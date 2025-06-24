---@module 'markview'

return {
  setup = function ()
    -- Toggle :Markview

    ---@type markview.config
    local config = {
      preview = {
        enable = vim.g.is_termux == 1,
        icon_provider = 'internal',
      },
      ---@diagnostic disable-next-line
      experimental = {
        check_rtp_message = false,
      },
    }

    require('markview').setup(config)
    require('markview.extras.checkboxes').setup()
  end,
}

