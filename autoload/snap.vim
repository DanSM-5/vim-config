if exists('g:loaded_snap')
  finish
endif

let g:loaded_snap = 1

function! snap#snap(...) abort
  if !executable('codesnap')
    echoerr '[Snap] not executable CodeSnap'
  endif

  let line1 = get(a:, 1)
  let line2 = get(a:, 2)
  let all = get(a:, 3, 0)
  let file = (exists('a:4') && !empty(a:4)) ? get(a:, 4, '%') : '%'
  let output = (exists('a:5') && !empty(a:5)) ? get(a:, 5, 'clipboard') : 'clipboard'
  let output = (output != 'clipboard' && isdirectory(output)) ? output : 'clipboard' 

  if file == '%'
    " empty string if buffer is not a file
    let file = expand('%:p')
  else
    let file = fnamemodify(file, ':p')
  endif

  if isdirectory(file)
    return
  endif

  " We know that item is a file
  if filereadable(file)
    let command = [
          \ 'codesnap',
          \ '--from-file', file,
          \ '--output', output,
          \ '--has-line-number'
          \ ]

    if !all
      let command += ['--range', printf('%d:%d', line1, line2)]
    endif

    if has('nvim')
      call jobstart(command, { "on_exit": {-> execute('echomsg "[Snap] Snip completed"')} })
    else
      " Vim recommends to set the job to a script varialbe to avoid
      " getting the job GC before it completes
      let s:snap_job = job_start(command, { "exit_cb": {-> execute('echomsg "[Snap] Snip completed"')} })
    endif

    return
  endif


  " Case in which the current buffer is not an file

  " codesnap -c "console.log('foo')" --output clipboard -l javascript
  " echomsg { "line1": line1, "line2": line2, "file": file }

  " range is used for getting the code from the buffer
  let lines = all ? getline(1, '$') : getline(line1, line2)
  let code = join(lines, "\n")

  " also try '--from-clipboard' if new lines are an issue
  let command = [
        \ 'codesnap',
        \ '--from-code', code,
        \ '--output', output,
        \ '--has-line-number'
        \ ]


  if has('nvim')
    call jobstart(command, { "on_exit": {-> execute('echomsg "[Snap] Snip completed"')} })
  else
    " Vim recommends to set the job to a script varialbe to avoid
    " getting the job GC before it completes
    let s:snap_job = job_start(command, { "exit_cb": {-> execute('echomsg "[Snap] Snip completed"')} })
  endif
endfunction
