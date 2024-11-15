local configs = {
  lua_ls = {
    ---@diagnostic disable-next-line: unused-local
    -- on_attach = function(client, bufnr)
    --   client.server_capabilities.documentFormattingProvider = true
    --   client.server_capabilities.documentRangeFormattingProvider = true
    -- end,
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
    on_attach = function(client)
      client.server_capabilities.document_formatting = false
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
}

return {
  ---Get the configuration for a given lsp server
  ---@param name string
  get_config = function(name)
    return configs[name]
  end,
}

