" Ref: https://github.com/alexandermckay/bda
" Original credits
" Plugin: BDA - Buffer Delete All 
" Description: Reset the buffer list whilst preserving your layout
" Author: Alexander McKay
" Version: 1.0.0

function bda#CreateNoNameBuffer() 
  enew
endfunction    

function bda#GetNoNameBufferNumber()
  call bda#CreateNoNameBuffer()
  return bufnr('%')
endfunction

function bda#SwitchWindowsToBuffer(target_buffer_number)
  for winnr in range(1, winnr('$'))
    execute winnr . 'wincmd w'
    execute 'buffer' a:target_buffer_number
  endfor
endfunction

function bda#DeleteOtherNamedBuffers(exclude_buffer_number)
  for buf in getbufinfo({'buflisted': 1})
    if buf.bufnr != a:exclude_buffer_number
      execute 'bdelete' buf.bufnr
    endif
  endfor
endfunction

function! bda#bda(...)
  let preserve_windows = exists('a:1') ? a:1 : 0
  if preserve_windows
    let no_name_buffer_number = bda#GetNoNameBufferNumber()
    call bda#SwitchWindowsToBuffer(no_name_buffer_number)
    call bda#DeleteOtherNamedBuffers(no_name_buffer_number)
    return
  endif

  " Just close everything, windows included
  execute ':%bd'
endfunction

function! bda#bdo(...) abort
  let preserve_windows = exists('a:1') ? a:1 : 0
  if !preserve_windows
    execute ':%bd|e#|bn|bd'
    return
  endif

  let current_file = expand('%:p')
  " let current_buff = bufnr('%')
  call bda#bda(preserve_windows)
  " let no_name_buffer_number = bda#GetNoNameBufferNumber()
  " if !clear_windows
  "   call bda#SwitchWindowsToBuffer(no_name_buffer_number)
  "   " redraw!
  " endif
  " call bda#DeleteOtherNamedBuffers(current_buff)

  " NOTE: TSContext breaks without the sleep
  " redraw is added just to nicely show a change on screen
  redraw!
  sleep 1
  execute 'edit '.current_file
endfunction

" TODO: Use shorter names?
" command! -bang -bar Bda call bda#bda(<bang>0)
" cabbrev bda Bda

