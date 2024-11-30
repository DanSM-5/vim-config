require('lsp-servers.types')

---@type table<string, LspConfigExtended>
local configs = {
  lua_ls = {
    on_attach = function(client, bufnr)
      client.server_capabilities.documentFormattingProvider = true
      client.server_capabilities.documentRangeFormattingProvider = true
      require('lsp-servers.keymaps').set_lsp_keys(client, bufnr)
    end,
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        telemetry = { enabled = false },
        workspace = { library = vim.api.nvim_get_runtime_file('', true) },
        format = {
          -- enable = true,
          defaultConfig = {
            insert_final_newline = true,
          },
        },
      },
    },
  },
  ts_ls = {
    on_attach = function(client, bufnr)
      ---@diagnostic disable-next-line: inject-field
      client.server_capabilities.document_formatting = false
      client.server_capabilities.documentFormattingProvider = false
      require('lsp-servers.keymaps').set_lsp_keys(client, bufnr)
    end,
  },
  vimls = {},
  biome = {},
  -- For bash lsp
  bashls = {
    filetypes = { 'sh', 'bash', 'zsh' },
    settings = {
      bashIde = {
        globPattern = '*@(.sh|.inc|.bash|.command|.zsh|.uconfrc|.uconfgrc|.ualiasrc|.ualiasgrc|.zsh_conf)',
      },
    },
  },
  ctags_lsp = {
    -- Prevent loading for all lsps
    filetypes = { 'go', 'c' },
  },
}

return {
  ---Get the configuration for a given lsp server
  ---@param name string
  ---@return LspConfigExtended | nil
  get_config = function(name)
    return configs[name]
  end,
}

