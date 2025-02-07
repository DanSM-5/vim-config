return {
  {
    'stevearc/oil.nvim',
    config = function ()
      require('config.oil_nvim').setup()
    end,
  },
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = "v3.x",
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
      'MunifTanjim/nui.nvim',
      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    config = function ()
      require('config.neo_tree').setup()
    end
  },
}
