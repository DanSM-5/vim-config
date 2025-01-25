
return {
  {
    'tpope/vim-fugitive',
    dependencies = {
      'tpope/vim-rhubarb',
    },
  },
  {
    'lewis6991/gitsigns.nvim',
    config = function ()
      require('config.nvim_gitsigns').setup()
    end,
  },
  {
    'jecaro/fugitive-difftool.nvim',
    cmd = {
      -- To the first
      'Gcfr',
      -- To the last
      'Gcla',
      -- To the next
      'Gcn',
      -- To the previous
      'Gcp',
      -- To the currently selected
      'Gcc',
    },
    -- Usage
    -- :Git! difftool --name-status master..my-feature
    -- :Gcc
    config = function ()
      require('config.nvim_fugitive-difftool').setup()
    end,
  },
  {
    'rbong/vim-flog',
    lazy = true,
    cmd = { 'Flog', 'Flogsplit', 'Floggit' },
    dependencies = {
      'tpope/vim-fugitive',
    },
  },
  {
    'oflisback/cursor-git-ref-command.nvim',
    cmd = {
      'CursorCheckOut',
      'CursorCherryPick',
      'CursorDrop',
      'CursorResetHard',
      'CursorResetMixed',
      'CursorResetSoft',
    },
    config = function ()
      require('config.nvim_cursor_ref').setup()
    end,
  },
}

