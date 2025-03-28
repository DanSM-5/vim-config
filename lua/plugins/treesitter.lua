return {
  {
    event = 'VeryLazy',
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'nvim-treesitter/nvim-treesitter-context'
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
