" Git history search backed by the standalone git-search-commits and
" git-file-history scripts. Neovim has its own lazy Lua implementation.

if has('nvim')
  finish
endif

if exists('g:loaded_git_search_commits')
  finish
endif

let g:loaded_git_search_commits = 1
let s:expected_keys = 'enter,ctrl-o,ctrl-e'
let s:supported_keys = {'enter': 1, 'ctrl-o': 1, 'ctrl-e': 1}

function! s:Notify(message, warning) abort
  execute 'echohl ' . (a:warning ? 'WarningMsg' : 'ErrorMsg')
  echom '[GitSearch] ' . a:message
  echohl None
endfunction

function! s:GitRoot(...) abort
  let seed = get(a:000, 0, '')
  if !empty(seed)
    let path = fnamemodify(expand(seed), ':p')
  else
    let path = expand('%:p')
  endif
  let directory = empty(path) ? getcwd() : (isdirectory(path) ? path : fnamemodify(path, ':h'))
  let output = systemlist('git -C ' . shellescape(directory) . ' rev-parse --show-toplevel')
  if v:shell_error != 0 || empty(output) || !isdirectory(output[0])
    call s:Notify('Not in a git repository', 1)
    return ''
  endif
  return substitute(output[0], '\r$', '', '')
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

function! s:RepositoryPath(root, path) abort
  let root = substitute(substitute(fnamemodify(a:root, ':p'), '\\', '/', 'g'), '/$', '', '')
  let absolute = substitute(fnamemodify(expand(a:path), ':p'), '\\', '/', 'g')
  let prefix = root . '/'
  let comparable_root = (has('win32') || has('win64')) ? tolower(prefix) : prefix
  let comparable_path = (has('win32') || has('win64')) ? tolower(absolute) : absolute
  if stridx(comparable_path, comparable_root) != 0
    call s:Notify('File is outside the repository: ' . a:path, 0)
    return ''
  endif
  return strpart(absolute, strlen(prefix))
endfunction

function! s:CurrentFile(root) abort
  let path = expand('%:p')
  return empty(path) ? '' : s:RepositoryPath(a:root, path)
endfunction

function! s:OpenCommits(lines, key, origin_win) abort
  if empty(a:lines)
    return
  endif
  if win_id2win(a:origin_win) != 0
    call win_gotoid(a:origin_win)
  endif
  if &modified && !&hidden
    new
  else
    enew
  endif

  execute 'file gitsearch://commits/' . bufnr('%')
  setlocal buftype=nofile bufhidden=wipe noswapfile
  call setline(1, a:lines)
  let b:gitsearch_expected_key = a:key
  setlocal filetype=git foldmethod=syntax
  setlocal nomodifiable readonly nomodified
endfunction

function! s:CollectOutput(state, stream, channel, message) abort
  call add(a:state[a:stream], a:message)
endfunction

function! s:FinishGitShow(state, timer) abort
  let info = job_info(a:state.job)
  let status = get(info, 'exitval', 0)
  if status != 0
    let message = trim(join(a:state.errors, "\n"))
    call s:Notify(empty(message) ? 'git show failed' : message, 0)
    return
  endif
  call s:OpenCommits(a:state.output, a:state.key, a:state.origin_win)
endfunction

function! s:GitShowClosed(state, channel) abort
  if get(a:state, 'done', 0)
    return
  endif
  let a:state.done = 1
  call timer_start(0, function('s:FinishGitShow', [a:state]))
endfunction

function! s:ShowCommits(root, hashes, key) abort
  let state = {
        \ 'done': 0,
        \ 'errors': [],
        \ 'key': a:key,
        \ 'origin_win': win_getid(),
        \ 'output': [],
        \ }
  let options = {
        \ 'close_cb': function('s:GitShowClosed', [state]),
        \ 'err_cb': function('s:CollectOutput', [state, 'errors']),
        \ 'err_mode': 'nl',
        \ 'out_cb': function('s:CollectOutput', [state, 'output']),
        \ 'out_mode': 'nl',
        \ }
  let state.job = job_start(['git', '-C', a:root, '--no-pager', 'show', '--no-color'] + a:hashes, options)
  if job_status(state.job) ==# 'fail'
    call s:Notify('Could not start git show', 0)
  endif
endfunction

function! s:HandleSelection(root, lines, status) abort
  let key = ''
  let hashes = []
  for line in a:lines
    let value = trim(line)
    if has_key(s:supported_keys, value)
      let key = value
      let hashes = []
    elseif !empty(key) && value =~# '^[0-9a-fA-F]\+$'
      call add(hashes, value)
    endif
  endfor

  if empty(key) || empty(hashes)
    if a:status != 0
      call s:Notify('Selector exited with status ' . a:status, 1)
    endif
    return
  endif

  " Enter preserves the original Vim integration, ctrl-o represents printed
  " patches, and ctrl-e edits those patches in the already-running editor.
  call s:ShowCommits(a:root, hashes, key)
endfunction

function! s:Run(script, root, arguments, fullscreen) abort
  let command = s:ScriptCommand(a:script)
  if empty(command)
    return
  endif
  call add(command, '-Display')
  call extend(command, a:arguments)

  let expect_name = a:script ==# 'git-search-commits' ? 'GSC_EXPECT' : 'GFH_EXPECT'
  let environment = {}
  let environment[expect_name] = s:expected_keys
  call terminal#run(command, {
        \ 'cwd': a:root,
        \ 'env': environment,
        \ 'fullscreen': a:fullscreen,
        \ 'name': a:script,
        \ 'on_term_exit': function('s:HandleSelection', [a:root]),
        \ })
endfunction

function! gitsearch#search(arguments, fullscreen) abort
  let root = s:GitRoot()
  if empty(root)
    return
  endif

  let arguments = copy(a:arguments)
  if len(arguments) == 1 && index(['%', '?'], arguments[0]) >= 0
    let path = s:CurrentFile(root)
    if empty(path)
      call s:Notify('The current buffer has no repository file', 1)
      return
    endif
    let arguments = ['-File', path]
  endif
  call s:Run('git-search-commits', root, arguments, a:fullscreen)
endfunction

function! gitsearch#file_history(arguments, fullscreen) abort
  let file = get(a:arguments, 0, '')
  let root = (empty(file) || index(['%', '?'], file) >= 0) ? s:GitRoot() : s:GitRoot(file)
  if empty(root)
    return
  endif

  let arguments = []
  if file ==# '?'
    " Let git-file-history run its own file selector.
  elseif !empty(file) && file !=# '%'
    let path = s:RepositoryPath(root, file)
    if empty(path)
      return
    endif
    let arguments = [path]
  else
    let path = s:CurrentFile(root)
    if !empty(path)
      let arguments = [path]
    elseif file ==# '%'
      call s:Notify('The current buffer has no repository file', 1)
      return
    endif
  endif
  call s:Run('git-file-history', root, arguments, a:fullscreen)
endfunction
