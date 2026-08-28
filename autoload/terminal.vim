" Small native Vim terminal wrapper.
"
" terminal#run() opens a command in a vertical split, or in a new tab when
" 'fullscreen' is set. If 'on_term_exit' is provided, it receives the final
" rendered terminal lines and exit status after the terminal window closes.

if exists('g:loaded_terminal_wrapper')
  finish
endif

let g:loaded_terminal_wrapper = 1

function! s:Finish(state, timer) abort
  if get(a:state, 'buf', 0) > 0 && bufexists(a:state.buf)
    " Process output that may still be queued when exit_cb fires.
    silent! call term_wait(a:state.buf, 100)
    let lines = getbufline(a:state.buf, 1, '$')
  else
    let lines = []
  endif

  if win_id2win(a:state.terminal_win) != 0
    call win_gotoid(a:state.terminal_win)
    silent! close!
  endif
  if get(a:state, 'buf', 0) > 0 && bufexists(a:state.buf)
    silent! execute 'bwipeout! ' . a:state.buf
  endif

  if win_id2win(a:state.origin_win) != 0
    call win_gotoid(a:state.origin_win)
  endif
  call call(a:state.callback, [lines, a:state.status])
endfunction

function! s:OnExit(state, job, status) abort
  let a:state.status = a:status
  call timer_start(10, function('s:Finish', [a:state]))
endfunction

" Run a command in a native Vim terminal.
"
" Supported options:
" - cwd: working directory
" - env: environment variables merged into the child environment
" - fullscreen: open in a new tab instead of a vertical split
" - name: terminal buffer name
" - on_term_exit: callback(lines, status)
function! terminal#run(command, options) abort
  if !has('terminal')
    echohl ErrorMsg
    echom '[Terminal] This Vim does not include terminal support'
    echohl None
    return 0
  endif

  let fullscreen = get(a:options, 'fullscreen', 0)
  let origin_win = win_getid()
  if fullscreen
    tabnew
  else
    botright vertical new
  endif

  let term_options = {
        \ 'curwin': 1,
        \ 'norestore': 1,
        \ 'term_kill': 'kill',
        \ }

  let cwd = get(a:options, 'cwd', '')
  if !empty(cwd)
    let term_options.cwd = cwd
  endif

  let env = get(a:options, 'env', {})
  if !empty(env)
    let term_options.env = env
  endif

  let name = get(a:options, 'name', '')
  if !empty(name)
    let term_options.term_name = name
  endif

  let Callback = get(a:options, 'on_term_exit', v:null)
  let state = {
        \ 'buf': 0,
        \ 'callback': Callback,
        \ 'origin_win': origin_win,
        \ 'status': 0,
        \ 'terminal_win': win_getid(),
        \ }
  if type(Callback) == v:t_func
    let term_options.exit_cb = function('s:OnExit', [state])
  else
    let term_options.term_finish = 'close'
  endif

  let state.buf = term_start(a:command, term_options)
  if state.buf == 0
    if fullscreen
      tabclose!
    else
      close!
    endif
    echohl ErrorMsg
    echom '[Terminal] Could not open terminal command'
    echohl None
    return 0
  endif

  call setbufvar(state.buf, '&bufhidden', 'wipe')
  startinsert
  return state.buf
endfunction
