-- Run lua code with
-- :lua <LUA COMMAND>

-- Help and documentation
-- :h lua
-- :h lua-guide
-- :h lspconfig-all

require('config.lsp_settings').setup()
require('config.treesitter').setup()
require('config.neo_tree').setup()
require('shared.autocmd')
-- require('./debugger')

