if exists('g:loaded_fzfgit')
  finish
endif

let g:loaded_fzfgit = 1
let s:is_windows = has('win32') || has('win32unix') || has('win64')
let s:is_gitbash = 0
if s:is_windows && ($MSYSTEM =~? 'MINGW' || $MSYSTEM =~? 'MSYS') && ($OSTYPE == 'msys')
  let s:is_gitbash = 1
endif


" Common functionality

function! s:get_options(opts) abort
  let opts = type(a:opts) == v:t_list ? a:opts : []

  " Common options managed by fzf_bind_options
  let common = exists('g:fzf_bind_options') ? g:fzf_bind_options : [
    \     '--cycle', '--multi',
    \     '--ansi', '--input-border',
    \     '--bind', 'alt-c:clear-query',
    \     '--bind', 'ctrl-l:change-preview-window(down|hidden|)',
    \     '--bind', 'ctrl-/:change-preview-window(down|hidden|)',
    \     '--bind', 'alt-up:preview-page-up,alt-down:preview-page-down',
    \     '--bind', 'shift-up:preview-up,shift-down:preview-down',
    \     '--bind', 'ctrl-^:toggle-preview',
    \     '--bind', 'ctrl-s:toggle-sort',
    \     '--bind', 'alt-f:first',
    \     '--bind', 'alt-l:last',
    \     '--bind', 'alt-a:select-all',
    \     '--bind', 'alt-d:deselect-all'
    \ ]

  return common + opts
endfunction

" Run a callback in an specific directory
function! s:sink_on_dir(directory, FuncRef, list) abort
  let cwd = getcwd()
  try
    exec 'cd '.a:directory
    call a:FuncRef(a:list)
  finally
    exec 'cd '.cwd
  endtry
endfunction


" ### Git Branches

function! fzfgit#select_branch(opts) abort
  let opts = get(a:opts, 'options', [])
  let name = get(a:opts, 'name', 'git_select_branch')
  let Callback = get(a:opts, 'callback', { -> join([]) }) " if missing NOOP
  let fullscreen = get(a:opts, 'fullscreen', 0)
  let Get_repo_ref = exists('*FugitiveWorkTree') ? function('FugitiveWorkTree') : function('utils#git_path')
  let directory = get(a:opts, 'directory', Get_repo_ref())

  let cmd = 'git -C '.directory.' branch -a --color=always | sort'
  let preview = ''
  let options = ['--preview-window', '60%,wrap', '--prompt', 'Branches> ', '--bind', 'start:reload:'.cmd]
  let tmp_preview = ''

  if s:is_windows
    let tmp_preview = tempname()
    let tmp_preview .= '.ps1' " only ps1 files are executable
    let preview_script = [
      \   'try {',
      \   '$line = @"',
      \   '$args',
      \   '"@',
      \   '$line = $line.Trim("*").Trim().Trim("'."'".'").Trim('."'".'"'."')",
      \   "$line = ($line -split ' ')[0]",
      \   'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $line',
      \   '} catch {',
      \   'Write-Error "Cannot preview"',
      \   '}'
      \ ]
    call writefile(preview_script, tmp_preview)
    let preview = tmp_preview . ' {}'
    let pwsh = executable('pwsh') ? 'pwsh' : 'powershell'
    call extend(options, ['--with-shell', pwsh . ' -NoLogo -NonInteractive -NoProfile -Command', '--preview', preview])
  else
    let preview = 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) || echo "Cannot preview"'
    call extend(options, ['--preview', preview])
  endif

  function! s:sink_branches(list) closure
    let clean_list = []
    for selected in a:list
      call add(clean_list, split(selected[2:])[0])
    endfor
    let cwd = getcwd()

    try
      exec 'cd '.directory
      call Callback(clean_list)
    finally
      exec 'cd '.cwd
    endtry
  endfunction

  function! s:exit_branches(...) closure
    if !empty(tmp_preview)
      silent call delete(tmp_preview)
    endif
  endfunction

  let options += s:get_options(opts)

  let spec = {
    \   'sinklist': function('s:sink_branches'),
    \   'options': options,
    \   'exit': function('s:exit_branches')
    \ }

  try
    call fzf#run(fzf#wrap(name, spec, fullscreen))
  catch /.*/
    echoerr '[Branches] Could not select'
    call Callback([])
  endtry
endfunction

function! s:checkout_sink(list) abort
  if empty(a:list)
    return
  endif

  let selected = a:list[0]
  let selected = substitute(selected, 'remotes/', '', '')
  call system('git checkout '.selected)
endfunction

function! fzfgit#checkout(fullscreen) abort
  call fzfgit#select_branch({
    \   'name': 'git_checkout',
    \   'options': ['--no-multi'],
    \   'callback': function('s:checkout_sink'),
    \   'fullscreen': a:fullscreen,
    \ })
endfunction


" ### Git Stashes

function! fzfgit#select_stash(opts) abort
  let opts = get(a:opts, 'options', [])
  let name = get(a:opts, 'name', 'git_select_stash')
  let Callback = get(a:opts, 'callback', { -> join([]) }) " if missing NOOP
  let fullscreen = get(a:opts, 'fullscreen', 0)
  let Get_repo_ref = exists('*FugitiveWorkTree') ? function('FugitiveWorkTree') : function('utils#git_path')
  let directory = get(a:opts, 'directory', Get_repo_ref())

  let cmd = 'git -C '.directory.' stash list'
  let preview = 'git show --color=always {1} %s | bat -p --color=always'
  let preview = printf(preview, executable('delta') ? '| delta' : '')
  let options = [
    \   '--preview-window', '60%,wrap',
    \   '--prompt', 'Stashes> ',
    \   '--delimiter', ':',
    \   '--accept-nth', '1',
    \   '--bind', 'start:reload:'.cmd,
    \   '--preview', preview]
  let options += s:get_options(opts)

  let spec = {
    \   'sinklist': function('s:sink_on_dir', [directory, { ls -> Callback(ls) }]),
    \   'options': options,
    \ }

  try
    call fzf#run(fzf#wrap(name, spec, fullscreen))
  catch /.*/
    echoerr '[Stashes] Could not select'
    call Callback([])
  endtry
endfunction

function! s:apply_stash_sink(list) abort
  if empty(a:list)
    return
  endif

  let selected = a:list[0]
  call system('git stash apply '.selected)
endfunction

function! fzfgit#stashes(fullscreen) abort
  call fzfgit#select_stash({
    \   'name': 'apply_stash',
    \   'options': ['--no-multi'],
    \   'callback': function('s:apply_stash_sink'),
    \   'fullscreen': a:fullscreen,
    \ })
endfunction


" ### Git Tags

function! fzfgit#select_tag(opts) abort
  let opts = get(a:opts, 'options', [])
  let name = get(a:opts, 'name', 'git_select_tag')
  let Callback = get(a:opts, 'callback', { -> join([]) }) " if missing NOOP
  let fullscreen = get(a:opts, 'fullscreen', 0)
  let Get_repo_ref = exists('*FugitiveWorkTree') ? function('FugitiveWorkTree') : function('utils#git_path')
  let directory = get(a:opts, 'directory', Get_repo_ref())

  let cmd = 'git -C '.directory.' tag --sort -version:refname'
  let preview = 'git show --color=always {} %s | bat -p --color=always'
  let preview = printf(preview, executable('delta') ? '| delta' : '')
  let options = ['--preview-window', '70%,wrap', '--prompt', 'Tags> ', '--bind', 'start:reload:'.cmd, '--preview', preview]
  let options += s:get_options(opts)

  let spec = {
    \   'sinklist': function('s:sink_on_dir', [directory, { ls -> Callback(ls) }]),
    \   'options': options,
    \ }

  try
    call fzf#run(fzf#wrap(name, spec, fullscreen))
  catch /.*/
    echoerr '[Tags] Could not select'
    call Callback([])
  endtry
endfunction

function! s:checkout_tag(list) abort
  if empty(a:list)
    return
  endif

  let selected = a:list[0]
  call system('git checkout '.selected)
endfunction

function! fzfgit#tags(fullscreen) abort
  call fzfgit#select_tag({
    \   'name': 'checkout_tag',
    \   'options': ['--no-multi'],
    \   'callback': function('s:checkout_tag'),
    \   'fullscreen': a:fullscreen,
    \ })
endfunction
