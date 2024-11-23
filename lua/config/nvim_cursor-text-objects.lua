
return {
  setup = function()
    local down_description = 'Operate from your current cursor to the end of some text-object.'
    local up_description = 'Operate from the start of some text-object to your current cursor.'

    vim.keymap.set('o', '[', '<Plug>(cursor-text-objects-up)', { desc = up_description })
    vim.keymap.set('o', ']', '<Plug>(cursor-text-objects-down)', { desc = down_description })
    vim.keymap.set('x', '[', '<Plug>(cursor-text-objects-up)', { desc = up_description })
    vim.keymap.set('x', ']', '<Plug>(cursor-text-objects-down)', { desc = down_description })
  end,
}

