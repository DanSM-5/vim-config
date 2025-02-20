local name = 'mpls'
local configured = false

local configure = function()
  if configured then
    return
  end

  configured = true
  local has_configs, configs = pcall(require, 'lspconfig.configs')
  if not has_configs then
    return
  end

  if not configs.mpls then
    configs.mpls = {
      default_config = {
        name = name,
        cmd = { name, '--dark-mode', '--enable-emoji' },
        filetypes = { 'markdown' },
        single_file_support = true,
        ---Get root dir function
        ---@param startpath string starting path
        ---@return string Root directory
        root_dir = function (startpath)
          return require('utils.stdlib')
            .get_root_dir('.git', startpath)
        end,
        settings = {},
      },
      docs = {
        description = [[https://github.com/mhersson/mpls

Markdown Preview Language Server (MPLS) is a language server that provides
live preview of markdown files in your browser while you edit them in your favorite editor.
          ]],
      },
    }
  end
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
  if vim.fn.executable(name) == 0 then
    return
  end

  -- Set automatically for next buffers
  require('lsp-servers.lsp_settings')
    .get_lsp_handler()(name)

  -- Buffer to attach initially
  local bufnr = -1

  -- If start with bang, do not try to attach buffer
  if opts.skip_load then
    return
  end

  if opts.file ~= nil then
    ---@type string
    local buff_name = opts.file
    -- Allow to open a new file
    vim.cmd.edit(buff_name)

    -- NOTE: Current logic checks if the path exists
    -- and opens the buffer with edit.
    -- Should `vim.fn.bufadd(buff_name)` be used instead?

    -- -- Open if not already
    -- if (vim.uv or vim.loop).fs_stat(buff_name) then
    --   vim.cmd.edit(buff_name)
    -- else
    --   -- file does not exist, stop here
    --   return
    -- end

    -- checks if the buffer is not open yet. If so
    -- open it with edit.
    -- if vim.fn.bufexists(buff_name) ~= 1 then
    --   vim.cmd.edit(buff_name)
    -- end

    -- Get bufnr
    bufnr = vim.fn.bufnr(buff_name)
  end

  if bufnr == -1 then
    -- Use current buffer
    bufnr = vim.api.nvim_get_current_buf()
  end

  -- Start client if buffer is markdown
  ---@type string
  local curr_buff_ft = vim.api.nvim_get_option_value('filetype', {
    buf = bufnr,
  })

  -- Continue only if in a markdown buffer
  if curr_buff_ft ~= 'markdown' then
    return
  end

  local base_config = require('lsp-servers.config').get_config(name) or {}
  local update_capabilities = require('lsp-servers.lsp_settings')
    .get_completion_module_from_settings()
    .get_update_capabilities()
  local lsp_config = update_capabilities(base_config)
  -- Try to gess root dir
  local root_dir = require('utils.stdlib')
    .get_root_dir('.git')

  -- Start lsp on buffer
  local client_id = vim.lsp.start(
    vim.tbl_deep_extend('force', {
      name = name,
      cmd = { name, '--dark-mode', '--enable-emoji' },
      filetypes = { 'markdown' },
      single_file_support = true,
      root_dir = root_dir,
      settings = {},
      on_attach = require('lsp-servers.keymaps').set_lsp_keys,
    }, lsp_config),
    {
      bufnr = bufnr,
      silent = false,
      ---Since this should be the first created client,
      ---no other client should be reused
      ---@param client vim.lsp.Client
      ---@param config vim.lsp.ClientConfig
      ---@return boolean
      reuse_client = function(client, config)
        return client.name == name
      end,
    }
  )

  -- Attach to client
  -- Even though bufnr is specified above in the options for vim.lsp.start
  -- it still may not attach the requested buffer, so we add it manually
  if client_id ~= nil then
    vim.lsp.buf_attach_client(bufnr, client_id)
    vim.notify('[MPLS] bufnr: ' .. bufnr .. ' client: ' .. client_id, vim.log.levels.INFO)
  end
end

return {
  configure = configure,
  start = start,
  download = function()
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
  end,
}

