---@module 'lsp-servers.types'

---@type table<string, config.LspConfigExtended>
local configs = {
  lua_ls = {
    on_attach = function(client, bufnr)
      client.server_capabilities.documentFormattingProvider = true
      client.server_capabilities.documentRangeFormattingProvider = true
      require('lsp-servers.keymaps').set_lsp_keys(client, bufnr)
    end,
    settings = {
      Lua = {
        signatureHelp = { enabled = true },
        runtime = { version = 'LuaJIT' },
        telemetry = { enabled = false },
        workspace = { library = vim.api.nvim_get_runtime_file('', true), checkThirdparty = false },
        format = {
          enable = true,
          insert_final_newline = true,
          defaultConfig = {
            insert_final_newline = true,
            quote_style = 'single',
          },
        },
      },
    },
  },
  ts_ls = {
    on_attach = function(client, bufnr)
      -- Change as needed

      -- -@diagnostic disable-next-line: inject-field
      -- client.server_capabilities.document_formatting = false
      -- client.server_capabilities.documentFormattingProvider = false
      require('lsp-servers.keymaps').set_lsp_keys(client, bufnr)
    end,
    settings = {
      completions = {
        completeFunctionCalls = true,
      },
      preferences = {
        -- https://code.visualstudio.com/docs/getstarted/settings search for "// TypeScript" for preferences
        javascript = {
          format = { enable = true },
          validate = { enable = true },
          suggestionActions = { enabled = true },
          autoClosingTags = true,
          updateImportsOnFileMove = { enabled = 'always' },
          suggest = {
            enabled = true,
            autoImports = true,
            classMemberSnippets = { enabled = true },
            completeJSDocs = true,
            includeAutomaticOptionalChainCompletions = true,
            includeCompletionsForImportStatements = true,
            jsdoc = { generateReturns = true },
            names = true,
            paths = true,
          },
        },
        typescript = {
          format = { enable = true },
          validate = { enable = true },
          suggestionActions = { enabled = true },
          suggest = { autoImports = true },
        },
      },
    },
  },
  vimls = {},
  biome = {},
  eslint = {},
  eslint_d = {
    use_legacy = true,
  },
  stylua = {
    use_legacy = true,
  },
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
  jsonls = {
    -- Keeping both on_new_config and before_init to support old and new setup
    -- use_legacy = true,

    -- lazyload schemastore when needed
    on_new_config = function(config)
      config.settings.json.schemas = config.settings.json.schemas or {}
      vim.list_extend(config.settings.json.schemas, require('schemastore').json.schemas())
    end,
    before_init = function (params, config)
      config.settings.json.schemas = config.settings.json.schemas or {}
      vim.list_extend(config.settings.json.schemas, require('schemastore').json.schemas())
    end,
    settings = {
      json = {
        format = {
          enable = true,
        },
        validate = { enable = true },
      },
    },
  },
  gopls = {
    settings = {
      gopls = {
        gofumpt = true,
        codelenses = {
          gc_details = false,
          generate = true,
          regenerate_cgo = true,
          run_govulncheck = true,
          test = true,
          tidy = true,
          upgrade_dependency = true,
          vendor = true,
        },
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
        analyses = {
          nilness = true,
          unusedparams = true,
          unusedwrite = true,
          useany = true,
        },
        usePlaceholders = true,
        completeUnimported = true,
        staticcheck = true,
        directoryFilters = { '-.git', '-.vscode', '-.idea', '-.vscode-test', '-node_modules' },
        semanticTokens = true,
      },
    },
  },
  powershell_es = {
    use_legacy = true,
    bundle_path = vim.fn.stdpath('data') .. '/mason/packages/powershell-editor-services',
  },
  harper_ls = {
    use_legacy = true,
    settings = {
      harper_ls = {
        linters = {
          SentenceCapitalization = false,
          -- SpellCheck = false
        },
      },
    },
  },
}

return {
  ---Get the configuration for a given lsp server
  ---@param name string
  ---@return config.LspConfigExtended | nil
  get_config = function(name)
    local shallow_clone = require('utils.stdlib').shallow_clone
    local general_config = shallow_clone(configs[name] or {})

    ---@type boolean, config.LspConfigExtended
    local local_ok, local_config = pcall(require, 'lsp-configs.local.'..name)

    if local_ok then
      return vim.tbl_deep_extend('force', general_config, local_config)
    end

    return general_config
  end,
}
