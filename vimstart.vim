
" vim:fileencoding=utf-8:foldmethod=marker:foldenable

" Change location of shada
" with nvim profile in terminal
if has('nvim')
  set shada+='1000,n$HOME/.cache/vim-config/main.shada
endif

" Make nocompatible explisit
set nocompatible
" Default encoding
set encoding=UTF-8
set t_Co=256
set cursorline
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

" enable filetype base indentation
filetype plugin indent on
" Enable highlight on search
set hlsearch

" NOTE: Set by VimPlug
" enable syntax highlight
" > syntax enabled

" Set backspace normal behavior
set backspace=indent,eol,start
" Set hidden on
set hidden

": Global variables {{{ :-------------------------------------------------

" Most global variables defined in this file should be place here unless
" it is needed to be defined upon confiditional logic

" Theme variables --
" Normal mode styles
let g:theme_normal = ''
" Visual mode styles
let g:theme_visual = ''
" Normal mode styles of unfocused windows
let g:theme_normalNC = ''
" Styles for the numbers line
let g:theme_lineNr = ''
" Styles for the numbers line under cursor
let g:theme_cursorLineNr = ''
" Styles for the cursor line
let g:theme_cursorLine = ''
" Styles for the line left to LineNr
let g:theme_signColumn = ''
" Styles for color of comments
let g:theme_comment = 'hi Comment guifg=#7f848e cterm=NONE'
" Replacements --
let g:theme_hidden_normal = 'hi Normal guibg=NONE ctermbg=NONE'
" let g:theme_hidden_visual = 'hi Visual guibg=#414858'
let g:theme_hidden_visual = 'hi Visual guibg=#39496e'
let g:theme_hidden_normalNC = ':'
let g:theme_hidden_lineNr = 'hi LineNr guibg=NONE'
let g:theme_hidden_cursorLineNr = ':'
let g:theme_hidden_cursorLine = ':'
let g:theme_hidden_signColumn = ''
let g:theme_hidden_comment = ':'

" Enable detection
let g:host_os = config#CurrentOS()

" Vim Buffet icons
let g:buffet_powerline_separators = 1
let g:buffet_tab_icon = "\uf00a"
let g:buffet_left_trunc_icon = "\uf0a8"
let g:buffet_right_trunc_icon = "\uf0a9"
" Only hide quickfix buffers. Can be found with :ls!
let g:buffet_hidden_buffers = ['quickfix']

" Camel case motion keybindings
let g:camelcasemotion_key = '<leader>'
" Vim-Asterisk keep cursor position under current letter with
let g:asterisk#keeppos = 1
" Disable vim-smoothie remaps
let g:smoothie_no_default_mappings = 1
" Airline configs
let g:airline_theme = 'onehalfdark'
let g:airline_powerline_fonts = 1
" One dark color config
" let g:onedark_termcolors = 256

" Disable signs limit for gitgutter
let g:gitgutter_max_signs = -1
" Use custom grep
" let g:gitgutter_grep = 'rg'

": }}} :------------------------------------------------------------------

" Setting up config setup
" Config before runs on startup
" Config after run on VimEnter
call config#before()

": Global functions {{{ :-------------------------------------------------
func! g:ToggleBg ()
  let highlight_value = execute('hi Normal')
  " let ctermbg_value = matchstr(highlight_value, 'ctermbg=\zs\S*')
  let guibg_value = matchstr(highlight_value, 'guibg=\zs\S*')

  if guibg_value ==? ''
    silent execute('hi ' . g:theme_normal)
    silent execute('hi ' . g:theme_visual)
    silent execute('hi ' . g:theme_normalNC)
    silent execute('hi ' . g:theme_lineNr)
    silent execute('hi ' . g:theme_cursorLineNr)
    silent execute('hi ' . g:theme_cursorLine)
    " silent execute('hi ' . g:theme_signColumn)
  else
    silent execute(g:theme_hidden_normal)
    silent execute(g:theme_hidden_visual)
    silent execute(g:theme_hidden_normalNC)
    silent execute(g:theme_hidden_lineNr)
    silent execute(g:theme_hidden_cursorLineNr)
    silent execute(g:theme_hidden_cursorLine)
    " silent execute(g:theme_hidden_signColumn)
  endif
endfunction

function g:SetTab (space)
  let space = empty(a:space) ? '2' : a:space
  exec 'set tabstop=' . space . ' softtabstop=' . space . ' shiftwidth=' . space
  set expandtab
  set ruler
  set autoindent smartindent
endfunction

" Note: Make sure the function is defined before `vim-buffet` is loaded.
function! g:BuffetSetCustomColors()
  " NOTE: This functions runs before VimEnter, so cannot take values
  " from g:theme_normal

  " let bg_val = substitute(g:theme_normal, 'Normal', '', '')
  " silent execute('hi! BuffetCurrentBuffer cterm=NONE ' . bg_val)
  hi! BuffetCurrentBuffer cterm=NONE ctermbg=236 ctermfg=188 guibg=#282c34 guifg=#dcdfe4
  " hi! BuffetActiveBuffer ctermfg=2 ctermbg=10 guifg=#00ff00 guibg=#999999
  " hi! BuffetActiveBuffer ctermfg=2 ctermbg=10 guifg=#98c379 guibg=#999999
  hi! BuffetActiveBuffer ctermfg=2 ctermbg=10 guifg=#5d677a guibg=#999999

  hi! BuffetTab ctermfg=8 ctermbg=4 guifg=#000000 guibg=#258bd3

  " Other groups
  " BuffetBuffer
  " BuffetModCurrentBuffer
  " BuffetModActiveBuffer
  " BuffetModBuffer
  " BuffetTrunc
endfunction

function! g:OnVimEnter()
  " Capture styles before calling ToggleBg
  let g:theme_normal = substitute(trim(execute("hi Normal")), 'xxx', '', 'g')
  let g:theme_visual = substitute(trim(execute("hi Visual")), 'xxx', '', 'g')
  let g:theme_normalNC = substitute(trim(execute("hi NormalNC")), 'xxx', '', 'g')
  let g:theme_lineNr = substitute(trim(execute("hi LineNr")), 'xxx', '', 'g')
  let g:theme_cursorLineNr = substitute(trim(execute("hi CursorLineNr")), 'xxx', '', 'g')
  let g:theme_cursorLine = substitute(trim(execute("hi CursorLine")), 'xxx', '', 'g')
  " let g:theme_signColumn = substitute(trim(execute("hi SingColumn")), 'xxx', '', 'g')
  " Set comments color
  hi Comment guifg=#7f848e cterm=NONE gui=NONE

  " Make background transparen
  ToggleBg
  " Set tab to 2 paces
  SetTab

  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
    PlugInstall --sync | q
  endif

  " Call config after on vim enter
  call config#after()

  " Single line version of above
  " autocmd VimEnter *
  "   \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  "   \|   PlugInstall --sync | q
  "   \| endif
  "   \| call config#after()

  " Update colors for vim buffet
  call g:BuffetSetCustomColors()
endfunction

": }}} :------------------------------------------------------------------

autocmd VimEnter * call g:OnVimEnter()

" let g:vscode_loaded = 1
" VSCode extension

": Plugings {{{ :-------------------------------------------------

" Automatically install VimPlug from within (n)vim
" let data_dir = has('nvim') ? stdpath('data') : '~/.vim'
" if empty(glob(data_dir . '/autoload/plug.vim'))
"   silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
"   " autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
" endif

function! s:plug_help_sink(line)
  let dir = g:plugs[a:line].dir
  for pat in ['doc/*.txt', 'README.md']
    let match = get(split(globpath(dir, pat), "\n"), 0, '')
    if len(match)
      execute 'tabedit' match
      return
    endif
  endfor
  tabnew
  execute 'Explore' dir
endfunction

command! -nargs=? PlugHelp call fzf#run(fzf#wrap({
  \ 'source': sort(keys(g:plugs)),
  \ 'options': ['--query', <q-args>],
  \ 'sink':   function('s:plug_help_sink')}))

call plug#begin()
  " List your plugins here
  " Plug 'tpope/vim-sensible'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-repeat'
  Plug 'inkarkat/vim-ReplaceWithRegister'
  Plug 'christoomey/vim-sort-motion'
  Plug 'DanSM-5/vim-system-copy'
  Plug 'junegunn/fzf'
  Plug 'junegunn/fzf.vim'
  Plug 'mg979/vim-visual-multi'
  Plug 'dyng/ctrlsf.vim'
  Plug 'kreskij/Repeatable.vim'
  Plug 'bkad/CamelCaseMotion'
  Plug 'haya14busa/vim-asterisk'
  Plug 'lambdalisue/vim-suda'
  Plug 'psliwka/vim-smoothie'
  Plug 'rbong/vim-flog'

  " Color scheme
  " NOTE: Preserve order!
  Plug 'sonph/onehalf', { 'rtp': 'vim' }
  Plug 'vim-airline/vim-airline'
  Plug 'ryanoasis/vim-devicons'
  Plug 'bagrat/vim-buffet'

  if has('nvim')
    " LSP plugings for neovim
    Plug 'nvim-lua/plenary.nvim'
    Plug 'neovim/nvim-lspconfig'
    Plug 'williamboman/mason.nvim'
    Plug 'williamboman/mason-lspconfig.nvim'
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'hrsh7th/nvim-cmp'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'L3MON4D3/LuaSnip'
    Plug 'roginfarrer/cmp-css-variables'
    Plug 'nvim-treesitter/nvim-treesitter-textobjects'
    Plug 'numToStr/Comment.nvim'
    Plug 'JoosepAlviste/nvim-ts-context-commentstring'
    Plug 'DanSM-5/fzf-lsp.nvim'
    Plug 'lewis6991/gitsigns.nvim'
    Plug 'xiyaowong/nvim-cursorword'
    Plug 'nvimtools/none-ls.nvim'

    " File explorer
    Plug 'stevearc/oil.nvim'

    " TODO: Should we add NeoTree? It needs nvim-web-devicons
    " Plug 'nvim-neo-tree/neo-tree.nvim'
    " Plug 'nvim-tree/nvim-web-devicons'
    " Plug 'MunifTanjim/nui.nvim'

    " Debugger protocol
    " Plug 'mfussenegger/nvim-dap'
    " Plug 'nvim-neotest/nvim-nio'
    " Plug 'rcarriga/nvim-dap-ui'

    " Plugins to consider
    " Plug 'lukas-reineke/indent-blankline.nvim'

    " Copied from example
    " Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'v3.x'}
  else
    " Only load in vim

    " Comments plugin
    Plug 'tpope/vim-commentary'
    " File explorer
    Plug 'tpope/vim-vinegar'
    " Git signs on the left
    " NOTE: Currently there is an issue in vim for windows
    " which requires an extra shellescape. Use forked version
    " with additional patch to workaround the issue.
    " Ref: https://github.com/airblade/vim-gitgutter/issues/896
    if g:is_windows
      Plug 'DanSM-5/vim-gitgutter'
    else
      Plug 'airblade/vim-gitgutter'
    endif

    " Show matching words under the cursor
    Plug 'itchyny/vim-cursorword'

    " For lsp within vim
    " Plug 'prabirshrestha/vim-lsp'
    " Plug 'mattn/vim-lsp-settings'
  endif
call plug#end()


": }}} :----------------------------------------------------------

" Color schemes should be loaded after plug#end call
" colorscheme onehalfdark
silent! colorscheme onehalfdark
" Ensure theme exists for vim and nvim
hi NormalNC guifg=#abb2bf

if has('nvim')
  " Entry poing for lua config for nvim
  runtime lua/nvimstart.lua
else
  runtime vimonly.vim
endif

" Return to last edit position when opening files
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"zz" |
     \ endif

