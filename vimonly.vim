" Equivalent of lua/nvimstart.lua for neovim
" This script loads vim only code

" Set workable mouse scroll
" For selecting text hold shift while selecting text
" or set mouse=r and then select text in command mode (:)
" NOTE: This prevents right click paste.
" use ctrl+shift+v, <leader>p or zp/zP
set mouse=a

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

if g:is_windows
  let g:gitgutter_grep = ''

  " NOTE:
  " Vim from scoop is compiled with lua
  " but lua binary from scoop is not in the path (shimmed)
  " The alternative is to set &luadll manually
  " Check if exists and add it. This will cause `has('lua')` to return 1.
  let lua_dll_dir = expand('~/scoop/apps/lua/current/bin')
  if isdirectory(lua_dll_dir)
    let &luadll = lua_dll_dir . '\lua54.dll'
  endif
else
  let g:gitgutter_grp = 'rg'
endif

