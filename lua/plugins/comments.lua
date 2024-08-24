return {
  {
    'numToStr/Comment.nvim',
    dependencies = {
      'JoosepAlviste/nvim-ts-context-commentstring',
    },
    config = function ()
      require('config.nvim_comments').setup()
    end
  }
}
