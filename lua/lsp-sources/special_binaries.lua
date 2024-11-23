---This includes devices such as termux or runing inside containers
---which require special built binaries.
---@type { server: string; lsp: string }[]
local special_binaries = {
  {
    server = 'lua-language-server',
    lsp = 'lua_ls',
  },
  {
    server = 'bash-language-server',
    lsp = 'bashls',
  },
  {
    server = 'vim-language-server',
    lsp = 'vimls',
  },
  {
    server = 'typescript-language-server',
    lsp = 'ts_ls',
  },
  {
    server = 'emmet-language-server ',
    lsp = 'emmet_language_server '
  },
  {
    server = 'biome',
    lsp = 'biome',
  },
}

return special_binaries

