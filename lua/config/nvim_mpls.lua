local name = 'mpls'
local configured = false
local filetypes = { 'markdown', 'markdown.mdx', 'makdown.mdx' }

local set_autocmds = function()
  ---@type uv_timer_t | nil
  local debounce_timer = nil
  local debounce_delay = 300

  local clean_timer = function ()
    if debounce_timer then
      debounce_timer:stop()
      debounce_timer:close()
      debounce_timer = nil
    end
  end

  local function sendMessageToMPLS()
    clean_timer()

    debounce_timer = (vim.uv or vim.loop).new_timer()
    debounce_timer:start(
      debounce_delay,
      0,
      vim.schedule_wrap(function()
        local bufnr = vim.api.nvim_get_current_buf()

        -- Start client if buffer is markdown
        ---@type string
        local curr_buff_ft = vim.api.nvim_get_option_value('filetype', {
          buf = bufnr,
        })

        if not vim.tbl_contains(filetypes, curr_buff_ft) then
          clean_timer()
          return
        end

        local clients = vim.lsp.get_clients({ name = name, bufnr = bufnr })

        -- clients[1]:notify()
        for _, client in ipairs(clients) do
          if client.name == name then
            -- NOTE: Updated to client:notify as per mpls documentation
            -- client:request(
            --   'mpls/editorDidChangeFocus',
            --   { uri = vim.uri_from_bufnr(bufnr) },
            --   function(err, result) end,
            --   bufnr
            -- )

            client:notify('mpls/editorDidChangeFocus', { uri = vim.uri_from_bufnr(bufnr) })
          end
        end

        clean_timer()
      end)
    )
  end

  vim.api.nvim_create_autocmd('BufEnter', {
    pattern = { '*.md', '*.mdx' },
    callback = sendMessageToMPLS,
    group = vim.api.nvim_create_augroup('MarkdownFocus', { clear = true }),
    desc = '[MPSL] Notify MPLS of buffer focus changes'
  })
end

local set_commands = function()
  ---@param opts { fargs: string[]; bang: boolean; }
  vim.api.nvim_create_user_command('MplsOpenPreview', function(opts)
    ---@type number
    local bufnr

    if opts.fargs[1] ~= nil and (vim.uv or vim.loop).fs_stat(opts.fargs[1]) then
      local buff_name = opts.fargs[1]
      bufnr = vim.fn.bufnr(buff_name, 1)
    else
      bufnr = vim.api.nvim_get_current_buf()
    end

    -- Start client if buffer is markdown
    ---@type string
    local curr_buff_ft = vim.api.nvim_get_option_value('filetype', {
      buf = bufnr,
    })

    -- Stop if requested buffer is not markdown
    if not vim.tbl_contains(filetypes, curr_buff_ft) then
      return
    end

    local clients = vim.lsp.get_clients({ name = name })
    ---@type vim.lsp.Client | nil
    local mpls_client = nil

    for _, client in ipairs(clients) do
      if client.name == 'mpls' then
        mpls_client = client
        break
      end
    end

    -- Only execute the command if the MPLS client is found
    if not mpls_client then
      print('mpls is not attached to the current buffer.')
      return
    end

    -- If requested buffer is not attached
    if not mpls_client.attached_buffers[bufnr] then
      vim.lsp.buf_attach_client(bufnr, mpls_client.id)
      vim.notify('[MPLS] bufnr: ' .. bufnr .. ' client: ' .. mpls_client.id, vim.log.levels.INFO)
    end

    local params = {
      command = 'open-preview',
      arguments = {},
    }
    mpls_client:request('workspace/executeCommand', params, function(err, _)
      if err then
        vim.notify('Error executing command: ' .. err.message, vim.log.levels.ERROR)
      else
        vim.notify('Preview opened', vim.log.levels.INFO)
      end
    end, bufnr)
  end, { bang = true, nargs = '?', complete = 'file', desc = '[MPLS] Request open preview for md file' })
end

local configure = function()
  if configured then
    return
  end

  configured = true
  set_commands()

  ---@type vim.lsp.Config
  local config = {
    name = name,
    cmd = { name, '--dark-mode', '--enable-emoji', '--enable-footnotes', '--code-style', 'onedark' },
    filetypes = filetypes,
    root_markers = { '.marksman.toml', '.git' },
    workspace_required = false,
    settings = {},
    on_attach = require('lsp-servers.keymaps').set_lsp_keys,
  }

  local update_capabilities =
      require('lsp-servers.lsp_settings').get_completion_module_from_settings().get_update_capabilities()
  config = update_capabilities(config)

  vim.lsp.config(name, config)
end

---Auto command for starting MPLS
---Usage :MPLS [/path/to/file]
---If current buffer is markdown, it will be used to attach
---If filename is provided, it will be use instead of current buffer
---If bang is used, it won't try to attach any buffer
---@param opts { skip_load?: boolean, file?: string }
local function start(opts)
  -- Setup lsp config
  configure()

  -- Prevent running if client does not exist
  if vim.fn.executable(name) == 0 or opts.skip_load then
    return
  end

  vim.lsp.enable(name)

  if (vim.uv or vim.loop).fs_stat(opts.file or '') then
    vim.cmd.edit(opts.file)
  end
end

---Download mpls lsp server from github releases
local download = function()
  local download_helper = vim.fn.substitute(vim.fn.expand('~/vim-config/utils/download_mpls'), '\\', '/', 'g')
  ---@type string[]
  local cmd = {}
  if vim.fn.has('win32') == 1 then
    -- Use powershell script on windows
    cmd = { 'powershell.exe', '-NoLogo', '-NonInteractive', '-NoProfile', '-File', download_helper .. '.ps1' }
  else
    cmd = { download_helper }
  end

  pcall(vim.system, cmd, {}, function()
    vim.schedule(function()
      vim.notify('[MPLS] Download completed', vim.log.levels.INFO)
    end)
  end)
end

return {
  configure = configure,
  start = start,
  download = download,
  set_commands = set_commands,
  set_autocmds = set_autocmds,
}
