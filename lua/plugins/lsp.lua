---@module 'lazy'

-- indicate wheter to use cmp or blink
local use_blink = os.getenv('USE_BLINK') == '1'

---@type LazyPluginSpec
local luasnip_spec = {
  'L3MON4D3/LuaSnip',
  lazy = true,
  -- follow latest release.
  version = 'v2.*', -- Replace <CurrentMajor> by the latest released major (first number of latest release)
  -- tag = 'v2.*',
  -- install jsregexp (optional!).
  build = (function ()
    if vim.fn.executable('make') == 0 then
      return
    end
    return 'make install_jsregexp'
  end)(),
}

---@type LazyPluginSpec[]
local blink_deps = use_blink and {
  -- Snippets
  'rafamadriz/friendly-snippets',
  luasnip_spec,
  {
    'saghen/blink.compat',
    -- use the latest release, via version = '*', if you also use the latest release for blink.cmp
    version = '*',
    -- lazy.nvim will automatically load the plugin when it's required by blink.cmp
    lazy = true,
    -- make sure to set opts so that lazy.nvim calls blink.compat's setup
    -- opts = {},
  },
  'petertriho/cmp-git',
  'roginfarrer/cmp-css-variables',
  'mikavilpas/blink-ripgrep.nvim',
} or {}

---@type LazyPluginSpec[]
local cmp_deps = use_blink and {} or {
  -- Snippets
  'rafamadriz/friendly-snippets',
  luasnip_spec,
  'saadparwaiz1/cmp_luasnip',
  'petertriho/cmp-git',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-nvim-lsp-signature-help',
  'roginfarrer/cmp-css-variables',
  'lukas-reineke/cmp-rg',
  'nvim-tree/nvim-web-devicons',
  -- 'hrsh7th/cmp-nvim-lua' -- { name = 'nvim_lua'  }
  -- 'hrsh7th/cmp-buffer' -- { name = 'path' }
  -- 'https://codeberg.org/FelipeLema/cmp-async-path' -- { name = 'async_path' }
  -- 'hrsh7th/cmp-path' -- { name = 'buffer' }
  -- 'hrsh7th/cmp-cmdline' -- { name = 'cmd' }
  -- 'Jezda1337/nvim-html-css' -- { name = 'html-css' }
}

-- Entry point of lsp related plugins
---@type LazyPluginSpec[]
return {
  {
    'williamboman/mason.nvim',
    event = 'VeryLazy',
    config = function ()
      require('lsp-servers.nvim_mason').setup()
    end,
  },
  {
    -- Find symbols
    'stevearc/aerial.nvim',
    keys = {
      '<leader>fa',
      '<leader>ss',
      '<leader>sS',
      '[S', ']S',
    },
    cmd = {
      'AerialToggle',
      'AerialOpen',
      'AerialOpenAll',
      'AerialClose',
      'AerialCloseAll',
      'AerialNext',
      'AerialPrev',
      'AerialGo',
      'AerialInfo',
      'AerialNavToggle',
      'AerialNavOpen',
      'AerialNavClose',
    },
    -- event = 'VeryLazy',
    config = function ()
      -- Configure aerial.nvim
      local aerial_config = require('config.nvim_aerial')
      aerial_config.setup()
      local bufnr = vim.api.nvim_get_current_buf()
      aerial_config.set_keymaps(bufnr)
    end,
  },

  {
    -- BLINK
    'saghen/blink.cmp',
    enabled = use_blink,
    event = 'InsertEnter',
    -- optional: provides snippets for the snippet source
    -- dependencies = 'rafamadriz/friendly-snippets',
    dependencies = blink_deps,

    -- use a release tag to download pre-built binaries
    version = 'v1.*',
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',

    -- allows extending the providers array elsewhere in your config
    -- without having to redefine it
    opts_extend = { 'sources.default' },
    config = function ()
      require('config.nvim_blink').configure({ lazydev = true })
    end
  },

  {
    -- CMP
    -- 'hrsh7th/nvim-cmp', -- Currently substituted by magazine.nvim
    -- NOTE: Using magazine.nvim as as nvim-cmp replacement
    'iguanacucumber/magazine.nvim',
    enabled = not use_blink,
    event = 'InsertEnter',
    name = 'nvim-cmp',
    dependencies = cmp_deps,
    config = function ()
      require('config.nvim_cmp').configure({ lazydev = true })
    end,
  },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Hook to mason
      'williamboman/mason-lspconfig.nvim',
      -- Lsp for linters/formatters
      'nvimtools/none-ls.nvim',
      -- Dependency
      'nvim-tree/nvim-web-devicons',
      -- Ctags lsp
      -- 'netmute/ctags-lsp.nvim',
      {
        -- For jsonls to add schemas
        'b0o/SchemaStore.nvim',
        lazy = true,
      },
    },
    -- event = 'VimEnter',
    event = 'VeryLazy',
    config = function()
      require('lsp-servers.lsp_settings').setup({
        completions = {
          enable = { lazydev = true },
          engine = use_blink and 'blink' or 'cmp'
        }
      })
      -- NOTE: Call lsp start manually to attempt to attach current buffer
      vim.cmd('LspStart')
    end,
  },
  -- TODO: Review how to use powershell editor services
  -- {
  --   "TheLeoP/powershell.nvim",
  --   config = function ()
  --     ---@type powershell.user_config
  --     local opts = {
  --       bundle_path = vim.fn.stdpath('data') .. '/mason/packages/powershell-editor-services'
  --     }
  --
  --     local powershell_nvim = require('powershell')
  --     powershell_nvim.setup(opts)
  --   end,
  --   enabled = vim.fn.executable('pwsh'),
  --   ft = 'ps1'
  -- },

  -- Install with mason rust-analyzer and codelldb
  {
    'mrcjkb/rustaceanvim',
    enabled = false, -- enable back when used
    version = '^5', -- Recommended (avoid breaking changes)
    lazy = false, -- Already lazy
    ['rust-analyzer'] = {
      cargo = {
        allFeatures = true,
      },
    },
    ft = 'rust',
    -- config = function ()
    --   require('config.nvim_rustaceanvim').debug_setup()
    -- end
  },
  -- NOTE: Automatic format on save in rust
  -- {
  --   'rust-lang/rust.vim',
  --   tf = 'rust',
  --   init = function ()
  --     vim.g.rustfmt_autosave = 1
  --   end
  -- },
  -- NOTE: for nvim dap debugger
  -- {
  --   'mfussenegger/nvim-dap',
  -- },
  -- {
  --   'rcarriga/nvim-dap-ui',
  --   dependencies = {
  --     'mfussenegger/nvim-dap',
  --     'nvim-neotest/nvim-nio',
  --   },
  --   config = function ()
  --     require('debugger').setup()
  --   end
  -- },
  {
    'DanSM-5/fzf-lsp.nvim',
    cmd = {
      'Definitions',
      'Declarations',
      'TypeDefinitions',
      'Implementations',
      'References',
      'DocumentSymbols',
      'WorkspaceSymbols',
      'IncomingCalls',
      'OutgoingCalls',
      'CodeActions',
      'RangeCodeActions',
      'Diagnostics',
      'DiagnosticsAll',
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('lsp-servers.nvim_fzf_lsp').setup()
    end,
  },
  {
    'lafarr/hierarchy.nvim',
    cmd = { 'FunctionReferences' },
    keys = { { '<leader>sc', mode = { 'n', 'v' } } },
    config = function ()
      require('config.nvim_hierarchy').setup()
    end
  }
}

