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
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason-lspconfig.nvim',
      'nvimtools/none-ls.nvim',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      -- 'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'roginfarrer/cmp-css-variables',
      'stevearc/aerial.nvim',
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
