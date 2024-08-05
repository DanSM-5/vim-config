-- Setup debugger in nvim
-- See: `https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation` for documentation
-- for adding debuggers for different languages

local dap = require('dap')

vim.keymap.set('n', '<leader>dt', dap.tottle_breakpoint, { desc = 'Debugger: Toggle Breakpoint' })
vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'Debugger: Continue' })

local dapui = require('dapui')

dapui.setup({})

dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end

