" Equivalent of lua/nvimstart.lua for neovim
" This script loads vim only code

let g:gitgutter_sign_added = '✚'
" let g:gitgutter_sign_modified = '✹'
let g:gitgutter_sign_modified = '󰜥'
let g:gitgutter_sign_removed = '✘'
let g:gitgutter_sign_removed_first_line = ''
let g:gitgutter_sign_removed_above_and_below = ''
let g:gitgutter_sign_modified_removed   = '󱣳'

" Defaults:
" let g:gitgutter_sign_added              = '+'
" let g:gitgutter_sign_modified           = '~'
" let g:gitgutter_sign_removed            = '_'
" let g:gitgutter_sign_removed_first_line = '‾'
" let g:gitgutter_sign_removed_above_and_below = '_¯'
" let g:gitgutter_sign_modified_removed   = '~_'

" Git gutter settings
" Navigation
nmap ]c <Plug>(GitGutterNextHunk)
nmap [c <Plug>(GitGutterPrevHunk)
" Text Object
omap ih <Plug>(GitGutterTextObjectInnerPending)
omap ah <Plug>(GitGutterTextObjectOuterPending)
xmap ih <Plug>(GitGutterTextObjectInnerVisual)
xmap ah <Plug>(GitGutterTextObjectOuterVisual)
" Actions
nnoremap <leader>hr <Plug>(GitGutterUndoHunk)
nnoremap <leader>hR <cmd>Git checkout -- %<cr>
nnoremap <leader>hU <cmd>Git reset -- %<cr>
nnoremap <leader>hS <cmd>Git add -- %<cr>
" `<leader>hs` is already implemented by gitgutter
" and `<leader>hu` (unstage) is not possible. It defaults
" to GitGutterUndoHunk same as `<leader>hr`

" Quickfix
function s:Gqf(bang) abort
  if a:bang
    GitGutterQuickFixCurrentFile | copen
  else
    GitGutterQuickFix | copen
  endif
endfunction

command! -bang -bar Gqf call s:Gqf(<bang>0)

" NOTE: Uncomment to enable gitgutter logs
" let g:gitgutter_log = 1

if executable('rg')
  let g:gitgutter_grep = 'rg'
endif

" Quickfix movement
nnoremap ]q <cmd>silent! cnext<cr>
nnoremap [q <cmd>silent! cprev<cr>

function! s:VimConfig() abort
  " Remap vinegar to <leader>-
  if hasmapto('<Plug>VinegarUp')
    nunmap -
    nmap <leader>- <Plug>VinegarUp
  endif

  " runtime utils/vimsuggest_config.vim
endfunction

autocmd VimEnter * call s:VimConfig()

" Remap vinegar to <leader>-
" autocmd VimEnter *
"     \  if hasmapto('<Plug>VinegarUp')
"     \|   nunmap -
"     \|   nmap <leader>- <Plug>VinegarUp
"     \| endif

if g:is_windows
  " NOTE:
  " Vim from scoop is compiled with lua
  " but lua binary from scoop is not in the path (shimmed)
  " The alternative is to set &luadll manually
  " Check if exists and add it. This will cause `has('lua')` to return 1.
  let lua_dll_dir = expand('~/scoop/apps/lua/current/bin')
  if isdirectory(lua_dll_dir)
    let &luadll = lua_dll_dir . '\lua54.dll'

    " use embedded lua for `:Flog`
    let g:flog_use_internal_lua = 1
  endif
else
  if has('lua')
    " If vim is compiled with lua, use that one
    let g:flog_use_internal_lua = 1
  endif
endif

" Set wildmenu completions
set wildmenu
set wildmode=list:longest,full

" clear search highlight
nnoremap <silent> <c-l> :<c-u>nohlsearch<cr>

" augroup CursorColorOnRecord
"   autocmd!
"   autocmd RecordingEnter * silent execute('hi Cursor guifg=#282c34 guibg=#16e81e') 
"   autocmd!
"   autocmd RecordingLeave * silent execute('hi ' . g:theme_cursor) 
" augroup END

" Change , and ; behavior
" Ref: https://www.reddit.com/r/vim/comments/43j5jr/comment/cziloc7
" function! s:InitConsistentRepeat(command)
"     if a:command =~# '[FT]'
"         noremap ; ,
"         noremap , ;
"     else
"         silent! unmap ;
"         silent! unmap ,
"     endif
"     return a:command
" endfunction

" noremap <expr> f <SID>InitConsistentRepeat('f')
" noremap <expr> t <SID>InitConsistentRepeat('t')
" noremap <expr> F <SID>InitConsistentRepeat('F')
" noremap <expr> T <SID>InitConsistentRepeat('T')


" Ref: https://www.reddit.com/r/vim/comments/3gpqjs/comment/cu0abeh
if exists('*getcharsearch')
  NXOnoremap <expr>; getcharsearch().forward ? ';' : ','
  NXOnoremap <expr>, getcharsearch().forward ? ',' : ';'
else
  " ~~Will probably implement, but it's not simple considering multi-bytes, etc.~~
  " It turns out doable. TODO: support Input Method
  "
  " command! -nargs=1 NOnoremap nnoremap <args><Bar> onoremap <args>
  " I use the mark `z`(as well the register `z`) exclusively in scripts.
  " NOnoremap <silent>F :<C-u>execute 'silent! normal! mzf'.nr2char(getchar()).'g`z'.v:count1.','<CR>
  " xnoremap <silent>F :<C-u>execute 'silent! normal! mzf'.nr2char(getchar()).'g`zgv'.v:count1.','<CR>
  " NOnoremap <silent>T :<C-u>execute 'silent! normal! mzt'.nr2char(getchar()).'g`z'.v:count1.','<CR>
  " xnoremap <silent>T :<C-u>execute 'silent! normal! mzt'.nr2char(getchar()).'g`zgv'.v:count1.','<CR>

  " Change , and ; behavior
  " Ref: https://www.reddit.com/r/vim/comments/43j5jr/comment/cziloc7
  function! s:InitConsistentRepeat(command)
      if a:command =~# '[FT]'
          noremap ; ,
          noremap , ;
      else
          silent! unmap ;
          silent! unmap ,
      endif
      return a:command
  endfunction

  noremap <expr> f <SID>InitConsistentRepeat('f')
  noremap <expr> t <SID>InitConsistentRepeat('t')
  noremap <expr> F <SID>InitConsistentRepeat('F')
  noremap <expr> T <SID>InitConsistentRepeat('T')
endif


func! s:SetCtrlSF () abort
  " Plugin help
  " :h CtrlSF

  " In CtrlSF window:
  "
  " Enter, o, double-click - Open corresponding file of current line in the window which CtrlSF is launched from.
  " <C-O> - Like Enter but open file in a horizontal split window.
  " t - Like Enter but open file in a new tab.
  " p - Like Enter but open file in a preview window.
  " P - Like Enter but open file in a preview window and switch focus to it.
  " O - Like Enter but always leave CtrlSF window opening.
  " T - Like t but focus CtrlSF window instead of new opened tab.
  " M - Switch result window between normal view and compact view.
  " q - Quit CtrlSF window.
  " <C-J> - Move cursor to next match.
  " <C-N> - Move cursor to next file's first match.
  " <C-K> - Move cursor to previous match.
  " <C-P> - Move cursor to previous file's first match.
  " <C-C> - Stop a background searching process.
  " <C-T> - (If you have fzf installed) Use fzf for faster navigation. In the fzf window, use <Enter> to focus specific match and <C-O> to open matched file.

  " let g:ctrlsf_toggle_map_key = '\t'
  " Highligth matching line in file and preview window
  let g:ctrlsf_selected_line_hl = 'op'
  let g:ctrlsf_default_root = 'cwd'
  let g:ctrlsf_backend = 'rg'
  let g:ctrlsf_extra_backend_args = {
      \ 'rg': '--hidden --glob "!plugged" --glob "!.git" --glob "!node_modules"'
      \ }
  let g:ctrlsf_ignore_dir = ['.git', 'node_modules', 'plugged']

  let g:ctrlsf_mapping = {
    \ "open"    : ["<CR>", "o"],
    \ "openb"   : { 'key': "O", 'suffix': "<C-w>p" },
    \ "split"   : "<C-O>",
    \ "vsplit"  : "<C-I>",
    \ "tab"     : "t",
    \ "tabb"    : "T",
    \ "popen"   : "p",
    \ "popenf"  : "P",
    \ "quit"    : "q",
    \ "next"    : "<C-J>",
    \ "prev"    : "<C-K>",
    \ "nfile"   : "<C-L>",
    \ "pfile"   : "<C-H>",
    \ "pquit"   : "q",
    \ "loclist" : "<C-Q>",
    \ "chgmode" : "M",
    \ "stop"    : "<C-C>",
    \ }

    " nfile   : "<C-D>",
    " pfile   : "<C-U>",

  nmap     <C-s>f <Plug>CtrlSFCwordPrompt
  nmap     <C-s>w <Plug>CtrlSFCwordExec
  vmap     <C-s>w <Plug>CtrlSFVwordExec
  nmap     <C-s>s <Plug>CtrlSFPwordExec
  nnoremap <C-s>o <cmd>CtrlSFOpen<CR>
  nnoremap <C-s><C-s> <cmd>CtrlSFToggle<CR>
endf


