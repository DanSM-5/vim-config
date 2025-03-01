return {
  {
    'kevinhwang91/nvim-bqf',
    ft = 'qf',
    config = function ()
      require('config.nvim_bqf').setup()
    end
  },
  {
    'stevearc/quicker.nvim',
    ft = 'qf',
    config = function ()
      require('config.nvim_quicker').setup()
    end
  }
}

