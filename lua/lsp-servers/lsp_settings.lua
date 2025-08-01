---@module 'lsp-servers.types'

-- Manual lsp-config
-- This runs when loading lsp from VimPlug

-- https://github.com/DanSM-5/vim-config
-- Setup the lsp config
-- See: `:help lspconfig-setup`
-- local lspconfig = require('lspconfig')
-- lspconfig.lua_ls.setup({})

---Get the default lsp setup settings
---@return config.LspSettings
local function get_default_settings ()
  return {
    completions = {
      enable = {
        lazydev = false,
        crates = false,
      },
      engine = 'cmp',
    },
  }
end

---@type config.LspSettings
local lsp_settings = get_default_settings()

---Update lsp_settings using tbl_deep_extend
---@param new_settings config.LspSettings
local function update_lsp_settings (new_settings)
  lsp_settings = vim.tbl_deep_extend('force', lsp_settings, new_settings or {})
  return lsp_settings
end
---Sets new lsp settings
---@param new_settings config.LspSettings
local function set_lsp_settings (new_settings)
  lsp_settings = new_settings
end
---Gets the lsp settings
---@return config.LspSettings
local function get_lsp_settings ()
  return lsp_settings
end

local get_completion_module_from_settings = function ()
  local current_settings = get_lsp_settings()
  local completions_module = current_settings.completions.engine == 'blink'
    and require('config.nvim_blink')
    or require('config.nvim_cmp')
  return completions_module
end

---Get the lsp handler for mason_lspconfig and other functions that register lsp clients
---@return fun(server_name: string, options?: config.LspServerEntry.options):nil
local function get_lsp_handler ()
    -- Get the hook to enable lsp completions
  local update_capabilities = get_completion_module_from_settings()
    .get_update_capabilities()

  ---@type config.LspHandlerFunc
  local lspconfig_handler = function(server_name, options)
    if server_name == nil or type(server_name) ~= 'string' then
      vim.notify('No valid server name provided', vim.log.levels.WARN)
      return
    end

    -- Ensure not null
    ---@type config.LspServerEntry.options
    options = vim.tbl_deep_extend('force', { enable = true }, options or {})

    -- Prevent mason-lspconfig from trying to start the LSP server
    -- for rust_analyzer. This is done through mrcjkb/rustaceanvim plugin
    if server_name == 'rust_analyzer' then
      return
    end

    local base_config = require('lsp-servers.config').get_config(server_name) or {}

    ---@type config.LspConfigExtended
    local config = update_capabilities(base_config)

    -- Add keymaps on buffer with lsp
    -- NOTE: Only include automatically on configs that do not include a `on_attach`
    -- If the config has `on_attach`, then it should add the keymaps there
    if options.keymaps ~= false and config.on_attach == nil then
      config.on_attach = require('lsp-servers.keymaps').set_lsp_keys
    end

    if config.use_legacy then
      require('lspconfig')[server_name].setup(config)
    else
      vim.lsp.config(server_name, config)

      if options.enable then
        vim.lsp.enable(server_name, true)
      end
    end
  end

  return lspconfig_handler
end

---Attempt to attach a buffer to enabled clients from lspconfig or vim.lsp.enable
---@param bufnr integer Buffer id to attach
local try_attach_buffer = function (bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if vim.bo[bufnr].buftype == 'nofile' or #bufname == 0 or (not vim.api.nvim_buf_is_valid(bufnr)) then
    return
  end

  local lspconfig, configs = pcall(require, 'lspconfig.configs')
  if lspconfig then
    for _, key in ipairs(require('lspconfig.util').available_servers()) do
      local config = configs[key]
      if type(config.launch) == 'function' and (config.filetypes == nil or vim.tbl_contains(config.filetypes, vim.bo[bufnr].filetype)) then
        config.launch(bufnr)
      end
    end
  end

  for _, key in ipairs(vim.tbl_keys(vim.lsp._enabled_configs)) do
    if vim.lsp.config[key] and (vim.tbl_contains(vim.lsp.config[key].filetypes or {}, vim.bo[bufnr].filetype) or vim.lsp.config[key].filetype == vim.bo[bufnr].filetype) then
      local clients = vim.lsp.get_clients({ name = key })
      if #clients > 0 then
        vim.lsp.buf_attach_client(bufnr, clients[1].id)
      else
        local client_id = vim.lsp.start(vim.lsp.config[key])
        if client_id then
          vim.lsp.buf_attach_client(bufnr, client_id)
        end
      end
    end
  end
end

return {
  try_attach_buffer = try_attach_buffer,
  update_lsp_settings = update_lsp_settings,
  set_lsp_settings = set_lsp_settings,
  get_lsp_settings = get_lsp_settings,
  get_default_settings = get_default_settings,
  get_completion_module_from_settings = get_completion_module_from_settings,
  get_lsp_handler = get_lsp_handler,

  ---Options when setting lsp features
  ---@param opts config.LspSettings | nil
  setup = function(opts)
    -- Update settings
    opts = update_lsp_settings(opts or {})

    local special_binaries = vim.g.is_termux == 1 or vim.g.is_container == 1
    local language_servers = special_binaries and {}
      or {
        -- # Use lspconfig names
        'lua_ls',
        'vimls',
        -- 'biome',
        'bashls',
        -- 'css-lsp',
        'css_variables',
        'eslint',
        -- 'eslint_d',
        -- 'powershell_es',
        -- 'stylua',
        'ts_ls',
        'html',
        'emmet_language_server',
        'jsonls',
      }

    -- Keymaps for legacy support. To remove when nvim-0.12.0 is released
    if vim.fn.has('nvim-0.11.0') == 0 then
      -- Configure hover window
      ---@diagnostic disable-next-line: deprecated
      vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = 'rounded',
        -- max_widht = 50,
        max_height = 50,
      })
      ---@diagnostic disable-next-line: deprecated
      vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = 'rounded',
      })
    end

    -- Setup lsp servers
    require('config.nvim_lspconfig').setup()

    -- Configure aerial.nvim
    -- require('config.nvim_aerial').setup()

    -- Buffer information
    -- See `:help vim.lsp.buf`

    ---@type config.LspHandlerFunc
    local lspconfig_handler = get_lsp_handler()

    -- Use utils to attach global functions
    require('lsp-servers.utils').setup(lspconfig_handler)

    local mason_lspconfig_opts = {
      ensure_installed = language_servers,
      automatic_enable = false,
      -- Deprecated in nvim 0.11.2
      -- handlers = {
      --   lspconfig_handler,
      -- },
    }

    -- Setup mason_lspconfig to activate lsp servers
    -- automatically
    local mason_lsp = require('mason-lspconfig')
    mason_lsp.setup(mason_lspconfig_opts)

    -- Manually enable lsp servers
    for _, server_name in ipairs(mason_lsp.get_installed_servers()) do
      lspconfig_handler(server_name)
    end

    local none_ls = require('null-ls')
    none_ls.setup({
      sources = {
        none_ls.builtins.formatting.stylua,
        none_ls.builtins.code_actions.gitrebase,
        -- https://github.com/CKolkey/ts-node-action
        none_ls.builtins.code_actions.ts_node_action,
        none_ls.builtins.code_actions.gitsigns,
        -- With filter
        -- none_ls.builtins.code_actions.gitsigns.with({
        --   config = {
        --     filter_actions = function (title)
        --       return title:lower():match('blame') == nil
        --     end
        --   }
        -- }),
        -- none_ls.builtins.formatting.eslint,
        -- none_ls.builtins.diagnostics.prettier,
      },
    })

    -- configure when not using mason-lspconfig
    local manual_setup = require('lsp-servers.lsp_manual_config')
    local manual_setup_config = {
      lspconfig_handler = lspconfig_handler,
    }

    -- Load lsp manually from the manual selected list for environments such
    -- as termux which uses lsps not built with gnu libraries
    if special_binaries then
      manual_setup.set_special_binaries(manual_setup_config)
    end
    manual_setup.set_manual_setup(manual_setup_config)
    manual_setup.set_device_specific(manual_setup_config)
  end,
}

