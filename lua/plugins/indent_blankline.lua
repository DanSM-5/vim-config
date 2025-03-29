return {
  {
    'lukas-reineke/indent-blankline.nvim',
    event = 'VeryLazy',
    main = 'ibl',
    config = function ()
      require('config.nvim_indent-blankline').setup()
    end,
  },
  {
    'echasnovski/mini.indentscope',
    event = 'VeryLazy',
    config = function ()
      require('config.nvim_mindent').setup()
    end
  },
}
