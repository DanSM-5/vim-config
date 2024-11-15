-- Entry point of lsp related plugins
return {
  {
    'williamboman/mason.nvim',
    config = require('lsp-servers.nvim_mason').setup
  },
  {
    'mawkler/refjump.nvim',
    keys = { ']r', '[r' }, -- Uncomment to lazy load
    config = require('config.nvim_refjump').setup
  },
  -- NOTE: Using magazine.nvim as as nvim-cmp replacement
  {
    'iguanacucumber/magazine.nvim',
    name = 'nvim-cmp',
  },
  {
    'L3MON4D3/LuaSnip',
    -- follow latest release.
    -- version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    -- install jsregexp (optional!).
    build = (function ()
      if vim.fn.executable('make') == 0 then
        return
      end
      return 'make install_jsregexp'
    end)(),
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Hook to mason
      'williamboman/mason-lspconfig.nvim',
      -- Lsp for linters/formatters
      'nvimtools/none-ls.nvim',
      -- Snippets
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets',
      -- Completions and sources
      -- 'hrsh7th/nvim-cmp', -- Currently substituted by magazine.nvim
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'roginfarrer/cmp-css-variables',
      'lukas-reineke/cmp-rg',
      -- 'hrsh7th/cmp-nvim-lua' -- { name = 'nvim_lua'  }
      -- 'hrsh7th/cmp-buffer' -- { name = 'path' }
      -- 'https://codeberg.org/FelipeLema/cmp-async-path' -- { name = 'async_path' }
      -- 'hrsh7th/cmp-path' -- { name = 'buffer' }
      -- 'hrsh7th/cmp-cmdline' -- { name = 'cmd' }
      -- 'Jezda1337/nvim-html-css' -- { name = 'html-css' }
      -- Find symbols
      'stevearc/aerial.nvim',
      -- Dependency
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require('lsp-servers.lsp_settings').setup({ completions = { enable = { lazydev = true } } })
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
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('lsp-servers.nvim_fzf_lsp').setup()
    end,
  },
}
