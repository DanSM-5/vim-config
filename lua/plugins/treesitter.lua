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
    'mawkler/demicolon.nvim',
    keys = {
      ';', ',',
      't', 'f',
      'T', 'F',
      ']', '[',
      ']d', '[d',
      ']c', '[c',
      ']s', '[s',
      ']z', '[z',
      ']q', '[q',
      ']l', '[l',
      ']<C-Q>', '[<C-Q>',
      ']<C-L>', '[<C-L>',
    }, -- Uncomment this to lazy load
    -- event = 'VeryLazy',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    config = function ()
      require('config.nvim_demicolon').setup()
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
