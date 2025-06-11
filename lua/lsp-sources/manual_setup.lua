---@module 'lsp-servers.types'

---Lsp servers to be setup when not using mason registry
---@type config.LspServerEntry[]
local manual_setup = {
  {
    -- WARN: ctags-lsp attaches to all buffers which could cause issues due to additional keybindings
    -- Exclusions can be added in `./lua/lsp-servers/keymaps.lua`
    -- Or consider defining specific filetypes.
    server = 'ctags-lsp',
    lsp = 'ctags_lsp',
    options = { keymaps = false }
  },
  {
    -- WARN: basics_ls attaches to all buffers which could cause issues due to additional keybindings
    -- Exclusions can be added in `./lua/lsp-servers/keymaps.lua`
    server = 'basics-language-server',
    lsp = 'basics_ls',
    options = { keymaps = false }
  },
  {
    -- WARN: basics_ls attaches to all buffers which could cause issues due to additional keybindings
    -- Exclusions can be added in `./lua/lsp-servers/keymaps.lua`
    server = 'ast-grep',
    lsp = 'ast_grep',
  },
}

return manual_setup

