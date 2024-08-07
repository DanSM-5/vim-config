
" vim:fileencoding=utf-8:foldmethod=marker

" Change location of shada
" with nvim profile in terminal
if has('nvim')
  set shada+='1000,n$HOME/.cache/vim-config/main.shada
endif

" Make nocompatible explisit
set nocompatible

" Default encoding
set encoding=UTF-8

": Global variables {{{ :-------------------------------------------------

" Most global variables defined in this file should be place here unless
" it is needed to be defined upon confiditional logic

" Store the value of the background in Normal mode
let g:bg_value = ''
" Enable detection
let g:host_os = config#CurrentOS()

" Vim Buffet icons
let g:buffet_powerline_separators = 1
let g:buffet_tab_icon = "\uf00a"
let g:buffet_left_trunc_icon = "\uf0a8"
let g:buffet_right_trunc_icon = "\uf0a9"

" Camel case motion keybindings
let g:camelcasemotion_key = '<leader>'
" Vim-Asterisk keep cursor position under current letter with
let g:asterisk#keeppos = 1
" Disable vim-smoothie remaps
let g:smoothie_no_default_mappings = 1
" Airline configs
let g:airline_theme = 'onehalfdark'
let g:airline_powerline_fonts = 1

": }}} :------------------------------------------------------------------

" Setting up config setup
" Config before runs on startup
" Config after run on VimEnter
call config#before()

": Global functions {{{ :-------------------------------------------------
func! g:ToggleBg ()
  let highlight_value = execute('hi Normal')
  let ctermbg_value = matchstr(highlight_value, 'ctermbg=\zs\S*')
  let guibg_value = matchstr(highlight_value, 'guibg=\zs\S*')

  if ctermbg_value == '' && guibg_value ==? ''
    silent execute('hi ' . g:bg_value)
  else
    silent execute('hi Normal guibg=NONE ctermbg=NONE')
  endif
endfunction

function g:SetTab ()
  set tabstop=2 softtabstop=2 shiftwidth=2
  set expandtab
  set ruler
  set autoindent smartindent
  filetype plugin indent on
endfunction

" Note: Make sure the function is defined before `vim-buffet` is loaded.
function! g:BuffetSetCustomColors()
  " NOTE: This functions runs before VimEnter, so cannot take values
  " from g:bg_value

  " let bg_val = substitute(g:bg_value, 'Normal', '', '')
  " silent execute('hi! BuffetCurrentBuffer cterm=NONE ' . bg_val)
  hi! BuffetCurrentBuffer cterm=NONE ctermbg=236 ctermfg=188 guibg=#282c34 guifg=#dcdfe4
  " hi! BuffetActiveBuffer ctermfg=2 ctermbg=10 guifg=#00ff00 guibg=#999999
  " hi! BuffetActiveBuffer ctermfg=2 ctermbg=10 guifg=#98c379 guibg=#999999
  hi! BuffetActiveBuffer ctermfg=2 ctermbg=10 guifg=#5d677a guibg=#999999
endfunction

function! g:OnVimEnter()
  " Get background settings of normal mode
  let g:bg_value = substitute(trim(execute("hi Normal")), 'xxx', '', 'g')
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
  Plug 'tpope/vim-commentary'
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
  Plug 'airblade/vim-gitgutter'

  " Color scheme
  " NOTE: Preserve order!
  Plug 'sonph/onehalf', { 'rtp': 'vim' }
  Plug 'vim-airline/vim-airline'
  Plug 'ryanoasis/vim-devicons'
  Plug 'bagrat/vim-buffet'


  if has('nvim')
    " LSP plugings for neovim
    Plug 'neovim/nvim-lspconfig'
    Plug 'williamboman/mason.nvim'
    Plug 'williamboman/mason-lspconfig.nvim'
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

    Plug 'DanSM-5/fzf-lsp.nvim'
    Plug 'nvim-lua/plenary.nvim'

    " Debugger protocol
    " Plug 'mfussenegger/nvim-dap'
    " Plug 'nvim-neotest/nvim-nio'
    " Plug 'rcarriga/nvim-dap-ui'

    " Plugins to consider
    " Plug 'lukas-reineke/indent-blankline.nvim'

    " Copied from example
    " Plug 'hrsh7th/nvim-cmp'
    " Plug 'hrsh7th/cmp-nvim-lsp'
    " Plug 'L3MON4D3/LuaSnip'
    " Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'v3.x'}
  " else
  "   Plug 'prabirshrestha/vim-lsp'
  endif
call plug#end()


": }}} :----------------------------------------------------------

" Color schemes should be loaded after plug#end call
" syntax on
set t_Co=256
set cursorline
" colorscheme onehalfdark
silent! colorscheme onehalfdark
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

" TODO: Remove if no issues with clipboard
" if $IS_WINSHELL == 'true'
"   " Windows specific
"   set shell=cmd
"   set shellcmdflag=/c

"   " Set system_copy variables
"   let g:system_copy#paste_command = 'pbpaste.exe'
"   let g:system_copy#copy_command = 'pbcopy.exe'
" elseif $IS_FROM_CONTAINER == 'true'
"   " Set system_copy variables
"   let g:system_copy#paste_command = 'fs-paste'
"   let g:system_copy#copy_command = 'fs-copy'
"   call clipboard#set(g:system_copy#copy_command, g:system_copy#paste_command)
" elseif has('wsl') && $IS_WSL1 == 'true'
"   " Set system_copy variables
"   let g:system_copy#paste_command = 'pbpaste.exe'
"   let g:system_copy#copy_command = 'pbcopy.exe'
" elseif !empty($DISPLAY) && executable('xsel')
"   let g:system_copy#copy_command = 'xsel -i -b'
"   let g:system_copy#paste_command = 'xsel -o -b'
" elseif !empty($DISPLAY) && executable('xclip')
"   let g:system_copy#copy_command = 'xclip -i -selection clipboard'
"   let g:system_copy#paste_command = 'xclip -o -selection clipboard'
" elseif !empty($WAYLAND_DISPLAY) && executable('wl-copy') && executable('wl-paste')
"   let g:system_copy#copy_command = 'wl-copy --foreground --type text/plain'
"   let g:system_copy#paste_command = 'wl-paste --no-newline'
" elseif has('mac')
"   " Set system_copy variables
"   let g:system_copy#paste_command = 'pbpaste'
"   let g:system_copy#copy_command = 'pbcopy'
" elseif executable('pbcopy.exe')
"   let g:system_copy#paste_command = 'pbpaste.exe'
"   let g:system_copy#copy_command = 'pbcopy.exe'
" endif

if has('nvim')
  " Entry poing for lua config for nvim
  runtime lua/init.lua
endif

" Return to last edit position when opening files
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"zz" |
     \ endif

