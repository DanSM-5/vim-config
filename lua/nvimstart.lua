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
require('config.nvim_comments').setup()
require('config.nvim_gitsigns').setup()

-- Call plugins that need setup
-- require('Comment').setup({})

-- Imitate vinegar '-' map
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
-- Set color for cursor word
vim.cmd('hi CursorWord gui=underline cterm=underline guibg=#4b5263')

-- require('shared.autocmd')
-- require('debugger').setup()

