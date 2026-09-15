" GitHub PR browser backed by the standalone ghf script. Neovim has its own
" lazy Lua implementation.

if has('nvim')
  finish
endif

if exists('g:loaded_fzfgh')
  finish
endif

let g:loaded_fzfgh = 1
let s:expected_keys = 'enter,ctrl-d,ctrl-o,ctrl-s'
let s:supported_keys = {
      \ 'enter': 1,
      \ 'ctrl-d': 1,
      \ 'ctrl-o': 1,
      \ 'ctrl-s': 1,
      \ }

function! s:Notify(message, warning) abort
  execute 'echohl ' . (a:warning ? 'WarningMsg' : 'ErrorMsg')
  echom '[Fzfgh] ' . a:message
  echohl None
endfunction

function! s:ScriptCommand(name) abort
  if has('win32') || has('win64')
    let script = exepath(a:name . '.ps1')
    if !empty(script)
      let powershell = executable('pwsh') ? 'pwsh' : (executable('powershell') ? 'powershell' : '')
      if empty(powershell)
        call s:Notify('Cannot find pwsh or powershell on PATH', 0)
        return []
      endif
      return [powershell, '-NoLogo', '-NonInteractive', '-NoProfile',
            \ '-ExecutionPolicy', 'Bypass', '-File', script]
    endif
  endif

  let executable_path = exepath(a:name)
  if empty(executable_path)
    call s:Notify('Cannot find ' . a:name . ' on PATH', 0)
    return []
  endif
  return [executable_path]
endfunction

function! s:OpenPr(lines, key, pr, origin_win) abort
  if empty(a:lines)
    return
  endif
  if win_id2win(a:origin_win) != 0
    call win_gotoid(a:origin_win)
  endif

  botright vnew
  execute 'file ' . fnameescape('fzfgh://pr/' . a:pr . '/' . bufnr('%'))
  setlocal buftype=nofile bufhidden=wipe noswapfile fileformat=unix
  call setline(1, map(copy(a:lines), 'substitute(v:val, "\r", "", "g")'))
  let b:fzfgh_expected_key = a:key
  setlocal filetype=markdown
  setlocal nomodifiable readonly nomodified
endfunction

function! s:CollectOutput(state, stream, channel, message) abort
  call add(a:state[a:stream], a:message)
endfunction

function! s:FinishGh(state, timer) abort
  let info = job_info(a:state.job)
  let status = get(info, 'exitval', 0)
  if status != 0
    let message = trim(join(a:state.errors, "\n"))
    if empty(message)
      let message = trim(join(a:state.output, "\n"))
    endif
    call s:Notify(empty(message) ? 'gh command failed' : message, 0)
    return
  endif

  if a:state.action ==# 'view'
    if empty(a:state.output)
      call s:Notify('No details returned for PR #' . a:state.pr, 1)
      return
    endif
    call s:OpenPr(a:state.output, a:state.key, a:state.pr, a:state.origin_win)
  elseif a:state.action ==# 'checkout'
    echom '[Fzfgh] Checked out PR #' . a:state.pr
  endif
endfunction

function! s:GhClosed(state, channel) abort
  if get(a:state, 'done', 0)
    return
  endif
  let a:state.done = 1
  call timer_start(0, function('s:FinishGh', [a:state]))
endfunction

function! s:RunGh(cwd, arguments, action, key, pr, origin_win) abort
  let state = {
        \ 'action': a:action,
        \ 'done': 0,
        \ 'errors': [],
        \ 'key': a:key,
        \ 'origin_win': a:origin_win,
        \ 'output': [],
        \ 'pr': a:pr,
        \ }
  let options = {
        \ 'close_cb': function('s:GhClosed', [state]),
        \ 'cwd': a:cwd,
        \ 'err_cb': function('s:CollectOutput', [state, 'errors']),
        \ 'err_mode': 'nl',
        \ 'out_cb': function('s:CollectOutput', [state, 'output']),
        \ 'out_mode': 'nl',
        \ }
  let state.job = job_start(['gh'] + a:arguments, options)
  if job_status(state.job) ==# 'fail'
    call s:Notify('Could not start gh', 0)
  endif
endfunction

function! s:HandleSelection(cwd, origin_win, lines, status) abort
  let key = ''
  let pr = ''
  for line in a:lines
    let value = trim(substitute(line, '\r', '', 'g'))
    if has_key(s:supported_keys, value)
      let key = value
      let pr = ''
    elseif !empty(key) && value =~# '^#\?\d\+$'
      let pr = substitute(value, '^#', '', '')
      break
    endif
  endfor

  if empty(key) || empty(pr)
    if a:status != 0
      call s:Notify('ghf exited with status ' . a:status, 1)
    endif
    return
  endif

  if key ==# 'enter' || key ==# 'ctrl-d'
    call s:RunGh(a:cwd, ['pr', 'view', pr], 'view', key, pr, a:origin_win)
  elseif key ==# 'ctrl-o'
    call s:RunGh(a:cwd, ['pr', 'view', pr, '--web'], 'browser', key, pr, a:origin_win)
  elseif key ==# 'ctrl-s'
    call s:RunGh(a:cwd, ['pr', 'checkout', pr], 'checkout', key, pr, a:origin_win)
  endif
endfunction

" Open the standalone ghf selector in an editor terminal.
function! fzfgh#select_prs(fullscreen) abort
  let command = s:ScriptCommand('ghf')
  if empty(command)
    return
  endif
  call add(command, '-Display')

  let cwd = getcwd()
  let origin_win = win_getid()
  return terminal#run(command, {
        \ 'cwd': cwd,
        \ 'env': {'GHF_EXPECT': s:expected_keys},
        \ 'fullscreen': a:fullscreen,
        \ 'name': 'ghf',
        \ 'on_term_exit': function('s:HandleSelection', [cwd, origin_win]),
        \ })
endfunction
