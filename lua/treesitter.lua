

-- Set treesitter
local config = require('nvim-treesitter.configs')
config.setup({
  ensure_installed = {
    'git_config',
    'git_rebase',
    'gitattributes',
    'gitcommit',
    'gitignore',
  },
  auto_install = true,
  highlight = { enable = true },
  indent = { enable = true },
})

