return {
  {
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
    -- keys = { ';', ',', 't', 'f', 'T', 'F', ']', '[', ']d', '[d' }, -- Uncomment this to lazy load
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    config = function ()
      require('config.nvim_demicolon').setup()
    end
  },
  {
    'CKolkey/ts-node-action',
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {},
  },
}
