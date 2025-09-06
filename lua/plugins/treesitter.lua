---@module 'lazy'
---@module 'treesitter-context'

---@type LazyPluginSpec|LazyPluginSpec[]
return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    -- event = 'VeryLazy',
    build = ':TSUpdate',
    opts = {},
    -- config = function()
    --   require('config.treesitter').setup()
    -- end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    event = 'VeryLazy',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('config.treesitter_textobjects').setup()
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = 'VeryLazy',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    ---@type TSContext.UserConfig
    opts = {
      enable = true,
    },
  },
  {
    'MeanderingProgrammer/treesitter-modules.nvim',
    -- event = 'VeryLazy',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    config = function ()
      require('config.treesitter_modules').setup()
    end
  },
  {
    -- event = 'VeryLazy',
    event = { 'BufReadPre', 'LspAttach' },
    'CKolkey/ts-node-action',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    opts = {},
  },
}
