local use_blink = os.getenv('USE_BLINK') == '1'

return {
  {
    'ColinKennedy/cursor-text-objects.nvim',
    event = 'VeryLazy',
    config = function()
      require('config.nvim_cursor-text-objects').setup()
    end,
    version = 'v1.*',
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    -- Optional dependency
    config = function()
      require('config.nvim_autopairs').setup({ use_cmp = not use_blink })
    end,
  },
  {
    -- enabled = false,
    'nvim-mini/mini.ai',
    event = 'VeryLazy',
    version = false,
    opts = {},
    config = function()
      require('config.nvim_mai').setup()
    end,
  },
}
