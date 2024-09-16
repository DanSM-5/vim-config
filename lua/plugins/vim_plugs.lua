return {
  -- built-in in neovim 0.10
  -- {
  --   'tpope/vim-commentary'
  -- },
  -- Using lua version
  -- {
  --   'tpope/vim-surround'
  -- },
  {
    'tpope/vim-fugitive'
  },
  {
    'tpope/vim-repeat'
  },
  {
    'inkarkat/vim-ReplaceWithRegister'
  },
  {
    'christoomey/vim-sort-motion'
  },
  {
    'DanSM-5/vim-system-copy'
  },
  {
    'junegunn/fzf'
  },
  {
    'junegunn/fzf.vim'
  },
  {
    'mg979/vim-visual-multi'
  },
  {
    'dyng/ctrlsf.vim'
  },
  {
    'kreskij/Repeatable.vim'
  },
  {
    'bkad/CamelCaseMotion'
  },
  {
    'haya14busa/vim-asterisk'
  },
  {
    'lambdalisue/vim-suda'
  },
  {
    'psliwka/vim-smoothie'
  },
  -- {
  --   'airblade/vim-gitgutter'
  -- },
  {
    'xiyaowong/nvim-cursorword',
    config = function ()
      -- NOTE: consider to keep or remove the background color and just keep the underline
      vim.cmd('hi CursorWord gui=underline cterm=underline guibg=#4b5263')
    end
  },
  {
    "rbong/vim-flog",
    lazy = true,
    cmd = { "Flog", "Flogsplit", "Floggit" },
    dependencies = {
      "tpope/vim-fugitive",
    },
  },
  {
    'stevearc/oil.nvim',
    config = require('config.oil_nvim').setup,
  },
}
