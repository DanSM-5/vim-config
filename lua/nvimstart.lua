-- Run lua code with
-- :lua <LUA COMMAND>

-- Help and documentation
-- :h lua
-- :h lua-guide
-- :h lspconfig-all

require('lsp-servers.nvim_mason').setup()
require('lsp-servers.lsp_settings').setup()
require('lsp-servers.nvim_fzf_lsp').setup()
require('config.treesitter').setup()
require('config.neo_tree').setup()
require('shared.autocmd')
-- require('./debugger')

