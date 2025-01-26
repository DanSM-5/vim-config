Buffer navigation
===========

## Move using ctrl

Move using ctrl maps without affecting windows like fzf

```vim
nnoremap <C-h> <C-W>h
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
nnoremap <C-l> <C-W>l

if has('nvim')
  augroup vimrc_term
    autocmd!
    autocmd WinEnter term://* nohlsearch
    autocmd WinEnter term://* startinsert

    autocmd TermOpen * tnoremap <buffer> <C-h> <C-\><C-n><C-w>h
    autocmd TermOpen * tnoremap <buffer> <C-j> <C-\><C-n><C-w>j
    autocmd TermOpen * tnoremap <buffer> <C-k> <C-\><C-n><C-w>k
    autocmd TermOpen * tnoremap <buffer> <C-l> <C-\><C-n><C-w>l
    autocmd TermOpen * tnoremap <buffer> <Esc> <C-\><C-n>
  augroup END
endif

" using https://github.com/junegunn/fzf.vim & fzf installed.
augroup vimrc_term_fzf 
  autocmd!
  " Do some other stuff independent of nvim.
  if has('nvim')
    autocmd FileType fzf tunmap <buffer> <Esc>
    autocmd FileType fzf tunmap <buffer> <C-h>
    autocmd FileType fzf tunmap <buffer> <C-j>
    autocmd FileType fzf tunmap <buffer> <C-k>
    autocmd FileType fzf tunmap <buffer> <C-l>
  endif
augroup END
```

