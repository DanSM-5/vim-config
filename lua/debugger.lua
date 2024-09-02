-- Setup debugger in nvim
-- See: `https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation` for documentation
-- for adding debuggers for different languages

return {
  setup = function()
    local dap = require('dap')

    vim.keymap.set('n', '<leader>db', dap.tottle_breakpoint, { desc = 'Debugger: Toggle Breakpoint' })
    vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'Debugger: Continue' })

    vim.keymap.set('n', '<leader>dl', dap.step_into, { desc = 'Debugger: Step into function' })
    vim.keymap.set('n', '<leader>dj', dap.step_over, { desc = 'Debugger: Step over function' })
    vim.keymap.set('n', '<leader>dk', dap.step_out, { desc = 'Debugger: Step out of function' })
    vim.keymap.set('n', '<leader>dd', function()
        dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
      end,
      { desc = 'Debugger: Set conditional breakpoint' }
    )
    vim.keymap.set('n', '<leader>de', dap.terminate, { desc = 'Debugger: Termnate session' })
    vim.keymap.set('n', '<leader>dr', dap.run_last, { desc = 'Debugger: Run last' })

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
  end
}
