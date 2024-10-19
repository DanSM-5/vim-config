
if exists('g:loaded_jump_conflict')
  finish
endif

let g:loaded_jump_conflict = 1

function! s:Context(reverse) abort
  call search('^\(@@ .* @@\|[<=>|]\{7}[<=>|]\@!\)', a:reverse ? 'bW' : 'W')
endfunction

function! s:ContextMotion(reverse) abort
  if a:reverse
    -
  endif
  call search('^@@ .* @@\|^diff \|^[<=>|]\{7}[<=>|]\@!', 'bWc')
  if getline('.') =~# '^diff '
    let end = search('^diff ', 'Wn') - 1
    if end < 0
      let end = line('$')
    endif
  elseif getline('.') =~# '^@@ '
    let end = search('^@@ .* @@\|^diff ', 'Wn') - 1
    if end < 0
      let end = line('$')
    endif
  elseif getline('.') =~# '^=\{7\}'
    +
    let end = search('^>\{7}>\@!', 'Wnc')
  elseif getline('.') =~# '^[<=>|]\{7\}'
    let end = search('^[<=>|]\{7}[<=>|]\@!', 'Wn') - 1
  else
    return
  endif
  if end > line('.')
    execute 'normal! V'.(end - line('.')).'j'
  elseif end == line('.')
    normal! V
  endif
endfunction

" If needed to access in lua `vim.cmd.JumpconflictContextPrevious()`
" command! JumpconflictContextPrevious call <SID>Context(1)
" command! JumpconflictContextNext     call <SID>Context(0)
" command! JumpconflictContextPrevious exe 'normal! gv'<Bar>call <SID>Context(1)
" command! JumpconflictContextNext     exe 'normal! gv'<Bar>call <SID>Context(0)
" command! JumpconflictContextPrevious call <SID>ContextMotion(1)
" command! JumpconflictContextNext     call <SID>ContextMotion(0)

nnoremap <silent> <Plug>(jumpconflict-context-previous) :<C-U>call <SID>Context(1)<CR>
nnoremap <silent> <Plug>(jumpconflict-context-next)     :<C-U>call <SID>Context(0)<CR>
vnoremap <silent> <Plug>(jumpconflict-context-previous) :<C-U>exe 'normal! gv'<Bar>call <SID>Context(1)<CR>
vnoremap <silent> <Plug>(jumpconflict-context-next)     :<C-U>exe 'normal! gv'<Bar>call <SID>Context(0)<CR>
onoremap <silent> <Plug>(jumpconflict-context-previous) :<C-U>call <SID>ContextMotion(1)<CR>
onoremap <silent> <Plug>(jumpconflict-context-next)     :<C-U>call <SID>ContextMotion(0)<CR>

nnoremap <silent> <Plug>JumpconflictContextPrevious :<C-U>call <SID>Context(1)<CR>
nnoremap <silent> <Plug>JumpconflictContextNext     :<C-U>call <SID>Context(0)<CR>
xnoremap <silent> <Plug>JumpconflictContextPrevious :<C-U>exe 'normal! gv'<Bar>call <SID>Context(1)<CR>
xnoremap <silent> <Plug>JumpconflictContextNext     :<C-U>exe 'normal! gv'<Bar>call <SID>Context(0)<CR>
onoremap <silent> <Plug>JumpconflictContextPrevious :<C-U>call <SID>ContextMotion(1)<CR>
onoremap <silent> <Plug>JumpconflictContextNext     :<C-U>call <SID>ContextMotion(0)<CR>

