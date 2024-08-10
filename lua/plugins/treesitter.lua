return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function()
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

    -- NOTE: For custom powershell treesitter parser:
    -- local treesitter_parser_config = require('nvim-treesitter.parsers').get_parser_configs()
    -- treesitter_parser_config.powershell = {
    --   install_info = {
    --     url = "~/.config/nvim/tsparsers/tree-sitter-powershell", -- need to update path
    --     files = { "src/parser.c", "src/scanner.c" },
    --     branch = "main",
    --     generate_requires_npm = false,
    --     requires_generate_from_grammar = false,
    --   },
    --   filetype = "ps1",
    -- }
  end
}
