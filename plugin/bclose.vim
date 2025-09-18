if exists('g:loaded_bclose')
  finish
endif

let g:loaded_bclose = 1


" Renamed Kwbd command to BCloseCurrent
command! BCloseCurrent call bda#kwbd(1)
command! -bang -bar BCloseOthers call bda#bdo(<bang>0)
command! -bang -bar BCloseAllBuffers call bda#bda(<bang>0)
command! Bd call bda#kwbd(1)
command! -bang -bar Bdo call bda#bdo(<bang>0)
command! -bang -bar Bda call bda#bda(<bang>0)

nnoremap <silent> <Plug>BCloseCurrent :<C-u>BCloseCurrent<CR>
nnoremap <silent> <Plug>BCloseOthers :<C-u>BCloseOthers<CR>
nnoremap <silent> <Plug>BCloseAllBuffers :<C-u>BCloseAllBuffers<CR>

