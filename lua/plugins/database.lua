-- enable when needed
local enabled = os.getenv('START_DB') == '1'

return {
  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      { 'tpope/vim-dadbod', lazy = true },
      { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql', lazy = true } },
    },
    enabled = enabled,
    cmd = {
      'DB',
      'DBUI', 'DBUIToggle', 'DBUIAddConnection', 'DBUIFindBuffer',
    },
    config = function ()
      vim.g.db_ui_use_nerd_fonts = 1
    end,
  },
  {
    'davesavic/dadbod-ui-yank',
    dependencies = {
      'kristijanhusak/vim-dadbod-ui',
    },
    enabled = enabled,
  },
}

