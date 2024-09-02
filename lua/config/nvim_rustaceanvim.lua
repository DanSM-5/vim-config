return {
  debug_setup = function()
    local mason_registry = require('mason-registry')
    local codelldb = mason_registry.get_package('codelldb')
    local extension_path = codelldb:get_install_path() .. '/extension/'
    local codelldb_path = extension_path .. 'adapter/codelldb'
    local liblldb_path = extension_path .. 'lldb/lib/liblldb.dylib'
    local cfg = require('rustaceanvim')

    vim.g.rustaceanvim = {
      dap = {
        adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path)
      }
    }

    vim.keymap.set('n', '<leader>dt', function()
      vim.cmd('RustLsp testables')
    end, { desc = 'Debugger(rust): Run testables' })
  end
}
