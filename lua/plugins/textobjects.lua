local autopairs_deps = os.getenv('USE_BLINK') == '1' and {} or {
  {
    'iguanacucumber/magazine.nvim',
    -- 'hrsh7th/nvim-cmp', -- Currently substituted by magazine.nvim
    -- NOTE: Using magazine.nvim as as nvim-cmp replacement
    name = 'nvim-cmp',
  },
}

return {
  {
    'ColinKennedy/cursor-text-objects.nvim',
    config = function ()
      require('config.nvim_cursor-text-objects').setup()
    end,
    version = 'v1.*',
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    -- Optional dependency
    dependencies = autopairs_deps,
    config = function ()
      require('config.nvim_autopairs').setup()
    end,
  },
  {
    'echasnovski/mini.ai',
    version = false,
    opts = {},
  },
}

