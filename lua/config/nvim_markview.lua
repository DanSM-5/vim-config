return {
  setup = function ()
    -- Toggle :Markview
    require('markview').setup({
      preview = {
        enable = vim.g.is_termux == 1,
        icon_provider = 'internal',
      },
    })
    require('markview.extras.checkboxes').setup()
  end
}

