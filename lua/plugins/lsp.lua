-- Entry point of lsp related plugins
return {
  {
    'williamboman/mason.nvim',
    config = function ()
      require('lsp-servers.nvim_mason').setup()
    end
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-nvim-lsp',
      'williamboman/mason-lspconfig.nvim',
      'L3MON4D3/LuaSnip',
      'roginfarrer/cmp-css-variables'
    },
    config = function()
      require('lsp-servers.lsp_settings').setup({ enable_lazydev = true })
    end
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
  {
    'DanSM-5/fzf-lsp.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim'
    },
    config = function ()
      require('lsp-servers.nvim_fzf_lsp').setup()
    end
  }
}
