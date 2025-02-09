return {
  {
    'brenoprata10/nvim-highlight-colors',
    config = function ()
      require('config.nvim_hl_colors').setup()
    end
  },
  {
    'OXY2DEV/helpview.nvim',
    lazy = false, -- Recommended

    -- In case you still want to lazy load
    -- ft = "help",

    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
  },
  {
    'OXY2DEV/markview.nvim',
    lazy = false,      -- Recommended
    -- ft = "markdown" -- If you decide to lazy-load anyway
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    config = function ()
      require('config.nvim_markview').setup()
    end,
  },
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },
}

