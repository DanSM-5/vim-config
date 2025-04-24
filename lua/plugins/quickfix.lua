return {
  {
    'kevinhwang91/nvim-bqf',
    ft = 'qf',
    event = {
      'QuickFixCmdPre',
      'Filetype qf',
    },
    config = function ()
      require('config.nvim_bqf').setup()
    end
  },
  {
    'stevearc/quicker.nvim',
    ft = 'qf',
    event = {
      'QuickFixCmdPre',
      'Filetype qf',
    },
    keys = {
      '<leader>q',
      '<leader>Q',
    },
    config = function ()
      require('config.nvim_quicker').setup()
    end
  }
}

