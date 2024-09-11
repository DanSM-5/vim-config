return {
  get_config = function()
    return {
      lua_ls = {
        ---@diagnostic disable-next-line: unused-local
        -- on_attach = function(client, bufnr)
        --   client.server_capabilities.documentFormattingProvider = true
        --   client.server_capabilities.documentRangeFormattingProvider = true
        -- end,
        settings = {
          Lua = {
            format = {
              -- enable = true,
              defaultConfig = {
                insert_final_newline = true
              }
            }
          }
        }
      },
      ts_ls = {
        on_attach = function (client)
          client.server_capabilities.document_formatting = false
        end
      },
      vimls = {},
      biome = {},
      -- For bash lsp
      bashls = {
        settings = {
          bashIde = {
            globPattern = '*@(.sh|.inc|.bash|.command|.zsh|.uconfrc|.uconfgrc|.ualiasrc|.ualiasgrc)'
          }
        }
      }
    }
  end
}
