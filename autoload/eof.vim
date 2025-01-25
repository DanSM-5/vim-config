
if exists('g:loaded_eol')
  finish
endif

let g:loaded_eol = 1

function! eol#unix() abort
  silent set ff=unix
endfunction

function! eol#dos() abort
  silent set ff=dos
endfunction

