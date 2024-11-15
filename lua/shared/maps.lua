
---Press yc to copy unamed(") register to system(*) register
vim.keymap.set('n', 'yc', function()
  require('utils.register').regmove('+', '"')
end, { noremap = true, desc = 'Copy from anon register to system cliboard register' })
vim.keymap.set('n', 'yC', function()
  require('utils.register').regmove('"', '+')
end, { noremap = true, desc = 'Copy from anon register to system cliboard register' })

