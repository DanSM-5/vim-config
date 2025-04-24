local set_keymaps = function ()
  local create_repeatable_func = require('utils.repeat_motion').create_repeatable_func

  local toggle_qf = create_repeatable_func(function()
    require('quicker').toggle()
  end)
  local toggle_locl = create_repeatable_func(function()
    require('quicker').toggle({ loclist = true })
  end)

  vim.keymap.set('n', '<leader>q', toggle_qf, {
    desc = '[quickfix] Toggle quickfix',
  })
  vim.keymap.set('n', '<leader>Q', toggle_locl, {
    desc = '[quickfix] Toggle loclist',
  })
end

return {
  setup = function ()
    require('quicker').setup({
      keys = {
        {
          '>',
          function()
            require('quicker').expand({ before = 2, after = 2, add_to_existing = true })
          end,
          desc = '[Quicker] Expand quickfix context',
        },
        {
          '<',
          function()
            require('quicker').collapse()
          end,
          desc = '[Quicker] Collapse quickfix context',
        },
      },
    })
    set_keymaps()
  end,
  set_keymaps = set_keymaps,
}

