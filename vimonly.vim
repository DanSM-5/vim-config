" Equivalent of lua/nvimstart.lua for neovim
" This script loads vim only code

" Git gutter settings
" Navigation
nmap ]g <Plug>(GitGutterNextHunk)
nmap [g <Plug>(GitGutterPrevHunk)
nmap <space>nh <Plug>(GitGutterNextHunk)
nmap <space>nH <Plug>(GitGutterPrevHunk)
" Text Object
omap ih <Plug>(GitGutterTextObjectInnerPending)
omap ah <Plug>(GitGutterTextObjectOuterPending)
xmap ih <Plug>(GitGutterTextObjectInnerVisual)
xmap ah <Plug>(GitGutterTextObjectOuterVisual)
" Quickfix
command! Gqf GitGutterQuickFix | copen
" Change update time to reflect gitgutter changes
set updatetime=1000

" NOTE: Uncomment to enable gitgutter logs
" let g:gitgutter_log = 1

if executable('rg')
  let g:gitgutter_grep = 'rg'
endif

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

