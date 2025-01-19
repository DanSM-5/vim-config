require('lsp-servers.types')

---Start a lsp client by name
---@param name string
---@param buf? integer
local start_client = function (name, buf)
  ---@type boolean, LspConfigExtended
  local has_config, lspconfig_config = pcall(require, 'lspconfig.configs.'..name)
  if not has_config then
    -- a default config can still be available in configs
    -- check manually if such config is available
    local has_configs, configs = pcall(require, 'lspconfig.configs')
    if has_configs and configs[name] and configs[name].config_def and configs[name].config_def.default_config then
      ---@type LspConfigExtended
      lspconfig_config = configs[name].config_def.default_config
    else
      ---@type LspConfigExtended
      lspconfig_config = {}
    end
  end

  -- Start client if buffer matches filetype
  ---@type integer
  local bufnr = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf --[[@as integer]]
  local curr_buff_ft = vim.api.nvim_get_option_value('filetype', { buf = bufnr })
  local accepted_filetypes = lspconfig_config.filetypes or {}
  if not vim.tbl_contains(accepted_filetypes, curr_buff_ft) then
    return
  end

  ---Try to gess root dir
  --@type string
  local root_dir = ''
  if lspconfig_config.root_dir ~= nil then
    root_dir = type(lspconfig_config.root_dir) == 'string'
    and lspconfig_config.root_dir --[[@as string]]
    or  lspconfig_config.root_dir(vim.fn.expand('%:p'), bufnr)
  else
    -- fallback to the git repository
    root_dir = vim.fs.dirname(vim.fs.find('.git', { path = vim.fn.expand('%:p:h'), upward = true })[1]) or vim.fn.expand('%:p:h')
  end

  local base_config = require('lsp-servers.config').get_config(name) or {}
  local update_capabilities = require('lsp-servers.lsp_settings')
    .get_completion_module_from_settings()
    .get_update_capabilities()
  local config = update_capabilities(base_config)

  -- Start lsp on buffer
  local client_id = vim.lsp.start(
    vim.tbl_deep_extend('force', lspconfig_config, {
      -- vim.lsp.start does not use document accepting a function
      -- so we call the lspconfig if available to pass the resulting string
      root_dir = root_dir,
      on_attach = require('lsp-servers.keymaps').set_lsp_keys,
    }, config)
    , {
      bufnr = bufnr,
      silent = false,
      ---lsp config checks in its manager if buffer should be attach
      ---check just name may not be enough but give it a try for now
      ---@param client vim.lsp.Client
      ---@param config vim.lsp.ClientConfig
      ---@return boolean
      reuse_client = function (client, config)
        return client.name == name
      end
    })

  -- Attach to client
  -- Even though bufnr is specified above in the options for vim.lsp.start
  -- it still may not attach the requested buffer, so we add it manually
  if client_id ~= nil then
    vim.lsp.buf_attach_client(bufnr, client_id)
    vim.notify(
      string.format('[%s] bufnr: '..bufnr..' client: '..client_id, name),
      vim.log.levels.INFO
    )
  end
end

return {
  ---@param handler LspHandlerFunc
  setup = function (handler)
    -- Add functions to enable lsp clients
    -- with cmp capabilities on the fly

    ---@type LspHandlerFunc
    vim.g.LspEnableClient = handler
    vim.g.LspStartClient = start_client
    ---Enable and start a lsp client
    ---@param name string
    ---@param config LspServersSettings.options
    ---@param buffer? integer
    vim.g.LspSetupClient = function (name, config, buffer)
      handler(name, config)
      start_client(name, buffer)
    end
  end,
  start_client = start_client,
}

