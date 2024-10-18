" Keybindings for help

" Jump to subject
nnoremap <buffer> <CR> <C-]>
" Go back from last jump
nnoremap <buffer> <BS> <C-T>
" Next option
nnoremap <buffer> o /'\l\{2,\}'<CR>
" Previous option
nnoremap <buffer> O ?'\l\{2,\}'<CR>
" Next subject
nnoremap <buffer> s /\|\zs\S\+\ze\|<CR>
" Previous subject
nnoremap <buffer> S ?\|\zs\S\+\ze\|<CR>

" Helper bindings for quickfix
" nnoremap <S-F1>  :cc<CR>
" nnoremap <F2>    :cnext<CR>
" nnoremap <S-F2>  :cprev<CR>
" nnoremap <F3>    :cnfile<CR>
" nnoremap <S-F3>  :cpfile<CR>
" nnoremap <F4>    :cfirst<CR>
" nnoremap <S-F4>  :clast<CR>

