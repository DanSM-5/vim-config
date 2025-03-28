-- Run lua code with
-- :lua <LUA COMMAND>

-- Help and documentation
-- :h lua
-- :h lua-guide
-- :h lspconfig-all

-- indicate wheter to use cmp or blink
-- local use_blink = os.getenv('USE_BLINK') == '1'

require('lsp-servers.nvim_mason').setup()
-- NOTE: Only load cmp for now. Blink is not defined in vimstart.
require('config.nvim_cmp').configure({ lazydev = false })
require('lsp-servers.lsp_settings').setup()
require('lsp-servers.nvim_fzf_lsp').setup()
require('config.nvim_aerial').setup()
require('config.treesitter').setup()
require('config.neo_tree').setup()
require('config.nvim_comments').setup()
require('config.nvim_gitsigns').setup()
require('config.oil_nvim').setup()
require('config.nvim_autopairs').setup()
require('config.treesitter_context').setup()
require('config.nvim_indent-blankline').setup()
require('config.nvim_prelive').setup()
require('config.nvim_markview').setup()
require('config.nvim_fugitive-difftool').setup()
require('config.nvim_cursor-text-objects').setup()
require('config.nvim_cursor_ref').setup()
require('config.nvim_hl_colors').setup()
require('config.nvim_mai').setup()
require('config.nvim_grugfar').setup()
require('config.nvim_bqf').setup()
require('config.nvim_quicker').setup()
require('config.nvim_hierarchy').setup()

-- NOTE: At some point I thought, why not put everything in an array
-- and load like below. Then I figured it messed up the lsp as it
-- can no longer infer the reference because it is now loaded dynamically.
-- Other information like types for a specific config will be lost as well.
-- It may look nicer but we lose more than we gain.
-- The snipper below is left as a reminder (and for reference in case I need it again)
-- that it isn't necessarily a good idea.

-- Define configs to load
-- local configs = {
--   'shared.big_files',
--   'lsp-servers.nvim_mason',
--   'lsp-servers.lsp_settings',
--   'lsp-servers.nvim_fzf_lsp',
--   'config.treesitter',
--   'config.neo_tree',
--   'config.nvim_comments',
--   'config.nvim_gitsigns',
--   'config.oil_nvim',
--   'config.nvim_autopairs',
--   'config.treesitter_context',
--   'config.nvim_indent-blankline',
--   'config.nvim_prelive',
-- }
--
-- -- Load all configs
-- for _, entry in ipairs(configs) do
--   if type(entry) == 'string' then
--     require(entry).setup()
--   elseif type(entry) == 'table' and entry.path and entry.config then
--     local path, config = entry.path, entry.config
--     require(path).setup(config)
--   end
-- end

-- Call plugins that need setup
-- require('Comment').setup({})
require('neo-img').setup()
require('split').setup({})
require('ts-node-action').setup({})
-- Start nvim autotag
require('nvim-ts-autotag').setup({
  opts = {
    -- Defaults
    enable_close = true, -- Auto close tags
    enable_rename = true, -- Auto rename pairs of tags
    enable_close_on_slash = false, -- Auto close on trailing </
  },
})

-- Set color for cursor word
vim.cmd('hi CursorWord gui=underline cterm=underline guibg=#4b5263')

require('shared.nvim_load')
require('shared.highlights').set_diagnostics()

