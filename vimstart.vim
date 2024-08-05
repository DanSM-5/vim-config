
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

" TODO: Remove later
set runtimepath^=~/projects/vim-config


" Global variables
let g:bg_value = ''
" Enable detection
let g:host_os = config#CurrentOS()
" Setting up config setup
" Config before runs on startup
" Config after run on VimEnter
call config#before()

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

" Background
command! ToggleBg call g:ToggleBg()
nnoremap <silent><leader>tb :ToggleBg<CR>

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

let g:buffet_powerline_separators = 1
let g:buffet_tab_icon = "\uf00a"
let g:buffet_left_trunc_icon = "\uf0a8"
let g:buffet_right_trunc_icon = "\uf0a9"


function! g:OnVimEnter()
  let g:bg_value = substitute(trim(execute("hi Normal")), 'xxx', '', 'g')
  ToggleBg
  SetTab

  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
    PlugInstall --sync | q
  endif

  call config#after()

  call g:BuffetSetCustomColors()
endfunction

autocmd VimEnter * call g:OnVimEnter()

" let g:vscode_loaded = 1
" VSCode extension

" Useful keybindings
" Replace word under the cursor with content of register 0
" nmap <leader>v ciw<C-r>0<ESC>

" Camel case motion keybindings
let g:camelcasemotion_key = '<leader>'
" Vim-Asterisk keep cursor position under current letter with
let g:asterisk#keeppos = 1

""Ctrl+Shift+Up/Down to move up and down
" nmap <silent><C-S-Down> :m .+1<CR>==
" nmap <silent><C-S-Up> :m .-2<CR>==
" imap <silent><C-S-Down> <Esc>:m .+1<CR>==gi
" imap <silent><C-S-Up> <Esc>:m .-2<CR>==gi
" vmap <silent><C-S-Down> :m '>+1<CR>gv=gv
" vmap <silent><C-S-Up> :m '<-2<CR>gv=gv

" ]<End> or ]<Home> move current line to the end or the begin of current buffer
nnoremap <silent>]<End> ddGp``
nnoremap <silent>]<Home> ddggP``
vnoremap <silent>]<End> dGp``
vnoremap <silent>]<Home> dggP``

" Select blocks after indenting
xnoremap < <gv
xnoremap > >gv|

" Use tab for indenting in visual mode
xnoremap <Tab> >gv|
xnoremap <S-Tab> <gv
nnoremap > >>_
nnoremap < <<_

" smart up and down
nmap <silent><DOWN> gj
nmap <silent><UP> gk
" nnoremap <expr> k (v:count == 0 ? 'gk' : 'k')
" nnoremap <expr> j (v:count == 0 ? 'gj' : 'j')

" Fast saving
nnoremap <C-s> :<C-u>w<CR>
vnoremap <C-s> :<C-u>w<CR>
cnoremap <C-s> <C-u>w<CR>

" System copy maps
" source ~/vim-config/utils/system-copy-maps.vim

"" move selected lines up one line
"xnoremap <A-Up> :m-2<CR>gv=gv
"" move selected lines down one line
"xnoremap <A-Down> :m'>+<CR>gv=gv
"" move current line up one line
"noremap <A-Up> :<C-u>m-2<CR>==
"" move current line down one line
"nnoremap <A-Down> :<C-u>m+<CR>==
"" move current line up in insert mode
"inoremap <A-Up> <Esc>:m .-2<CR>==gi
"" move current line down in insert mode
"inoremap <A-Down> <Esc>:m .+1<CR>==gi

" Toggle scrolloff
nnoremap <Leader>zz :let &scrolloff=999-&scrolloff<CR>

" Disable vim-smoothie remaps
g:smoothie_no_default_mappings = 1
" VimSmoothie remap
vnoremap <S-down> <cmd>call smoothie#do("\<C-D>")<CR>
nnoremap <S-down> <cmd>call smoothie#do("\<C-D>")<CR>
vnoremap <S-up> <cmd>call smoothie#do("\<C-U>")<CR>
nnoremap <S-up> <cmd>call smoothie#do("\<C-U>")<CR>
vnoremap zz <Cmd>call smoothie#do("zz")<CR>
nnoremap zz <Cmd>call smoothie#do("zz")<CR>

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

" Set after VimPlug



" Automatically install plugins on startup
" autocmd VimEnter *
"   \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
"   \|   PlugInstall --sync | q
"   \| endif
"   \| call config#after()
" Load config after plugins are available
" autocmd VimEnter * call config#after()


" Color schemes should be loaded after plug#end call
" syntax on
set t_Co=256
set cursorline
" colorscheme onehalfdark
silent! colorscheme onehalfdark
let g:airline_theme = 'onehalfdark'
let g:airline_powerline_fonts = 1

if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

" " Load plugins
" set runtimepath^=~/.cache/vimfiles/repos/github.com/DanSM-5/vim-system-copy
" set runtimepath^=~/.config/vscode-nvim/plugins/vim-repeat
" set runtimepath^=~/.cache/vimfiles/repos/github.com/bkad/CamelCaseMotion
" set runtimepath^=~/.cache/vimfiles/repos/github.com/tpope/vim-surround
" " set runtimepath^=~/.cache/vimfiles/repos/github.com/christoomey/vim-sort-motion
" set runtimepath^=~/.cache/vimfiles/repos/github.com/kreskij/Repeatable.vim
" set runtimepath^=~/.cache/vimfiles/repos/github.com/haya14busa/vim-asterisk
" set runtimepath^=~/.config/vscode-nvim/plugins/vim-smoothie

" source ~/.cache/vimfiles/repos/github.com/DanSM-5/vim-system-copy/plugin/system_copy.vim
" source ~/.cache/vimfiles/repos/github.com/bkad/CamelCaseMotion/plugin/camelcasemotion.vim
" source ~/.cache/vimfiles/repos/github.com/tpope/vim-surround/plugin/surround.vim
" " source ~/.cache/vimfiles/repos/github.com/christoomey/vim-sort-motion/sort_motion.vim
" source ~/.cache/vimfiles/repos/github.com/kreskij/Repeatable.vim/plugin/repeatable.vim
" source ~/.cache/vimfiles/repos/github.com/haya14busa/vim-asterisk/plugin/asterisk.vim
" source ~/.config/vscode-nvim/plugins/vim-smoothie/plugin/smoothie.vim

" Move line up/down
" Require repeatable.vim
" Repeatable nnoremap mlu :<C-U>m-2<CR>==
" Repeatable nnoremap mld :<C-U>m+<CR>==

" Load utility clipboard functions
" Rsource utils/clipboard.vim
runtime utils/clipboard.vim
" source ~/vim-config/utils/clipboard.vim

" Map clipboard functions
xnoremap <silent> <Leader>y :<C-u>call clipboard#yank()<cr>
nnoremap <expr> <Leader>p clipboard#paste('p')
nnoremap <expr> <Leader>P clipboard#paste('P')
xnoremap <expr> <Leader>p clipboard#paste('p')
xnoremap <expr> <Leader>P clipboard#paste('P')

if $IS_WINSHELL == 'true'
  " Windows specific
  set shell=cmd
  set shellcmdflag=/c

  " Set system_copy variables
  let g:system_copy#paste_command = 'pbpaste.exe'
  let g:system_copy#copy_command = 'pbcopy.exe'
elseif $IS_FROM_CONTAINER == 'true'
  " Set system_copy variables
  let g:system_copy#paste_command = 'fs-paste'
  let g:system_copy#copy_command = 'fs-copy'
  call clipboard#set(g:system_copy#copy_command, g:system_copy#paste_command)
elseif has('wsl') && $IS_WSL1 == 'true'
  " Set system_copy variables
  let g:system_copy#paste_command = 'pbpaste.exe'
  let g:system_copy#copy_command = 'pbcopy.exe'
elseif !empty($DISPLAY) && executable('xsel')
  let g:system_copy#copy_command = 'xsel -i -b'
  let g:system_copy#paste_command = 'xsel -o -b'
elseif !empty($DISPLAY) && executable('xclip')
  let g:system_copy#copy_command = 'xclip -i -selection clipboard'
  let g:system_copy#paste_command = 'xclip -o -selection clipboard'
elseif !empty($WAYLAND_DISPLAY) && executable('wl-copy') && executable('wl-paste')
  let g:system_copy#copy_command = 'wl-copy --foreground --type text/plain'
  let g:system_copy#paste_command = 'wl-paste --no-newline'
elseif has('mac')
  " Set system_copy variables
  let g:system_copy#paste_command = 'pbpaste'
  let g:system_copy#copy_command = 'pbcopy'
elseif executable('pbcopy.exe')
  let g:system_copy#paste_command = 'pbpaste.exe'
  let g:system_copy#copy_command = 'pbcopy.exe'
endif

" Set relative numbers
set number relativenumber

" Prevent open dialog
" let g:system_copy_silent = 1

" Clean trailing whitespace in file
" nnoremap <silent> <Leader>c :%s/\s\+$//e<cr>
" Clean carriage returns '^M'
" nnoremap <silent> <Leader>r :%s/\r$//g<cr>
" Quick buffer overview an completion to change
" nnoremap gb :ls<CR>:b<Space>
" Move between buffers with tab
" nnoremap <silent> <tab> :bn<cr>
" nnoremap <silent> <s-tab> :bN<cr>

" Wipe current buffer
noremap <Leader><Tab> <cmd>Bw<CR>
" Wipe all buffers but current
noremap <Leader><S-Tab> <cmd>Bonly<CR>
" noremap <Leader><S-Tab> :Bw!<CR>
" noremap <C-t> :tabnew split<CR>

" vim-asterisk
" map *   <Plug>(asterisk-*)
" map #   <Plug>(asterisk-#)
" map g*  <Plug>(asterisk-g*)
" map g#  <Plug>(asterisk-g#)
" map z*  <Plug>(asterisk-z*)
" map gz* <Plug>(asterisk-gz*)
" map z#  <Plug>(asterisk-z#)
" map gz# <Plug>(asterisk-gz#)

if has('nvim')
  " Entry poing for lua config for nvim
  runtime lua/init.lua
endif

" Return to last edit position when opening files
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"zz" |
     \ endif


