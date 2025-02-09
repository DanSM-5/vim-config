local autopairs_deps = os.getenv('USE_BLINK') == '1' and {} or {
  {
    'iguanacucumber/magazine.nvim',
    -- 'hrsh7th/nvim-cmp', -- Currently substituted by magazine.nvim
    -- NOTE: Using magazine.nvim as as nvim-cmp replacement
    name = 'nvim-cmp',
  },
}

return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  -- Optional dependency
  dependencies = autopairs_deps,
  config = function ()
    require('config.nvim_autopairs').setup()
  end,
}
