" Equivalent of lua/nvimstart.lua for neovim
" This script loads vim only code

" Git gutter settings
" Navigation
nmap <space>nh <Plug>(GitGutterNextHunk)
nmap <space>nH <Plug>(GitGutterPrevHunk)
nmap ]c <Plug>(GitGutterNextHunk)
nmap [c <Plug>(GitGutterPrevHunk)
" Text Object
omap ih <Plug>(GitGutterTextObjectInnerPending)
omap ah <Plug>(GitGutterTextObjectOuterPending)
xmap ih <Plug>(GitGutterTextObjectInnerVisual)
xmap ah <Plug>(GitGutterTextObjectOuterVisual)
" Actions
nnoremap <leader>hr <Plug>(GitGutterUndoHunk)
" Quickfix
function s:Gqf(bang) abort
  if a:bang
    GitGutterQuickFixCurrentFile | copen
  else
    GitGutterQuickFix | copen
  endif
endfunction

command! -bang -bar Gqf call s:Gqf(<bang>0)
" Change update time to reflect gitgutter changes
set updatetime=1000

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


