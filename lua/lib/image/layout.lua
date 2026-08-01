local M = {}

local function dimension(value, total)
  if type(value) ~= 'number' or value <= 0 then
    return 1
  end
  return math.max(1, math.floor(value <= 1 and total * value or value))
end

local function border_offsets(border)
  if border == nil or border == '' or border == 'none' then
    return 0, 0
  end
  if type(border) == 'table' then
    local function visible(part)
      return type(part) == 'string' and part ~= '' or type(part) == 'table' and part[1] ~= ''
    end
    return visible(border[1]) and 1 or 0, visible(border[8] or border[4] or border[2]) and 1 or 0
  end
  return 1, 1
end

local function title(source, config)
  local setting = config.layout.float.title
  if setting == false or config.layout.float.border == 'none' then
    return nil
  end
  if type(setting) == 'function' then
    return setting(source)
  end
  if type(setting) == 'string' then
    return setting
  end
  return ' ' .. vim.fn.fnamemodify(source.name or source.path or source.uri or 'image', ':~:.') .. ' '
end

local function configure_scratch_buffer(bufnr)
  vim.bo[bufnr].buflisted = false
  vim.bo[bufnr].bufhidden = 'wipe'
  vim.bo[bufnr].buftype = 'nofile'
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].filetype = 'lib_image'
  return bufnr
end

local function scratch_buffer()
  return configure_scratch_buffer(vim.api.nvim_create_buf(false, true))
end

local function clear_preview_buffer(bufnr)
  if vim.bo[bufnr].buftype ~= 'nofile' and not vim.b[bufnr].lib_image_source then
    return
  end
  local modifiable = vim.bo[bufnr].modifiable
  local readonly = vim.bo[bufnr].readonly
  vim.bo[bufnr].modifiable = true
  vim.bo[bufnr].readonly = false
  pcall(vim.api.nvim_buf_set_lines, bufnr, 0, -1, false, { '' })
  vim.bo[bufnr].modifiable = modifiable
  vim.bo[bufnr].readonly = readonly
end

local function fit(pixel_width, pixel_height, max_width, max_height, cell_width, cell_height)
  local natural_width = math.max(1, pixel_width / cell_width)
  local natural_height = math.max(1, pixel_height / cell_height)
  local scale = math.min(max_width / natural_width, max_height / natural_height)
  return math.max(1, math.floor(natural_width * scale + 0.5)), math.max(1, math.floor(natural_height * scale + 0.5))
end

local function find_preview_window()
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.wo[winid].previewwindow then
      return winid
    end
  end
  return nil
end

local function create_preview_window(config)
  local current = vim.api.nvim_get_current_win()
  local preview_config = config.layout.preview
  if preview_config.vertical then
    vim.cmd(('botright %dvnew'):format(dimension(preview_config.width, vim.o.columns)))
  else
    vim.cmd(('botright %dnew'):format(dimension(preview_config.height, vim.o.lines)))
  end
  local winid = vim.api.nvim_get_current_win()
  local bufnr = configure_scratch_buffer(vim.api.nvim_get_current_buf())
  vim.wo[winid].previewwindow = true
  vim.api.nvim_set_current_win(current)
  return winid, bufnr
end

local function window_layout(winid, bufnr, owned_win, owned_buf, border)
  local top, left = border_offsets(border)
  return {
    winid = winid,
    bufnr = bufnr,
    width = math.max(1, vim.api.nvim_win_get_width(winid)),
    height = math.max(1, vim.api.nvim_win_get_height(winid)),
    border_top = top,
    border_left = left,
    owned_win = owned_win,
    owned_buf = owned_buf,
  }
end

---@param target LibImageTarget
---@param source LibImageSource
---@param image table
---@param cell_width number
---@param cell_height number
---@param config LibImageConfig
---@return table? layout
---@return string? err
function M.open(target, source, image, cell_width, cell_height, config)
  local kind = target.kind or config.layout.default
  if kind == 'float' then
    local max_width = dimension(config.layout.float.max_width, vim.o.columns - 2)
    local max_height = dimension(config.layout.float.max_height, vim.o.lines - 2)
    local width, height = fit(image.width, image.height, max_width, max_height, cell_width, cell_height)
    local bufnr = scratch_buffer()
    local winid = vim.api.nvim_open_win(bufnr, target.focus ~= false, {
      relative = 'editor',
      width = width,
      height = height,
      row = math.max(0, math.floor((vim.o.lines - height) / 2)),
      col = math.max(0, math.floor((vim.o.columns - width) / 2)),
      style = 'minimal',
      border = config.layout.float.border,
      title = title(source, config),
      title_pos = config.layout.float.title_pos,
      zindex = config.layout.float.zindex,
    })
    return window_layout(winid, bufnr, true, true, config.layout.float.border)
  end

  if kind == 'tab' then
    vim.cmd.tabnew()
    local winid = vim.api.nvim_get_current_win()
    local bufnr = configure_scratch_buffer(vim.api.nvim_get_current_buf())
    return window_layout(winid, bufnr, true, true, nil)
  end

  if kind == 'preview' then
    local winid = find_preview_window()
    local bufnr
    local owned_win = false
    if not winid then
      winid, bufnr = create_preview_window(config)
      owned_win = true
    else
      bufnr = scratch_buffer()
      vim.api.nvim_win_set_buf(winid, bufnr)
    end
    return window_layout(winid, bufnr, owned_win, true, nil)
  end

  if kind == 'window' then
    local winid = target.winid
    if not winid or not vim.api.nvim_win_is_valid(winid) then
      return nil, 'The requested image target window is no longer valid'
    end
    local bufnr = target.bufnr
    local owned_buf = false
    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
      bufnr = scratch_buffer()
      vim.api.nvim_win_set_buf(winid, bufnr)
      owned_buf = true
    elseif vim.api.nvim_win_get_buf(winid) ~= bufnr then
      vim.api.nvim_win_set_buf(winid, bufnr)
    end
    clear_preview_buffer(bufnr)
    return window_layout(winid, bufnr, false, owned_buf, nil)
  end

  return nil, 'Unknown image layout: ' .. tostring(kind)
end

---@param layout table?
function M.close(layout)
  if not layout then
    return
  end
  if layout.owned_win and layout.winid and vim.api.nvim_win_is_valid(layout.winid) then
    pcall(vim.api.nvim_win_close, layout.winid, true)
  elseif layout.owned_buf and layout.bufnr and vim.api.nvim_buf_is_valid(layout.bufnr) then
    -- Existing plugin preview windows own their lifecycle. Leave the scratch
    -- buffer for that plugin to replace rather than changing its active window.
    pcall(vim.api.nvim_buf_set_lines, layout.bufnr, 0, -1, false, { '' })
  end
end

return M
