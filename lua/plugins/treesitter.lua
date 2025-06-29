---@module 'lazy'
---@module 'treesitter-context'

---@type LazyPluginSpec|LazyPluginSpec[]
return {
  {
    event = 'VeryLazy',
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      {
        'nvim-treesitter/nvim-treesitter-context',
        ---@type TSContext.UserConfig
        opts = {
          enable = true,
        },
      },
    },
    build = ':TSUpdate',
    config = function()
      require('config.treesitter').setup()
    end
  },
  {
    -- event = 'VeryLazy',
    event = { 'BufReadPre' , 'LspAttach' },
    'CKolkey/ts-node-action',
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {},
  },
}
