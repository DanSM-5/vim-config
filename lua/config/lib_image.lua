local M = {}

local setup_done = false

local function image()
  return require('lib.image')
end

local function active_session()
  local session = package.loaded['lib.image.session']
  if session and session.status().active then
    return session
  end
  return nil
end

local function trim_command_source(value)
  value = vim.trim(value or '')
  if (value:sub(1, 1) == '"' and value:sub(-1) == '"') or (value:sub(1, 1) == "'" and value:sub(-1) == "'") then
    value = value:sub(2, -2)
  end
  return value:gsub('\\ ', ' ')
end

local function command_source(bufnr, value)
  value = trim_command_source(value)
  if value ~= '' then
    return value
  end
  local configured_source = vim.b[bufnr].lib_image_source
  if configured_source and configured_source ~= '' then
    return configured_source
  end
  local resolved = image().resolve_at_cursor({ bufnr = bufnr, generic = true })
  if resolved then
    return resolved.target
  end
  local name = vim.api.nvim_buf_get_name(bufnr)
  return name ~= '' and name or nil
end

local function preview_command(opts, forced_target)
  local args = vim.trim(opts.args or '')
  local question = args:sub(1, 1) == '?'
  if question then
    args = vim.trim(args:sub(2))
  end
  local target = forced_target
    or (opts.bang and { kind = 'tab' })
    or (question and { kind = 'preview' })
    or { kind = 'float' }
  local bufnr = vim.api.nvim_get_current_buf()
  local source = command_source(bufnr, args)
  if not source then
    vim.notify('No path, URI, current file, or Markdown image found to preview', vim.log.levels.WARN, {
      title = 'Image preview',
    })
    return
  end
  local result = image().preview(source, { bufnr = bufnr, explicit = true, target = target })
  if not result.handled and result.error then
    vim.notify(result.error, vim.log.levels.WARN, { title = 'Image preview' })
  end
end

local function normal_bufread(bufnr, path)
  vim.api.nvim_buf_call(bufnr, function()
    vim.bo[bufnr].buftype = ''
    vim.bo[bufnr].modifiable = true
    vim.bo[bufnr].readonly = false
    vim.cmd('silent noautocmd keepalt 0read ' .. vim.fn.fnameescape(path))
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    if line_count > 1 and vim.api.nvim_buf_get_lines(bufnr, line_count - 1, line_count, false)[1] == '' then
      vim.api.nvim_buf_set_lines(bufnr, line_count - 1, line_count, false, {})
    end
    vim.bo[bufnr].modified = false
    vim.api.nvim_exec_autocmds('BufReadPost', { buffer = bufnr, modeline = true })
  end)
end

local function preview_buffer(bufnr, path)
  vim.bo[bufnr].buftype = 'nofile'
  vim.bo[bufnr].bufhidden = 'hide'
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'Loading image preview…', path })
  vim.bo[bufnr].modified = false
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].readonly = true
  vim.bo[bufnr].filetype = 'lib_image'
  vim.b[bufnr].lib_image_source = path
  vim.keymap.set('n', 'q', function()
    image().close_for_buffer(bufnr)
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end, { buffer = bufnr, nowait = true, silent = true, desc = 'Close image preview buffer' })

  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end
    local status = image().status()
    if status.active and status.source == path then
      return
    end
    local wins = vim.fn.win_findbuf(bufnr)
    if #wins > 0 then
      image().preview(path, {
        bufnr = bufnr,
        explicit = false,
        target = { kind = 'window', winid = wins[1], bufnr = bufnr, focus = false },
      })
    end
  end)
end

local function auto_patterns()
  local result = {}
  local extensions = {}
  for _, values in ipairs({
    image().defaults().auto_preview.extensions,
    image().get_config().auto_preview.extensions,
  }) do
    for _, ext in ipairs(values) do
      extensions[ext:lower()] = true
    end
  end
  for ext in pairs(extensions) do
    local insensitive = ext:gsub('%a', function(character)
      return ('[%s%s]'):format(character:lower(), character:upper())
    end)
    table.insert(result, '*.' .. insensitive)
  end
  return result
end

local function find_explorer_buffer(filetype, except_win)
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if winid ~= except_win then
      local bufnr = vim.api.nvim_win_get_buf(winid)
      if vim.bo[bufnr].filetype == filetype then
        return bufnr
      end
    end
  end
  return vim.api.nvim_get_current_buf()
end

local function find_preview_window(candidate)
  if candidate and vim.api.nvim_win_is_valid(candidate) and vim.wo[candidate].previewwindow then
    return candidate
  end
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.wo[winid].previewwindow then
      return winid
    end
  end
  return nil
end

local function explorer_path(path, filetype, source_buf)
  if vim.fn.isabsolutepath(path) == 1 or path:match('^[%a][%w+.-]*:') then
    return path
  end
  local cwd_path = vim.fs.normalize(vim.fs.joinpath(vim.fn.getcwd(), path))
  if vim.uv.fs_stat(cwd_path) then
    return cwd_path
  end
  local ok, explorer = pcall(require, filetype == 'canola' and 'canola' or 'oil')
  local directory = ok and explorer.get_current_dir and explorer.get_current_dir(source_buf) or nil
  if directory then
    return vim.fs.normalize(vim.fs.joinpath(directory, path))
  end
  return cwd_path
end

---Oil/compatible-Canola hook for `preview_win.disable_preview`.
---@param path string
---@return boolean disable_builtin
function M.oil_disable_preview(path)
  local callback_win = vim.api.nvim_get_current_win()
  local source_buf = find_explorer_buffer('oil', callback_win)
  path = explorer_path(path, 'oil', source_buf)
  if not image().can_preview(path, { bufnr = source_buf, explicit = false }) then
    return false
  end
  vim.schedule(function()
    local preview_win = find_preview_window(callback_win)
    if preview_win then
      local preview_buf = vim.api.nvim_win_get_buf(preview_win)
      image().preview(path, {
        bufnr = source_buf,
        explicit = false,
        notify = false,
        target = { kind = 'window', winid = preview_win, bufnr = preview_buf, focus = false },
      })
    end
  end)
  return true
end

local function setup_commands()
  vim.api.nvim_create_user_command('PreviewImage', preview_command, {
    bang = true,
    nargs = '*',
    complete = 'file',
    desc = 'Preview a path/URI (`?` uses a preview window; `!` uses a new tab)',
  })
  vim.api.nvim_create_user_command('PreviewImageWindow', function(opts)
    preview_command(opts, { kind = 'preview' })
  end, { nargs = '*', complete = 'file', desc = 'Preview a path/URI in a reusable preview window' })
  vim.api.nvim_create_user_command('PreviewImageClose', function()
    image().close()
  end, { desc = 'Close the active image preview' })
  vim.api.nvim_create_user_command('PreviewImageRedraw', function()
    image().redraw()
  end, { desc = 'Redraw the active image preview' })
end

local function setup_autocmds()
  local group = vim.api.nvim_create_augroup('lib_image', { clear = true })
  vim.api.nvim_create_autocmd('BufReadCmd', {
    group = group,
    pattern = auto_patterns(),
    callback = function(event)
      local effective = image().get_config(event.buf)
      local path = vim.fn.fnamemodify(event.file, ':p')
      if effective.auto_preview.enabled and image().can_preview(path, { bufnr = event.buf, explicit = false }) then
        preview_buffer(event.buf, path)
      else
        normal_bufread(event.buf, path)
      end
    end,
    desc = 'Open supported media as an image preview',
  })
  vim.api.nvim_create_autocmd('BufWinEnter', {
    group = group,
    callback = function(event)
      local path = vim.b[event.buf].lib_image_source
      if not path or image().status().source == path then
        return
      end
      local winid = vim.api.nvim_get_current_win()
      image().preview(path, {
        bufnr = event.buf,
        explicit = false,
        target = { kind = 'window', winid = winid, bufnr = event.buf, focus = false },
      })
    end,
    desc = 'Restore an image preview buffer when it becomes visible',
  })
  vim.api.nvim_create_autocmd('BufLeave', {
    group = group,
    callback = function(event)
      if not vim.b[event.buf].lib_image_source then
        return
      end
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(event.buf) or #vim.fn.win_findbuf(event.buf) > 0 then
          return
        end
        local status = image().status()
        if status.bufnr == event.buf or status.bufnr == nil and status.source_bufnr == event.buf then
          image().close_for_buffer(event.buf)
        end
      end)
    end,
    desc = 'Clear terminal image data when leaving a preview buffer',
  })

  local redraw_pending = false
  vim.api.nvim_create_autocmd({ 'WinScrolled', 'ColorScheme' }, {
    group = group,
    callback = function()
      local session = active_session()
      if redraw_pending or not session then
        return
      end
      redraw_pending = true
      vim.schedule(function()
        redraw_pending = false
        local current = active_session()
        if current then
          current.redraw()
        end
      end)
    end,
    desc = 'Keep the terminal image aligned with its Neovim window',
  })
  vim.api.nvim_create_autocmd('VimResized', {
    group = group,
    callback = function()
      local session = active_session()
      if session then
        require('lib.image.terminal').reset()
        session.redraw({ resize = true })
      end
    end,
    desc = 'Resize the active image preview',
  })
  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = group,
    callback = function()
      local session = package.loaded['lib.image.session']
      if session then
        session.close()
      end
    end,
    desc = 'Clear terminal image data before Neovim exits',
  })

  -- The independent Canola branch emits this event and also respects our
  -- BufReadCmd patterns. The checked-out Oil-compatible fork uses the hook
  -- above and never reaches this adapter.
  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'CanolaPreviewDisable',
    callback = function(event)
      local data = event.data or {}
      local path = data.filename or data.path
      local callback_win = vim.api.nvim_get_current_win()
      local source_buf = find_explorer_buffer('canola', callback_win)
      if not path or vim.bo[source_buf].filetype ~= 'canola' then
        return
      end
      path = explorer_path(path, 'canola', source_buf)
      if not image().can_preview(path, { bufnr = source_buf, explicit = false }) then
        return
      end
      data.result = true
      vim.schedule(function()
        local preview_win = find_preview_window(callback_win)
        if preview_win then
          local preview_buf = vim.api.nvim_win_get_buf(preview_win)
          image().preview(path, {
            bufnr = source_buf,
            explicit = false,
            notify = false,
            target = { kind = 'window', winid = preview_win, bufnr = preview_buf, focus = false },
          })
        end
      end)
    end,
    desc = 'Use lib.image for media in the independent Canola preview window',
  })
end

function M.setup()
  if setup_done then
    return
  end
  setup_done = true
  setup_commands()
  setup_autocmds()
end

return M
