---Lsp servers to be setup when not using mason registry
---@type { server: string; lsp: string }[]
local manual_setup = {
  {
    -- WARN: ctags-lsp attaches to all buffers which could cause issues due to additional keybindings
    -- Exclusions can be added in `./lua/lsp-servers/keymaps.lua`
    -- Or consider defining specific filetypes.
    server = 'ctags-lsp',
    lsp = 'ctags_lsp',
  },
  {
    -- WARN: basics_ls attaches to all buffers which could cause issues due to additional keybindings
    -- Exclusions can be added in `./lua/lsp-servers/keymaps.lua`
    server = 'basics-language-server',
    lsp = 'basics_ls',
  },
}

return manual_setup
