return {
  setup = function ()
    -- Toggle :Markview
    require('markview').setup({
      initial_state = vim.g.is_termux == 1
    })
  end
}

