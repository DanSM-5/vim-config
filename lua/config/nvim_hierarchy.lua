local set_keymaps = function ()
  vim.keymap.set({ 'n', 'x' }, '<space>cs', '<cmd>FunctionReferences<cr>', {
    desc = '[Hierarchy] Open call hierarchy of function under cursor',
    noremap = true,
  })
end

return {
  setup = function ()
    -- e.g. depth = 3
    require('hierarchy').setup({})
    set_keymaps()
  end,
  set_keymaps = set_keymaps,
}

