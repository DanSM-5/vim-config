local set_keymaps = function ()
  vim.keymap.set('n', '<leader>q', function()
    require('quicker').toggle()
  end, {
    desc = 'Toggle quickfix',
  })
  vim.keymap.set('n', '<leader>l', function()
    require('quicker').toggle({ loclist = true })
  end, {
    desc = 'Toggle loclist',
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
  end,
  set_keymaps = set_keymaps,
}

