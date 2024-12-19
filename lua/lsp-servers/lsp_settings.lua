require('lsp-servers.types')

-- Manual lsp-config
-- This runs when loading lsp from VimPlug

-- https://github.com/DanSM-5/vim-config
-- Setup the lsp config
-- See: `:help lspconfig-setup`
-- local lspconfig = require('lspconfig')
-- lspconfig.lua_ls.setup({})

---@type LspSetttings
local defaultLspSetupOpts = {
  completions = {
    enable = {
      lazydev = false,
      crates = false,
    },
  },
}

return {
  ---Options when setting lsp features
  ---@param opts LspSetttings | nil
  setup = function(opts)
    ---@type LspSetttings
    opts = vim.tbl_deep_extend('force', defaultLspSetupOpts, opts or {})
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

    -- Configure hover window
    vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
      border = 'rounded',
      -- max_widht = 50,
      max_height = 50,
    })

    -- Setup lsp servers
    require('config.nvim_lspconfig').setup()

    -- Configure aerial.nvim
    require('config.nvim_aerial').setup()

    -- Buffer information
    -- See `:help vim.lsp.buf`

    -- NOTE: For css-variable set the global variable files with
    -- vim.g.css_variables_files = { 'variables.css', 'other/path' }

    local blink_sources_default = {
      'lsp',
      'snippets',
      'css-variables',
      'git',
      -- TODO: Check if keep
      'buffer',
      'path',
    }
    -- local blink_sources_completion = {
    --   enabled_providers = {
    --     'lsp',
    --     'snippets',
    --     -- 'css-variables',
    --     -- 'git',
    --   },
    -- }
    local blink_sources_providers = {
      ['css-variables'] = {
        name = 'css-variables',
        module = 'blink.compat.source',
      },
      git = {
        name = 'git',
        module = 'blink.compat.source',
      },
    }

    -- if opts.completions.enable.crates then
    --   table.insert(blink_sources_default, 'crates')
    -- end
    require('blink-compat').setup({})
    local blink = require('blink.cmp')
    local luasnip = require('luasnip')
    local capabilities =
      vim.tbl_deep_extend('force', {}, vim.lsp.protocol.make_client_capabilities(), blink.get_lsp_capabilities())


    -- Add ripgrep source if binary is available
    if vim.fn.executable('rg') then
      -- table.insert(blink_sources_completion.enabled_providers, { 'ripgrep' })
      table.insert(blink_sources_default, 'ripgrep')
      blink_sources_providers.ripgrep = {
        module = 'blink-ripgrep',
        name = 'Ripgrep',
        -- the options below are optional, some default values are shown
        ---@module 'blink-ripgrep'
        ---@type blink-ripgrep.Options
        opts = {
          -- For many options, see `rg --help` for an exact description of
          -- the values that ripgrep expects.

          -- the minimum length of the current word to start searching
          -- (if the word is shorter than this, the search will not start)
          prefix_min_len = 3,

          -- The number of lines to show around each match in the preview
          -- (documentation) window. For example, 5 means to show 5 lines
          -- before, then the match, and another 5 lines after the match.
          context_size = 5,

          -- The maximum file size of a file that ripgrep should include in
          -- its search. Useful when your project contains large files that
          -- might cause performance issues.
          -- Examples:
          -- "1024" (bytes by default), "200K", "1M", "1G", which will
          -- exclude files larger than that size.
          max_filesize = '2M',

          -- (advanced) Any additional options you want to give to ripgrep.
          -- See `rg -h` for a list of all available options. Might be
          -- helpful in adjusting performance in specific situations.
          -- If you have an idea for a default, please open an issue!
          --
          -- Not everything will work (obviously).
          additional_rg_options = {},
        },
      }
    end

    if opts.completions.enable.lazydev then
      blink_sources_providers.lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', fallbacks = { 'lsp' } }
      table.insert(blink_sources_default, 'lazydev')
    end

    require('cmp_git').setup()
    require('luasnip.loaders.from_vscode').lazy_load()

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    local blink_opts = {
      -- 'default' for mappings similar to built-in completion
      -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
      -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
      -- see the "default configuration" section below for full documentation on how to define
      -- your own keymap.
      keymap = {
        preset = 'enter',
        -- preset = 'default',
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
        ['<C-e>'] = { 'hide' },
        ['<C-y>'] = { 'select_and_accept' },
        ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
        ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
        ['<C-/>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-Space>'] = { 'select_and_accept' },
        ['<S-up>'] = { 'scroll_documentation_up', 'fallback' },
        ['<S-down>'] = { 'scroll_documentation_down', 'fallback' },
        ['<C-l>'] = { 'snippet_forward', 'fallback' },
        ['<C-h>'] = { 'snippet_backward', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
        -- ['<c-g>'] = {
        --   function()
        --     -- invoke manually, requires blink >v0.7.6
        --     require('blink-cmp').show({ sources = { 'ripgrep' } })
        --   end,
        -- },
      },
      appearance = {
        -- Sets the fallback highlight groups to nvim-cmp's highlight groups
        -- Useful for when your theme doesn't support blink.cmp
        -- will be removed in a future release
        use_nvim_cmp_as_default = true,
        -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
        kind_icons = {
          Text = '󰉿',
          Method = '󰆧',
          Function = '󰊕',
          Constructor = '󰒓',

          Field = '󰜢',
          Variable = '󰆦',
          Property = '󰖷',

          Class = '󰠱',
          Interface = '',
          Struct = '',
          Module = '󰅩',

          Unit = '󰪚',
          Value = '󰎠',
          Enum = '',
          EnumMember = '',

          Keyword = '󰌋',
          Constant = '󰏿',

          Snippet = '󱄽',
          Color = '󰏘',
          File = '󰈙',
          Reference = '󰬲',
          Folder = '󰉋',
          Event = '',
          Operator = '󰪚',
          TypeParameter = '󰬛',
        },
      },

      -- default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, via `opts_extend`
      sources = {
        default = blink_sources_default,
        -- completion = blink_sources_completion,
        providers = blink_sources_providers,

        -- optionally disable cmdline completions
        cmdline = {},
      },

      -- experimental signature help support
      signature = { enabled = true },
      snippets = {
        expand = function(snippet) luasnip.lsp_expand(snippet) end,
        active = function(filter)
          if filter and filter.direction then
            return luasnip.jumpable(filter.direction)
          end
          return luasnip.in_snippet()
        end,
        jump = function(direction) luasnip.jump(direction) end,

        -- Default
        -- Function to use when expanding LSP provided snippets
        -- expand = function(snippet) vim.snippet.expand(snippet) end,
        -- Function to use when checking if a snippet is active
        -- active = function(filter) return vim.snippet.active(filter) end,
        -- Function to use when jumping between tab stops in a snippet, where direction can be negative or positive
        -- jump = function(direction) vim.snippet.jump(direction) end,
      },

      -- Example for blocking multiple filetypes
      -- enabled = function()
      --  return not vim.tbl_contains({ "lua", "markdown" }, vim.bo.filetype)
      --    and vim.bo.buftype ~= "prompt"
      --    and vim.b.completion ~= false
      -- end,

      completion = {
        -- NOTE: Currently causes issues
        documentation = {
          auto_show = true,
        },
        menu = {
          draw = {
            padding = { 1, 1 },
            columns = {
              { 'label', 'label_description', gap = 1 },
              { 'kind_icon', 'kind', gap = 1 },
              { 'source_name' },
            },
            components = {
              kind_icon = { width = { fill = true } }
            },
          },
        },
      },
    }

    blink.setup(blink_opts)

    ---@type LspHandlerFunc
    local lspconfig_handler = function(server_name, options)
      if server_name == nil or type(server_name) ~= 'string' then
        vim.notify('No valid server name provided', vim.log.levels.WARN)
        return
      end

      -- Ensure not null
      options = options or {}

      -- Prevent mason-lspconfig from trying to start the LSP server
      -- for rust_analyzer. This is done through mrcjkb/rustaceanvim plugin
      if server_name == 'rust_analyzer' then
        return
      end

      local base_config = require('lsp-servers.config').get_config(server_name) or {}
      base_config.capabilities = base_config.capabilities and blink.get_lsp_capabilities(base_config.capabilities) or capabilities

      ---@type lspconfig.Config
      local config = vim.tbl_deep_extend('force', {}, base_config, { capabilities = capabilities })

      -- Add keymaps on buffer with lsp
      -- NOTE: Only include automatically on configs that do not include a `on_attach`
      -- If the config has `on_attach`, then it should add the keymaps there
      if options.keymaps ~= false and config.on_attach == nil then
        config.on_attach = require('lsp-servers.keymaps').set_lsp_keys
      end

      require('lspconfig')[server_name].setup(config)
    end

    -- Add setup function available globally 😎
    -- This is so it is available to start new lsp servers
    -- with cmp capabilities on the fly
    vim.g.SetupLsp = lspconfig_handler

    local mason_lspconfig_opts = {
      ensure_installed = language_servers,
      handlers = {
        lspconfig_handler,
      },
    }

    -- Setup mason_lspconfig to activate lsp servers
    -- automatically
    local mason_lsp = require('mason-lspconfig')
    mason_lsp.setup(mason_lspconfig_opts)

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

