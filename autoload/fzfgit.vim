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
  let options = ['--preview-window', '60%,wrap-word', '--prompt', 'Branches> ', '--bind', 'start:reload:'.cmd]
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
    \   '--preview-window', '60%,wrap-word',
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
  let options = ['--preview-window', '70%,wrap-word', '--prompt', 'Tags> ', '--bind', 'start:reload:'.cmd, '--preview', preview]
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


" ### Git Compare Files

" Resolve the repository's default branch (e.g. 'origin/main').
" Uses origin/HEAD when available, falling back to a local main/master.
"
" Underlying shell commands:
"   git -C <dir> symbolic-ref --quiet refs/remotes/origin/HEAD
"   git -C <dir> rev-parse --verify --quiet <main|master>
function! s:default_branch(directory) abort
  let head = trim(system('git -C '.a:directory.' symbolic-ref --quiet refs/remotes/origin/HEAD'))
  if v:shell_error == 0 && !empty(head)
    " refs/remotes/origin/main -> origin/main
    return substitute(head, '^refs/remotes/', '', '')
  endif

  for branch in ['main', 'master']
    call system('git -C '.a:directory.' rev-parse --verify --quiet '.branch)
    if v:shell_error == 0
      return branch
    endif
  endfor

  return 'master'
endfunction

" Clipboard command that copies the fzf selection file ({+f}) verbatim,
" one path per line. Mirrors gitsearch's copy helper but keeps the whole
" line (filenames may contain spaces) instead of taking the first field.
"
" Underlying shell command (per platform):
"   windows : Get-Content {+f} | Set-Clipboard
"   *nix    : cat {+f} | <pbcopy|wl-copy|xsel|xclip>
function! s:compare_copy_cmd() abort
  if has('win32') || $OS ==? 'Windows_NT'
    return 'Get-Content {+f} | Set-Clipboard'
  elseif has('gui_mac') || substitute(system('uname'), '\n', '', '') ==? 'Darwin'
    return 'cat {+f} | pbcopy'
  elseif !empty($WAYLAND_DISPLAY) && executable('wl-copy')
    return 'cat {+f} | wl-copy --foreground --type text/plain'
  elseif !empty($DISPLAY) && executable('xsel')
    return 'cat {+f} | xsel -i -b'
  elseif !empty($DISPLAY) && executable('xclip')
    return 'cat {+f} | xclip -i -selection clipboard'
  endif

  return ''
endfunction

" Show the files changed between the current branch and a target branch
" (the repository's default branch when no target is given). Selecting one
" or more files opens their patches in a temporary 'git' buffer.
"
" Underlying shell commands (<base> = git merge-base HEAD <target>):
"   merge base : git -C <dir> merge-base HEAD <target>
"   source     : git -C <dir> diff --name-only <base>
"   preview    : git -C <dir> diff --color=always <base> -- {} | delta
"   sink       : git -C <dir> diff <base> -- <file>
"   ctrl-y     : <selected file paths> -> clipboard
function! fzfgit#compare_files(target, fullscreen) abort
  let Get_repo_ref = exists('*FugitiveWorkTree') ? function('FugitiveWorkTree') : function('utils#git_path')
  let directory = Get_repo_ref()

  if empty(directory)
    echohl WarningMsg | echomsg '[CompareFiles] Not in a git repository' | echohl None
    return
  endif

  " Resolve the target branch (default branch when none is given).
  " Strip a leading 'remotes/' that 'git branch -a' / completion may add;
  " 'origin/<branch>' refs are valid and passed straight to git.
  let target = trim(a:target)
  if empty(target)
    let target = s:default_branch(directory)
  endif
  let target = substitute(target, '^remotes/', '', '')

  " Resolve the merge base once so both the source and the preview reuse it.
  " Computing it here (instead of with a '$(...)' subshell) keeps the command
  " portable to powershell and avoids re-running it on every preview redraw.
  let merge_base = trim(system('git -C '.directory.' merge-base HEAD '.shellescape(target)))
  if v:shell_error != 0 || empty(merge_base)
    echohl WarningMsg | echomsg '[CompareFiles] Could not find merge base with '.target | echohl None
    return
  endif

  let cmd = 'git -C '.directory.' diff --name-only '.merge_base
  let preview = 'git -C '.directory.' diff --color=always '.merge_base.' -- {} %s'
  let preview = printf(preview, executable('delta') ? '| delta' : (executable('bat') ? '| bat -p --color=always' : ''))
  let copy_cmd = s:compare_copy_cmd()

  let options = [
    \   '--preview-window', '60%,wrap-word',
    \   '--prompt', 'Compare '.target.'> ',
    \   '--header', 'ctrl-y: Copy file paths',
    \   '--bind', 'start:reload:'.cmd,
    \   '--preview', preview]

  if !empty(copy_cmd)
    let options += ['--bind', 'ctrl-y:execute-silent('.copy_cmd.')+bell']
  endif

  " Always run fzf's child commands through powershell on windows (including
  " git bash), never bash. Detect windows via has('win32') / the $OS variable.
  if has('win32') || $OS ==? 'Windows_NT'
    let pwsh = executable('pwsh') ? 'pwsh' : 'powershell'
    let options += ['--with-shell', pwsh.' -NoLogo -NonInteractive -NoProfile -Command']
  endif

  let options += s:get_options([])

  function! s:compare_sink(list) closure
    if empty(a:list)
      return
    endif

    enew
    exec 'silent! file '.fnameescape('CompareFiles '.target)
    for file in a:list
      pu = system('git -C '.directory.' diff '.merge_base.' -- '.shellescape(file))
      pu = ''
    endfor
    silent call execute('normal ggdd')
    setlocal buftype=nofile bufhidden=wipe noswapfile
    setlocal nomodifiable readonly nomodified
    setlocal filetype=git
    setlocal foldmethod=syntax
  endfunction

  let spec = {
    \   'sinklist': function('s:compare_sink'),
    \   'options': options,
    \ }

  try
    call fzf#run(fzf#wrap('git_compare_files', spec, a:fullscreen))
  catch /.*/
    echoerr '[CompareFiles] Could not compare'
  endtry
endfunction

" Completion: list available branches (local and remote), filtered by the
" leading portion of the argument being typed. The 'origin/HEAD' symbolic
" ref is dropped as it is not a real branch.
"
" Underlying shell command:
"   git -C <dir> for-each-ref --format='%(refname:short)' refs/heads refs/remotes
function! fzfgit#compare_branch_complete(arglead, cmdline, cursorpos) abort
  let Get_repo_ref = exists('*FugitiveWorkTree') ? function('FugitiveWorkTree') : function('utils#git_path')
  let directory = Get_repo_ref()
  if empty(directory)
    return []
  endif

  let fmt = shellescape('%(refname:short)')
  let branches = systemlist('git -C '.directory.' for-each-ref --format='.fmt.' refs/heads refs/remotes')
  if v:shell_error != 0
    return []
  endif

  call filter(branches, 'v:val !~# "/HEAD$"')

  if !empty(a:arglead)
    call filter(branches, 'stridx(v:val, a:arglead) == 0')
  endif

  return sort(branches)
endfunction


" ### Git Compare Commits

" Clipboard command that copies the first whitespace field (the short hash)
" of every selected line in the fzf selection file ({+f}). A '{ ... }' block
" is left untouched by fzf's placeholder parser (only '{+f}' is expanded),
" same as gitsearch's awk-based copy helper.
"
" Underlying shell command (per platform):
"   windows : Get-Content {+f} | ForEach-Object { ($_ -split '\s+')[0] } | Set-Clipboard
"   *nix    : awk '{ print $1 }' {+f} | <pbcopy|wl-copy|xsel|xclip>
function! s:commits_copy_cmd() abort
  if has('win32') || $OS ==? 'Windows_NT'
    return 'Get-Content {+f} | ForEach-Object { ($_ -split ''\s+'')[0] } | Set-Clipboard'
  elseif has('gui_mac') || substitute(system('uname'), '\n', '', '') ==? 'Darwin'
    return 'awk ''{ print $1 }'' {+f} | pbcopy'
  elseif !empty($WAYLAND_DISPLAY) && executable('wl-copy')
    return 'awk ''{ print $1 }'' {+f} | wl-copy --foreground --type text/plain'
  elseif !empty($DISPLAY) && executable('xsel')
    return 'awk ''{ print $1 }'' {+f} | xsel -i -b'
  elseif !empty($DISPLAY) && executable('xclip')
    return 'awk ''{ print $1 }'' {+f} | xclip -i -selection clipboard'
  endif

  return ''
endfunction

" Show the commits on the current branch that are not on a target branch
" (the repository's default branch when no target is given), i.e. the commit
" stack 'git log <target>..HEAD'. Selecting one or more commits opens their
" patches in a temporary 'git' buffer.
"
" Underlying shell commands:
"   source  : git -C <dir> log <target>..HEAD --color=always \
"                  --format='%C(auto)%h%d %s %C(black)%C(bold)%cr %C(auto)%an'
"   preview : git -C <dir> show --color=always {1} | delta
"   sink    : git -C <dir> show <sha>
"   ctrl-y  : awk '{ print $1 }' {+f} -> clipboard   (first field = <sha>)
function! fzfgit#compare_commits(target, fullscreen) abort
  let Get_repo_ref = exists('*FugitiveWorkTree') ? function('FugitiveWorkTree') : function('utils#git_path')
  let directory = Get_repo_ref()

  if empty(directory)
    echohl WarningMsg | echomsg '[CompareCommits] Not in a git repository' | echohl None
    return
  endif

  " Resolve the target branch (default branch when none is given). Strip a
  " leading 'remotes/'; 'origin/<branch>' refs are passed straight to git.
  let target = trim(a:target)
  if empty(target)
    let target = s:default_branch(directory)
  endif
  let target = substitute(target, '^remotes/', '', '')

  " Rich, git-stack inspired log line. The short hash is always field {1}.
  let format = '%C(auto)%h%d %s %C(black)%C(bold)%cr %C(auto)%an'
  let preview = 'git -C '.directory.' show --color=always {1} %s'
  let preview = printf(preview, executable('delta') ? '| delta' : (executable('bat') ? '| bat -p --color=always' : ''))
  let copy_cmd = s:commits_copy_cmd()

  let options = [
    \   '--preview-window', '60%,wrap-word',
    \   '--no-sort',
    \   '--prompt', 'Commits '.target.'> ',
    \   '--header', 'ctrl-y: Copy sha',
    \   '--preview', preview]

  if !empty(copy_cmd)
    let options += ['--bind', 'ctrl-y:execute-silent('.copy_cmd.')+bell']
  endif

  " The rich --format string is too brittle to survive shell quoting, so on
  " windows it is written to a generated .ps1 and run with 'powershell -File'
  " (-ExecutionPolicy bypass to allow it). fzf's child processes always use
  " powershell on windows, even under git bash.
  let tmp_source = ''
  if has('win32') || $OS ==? 'Windows_NT'
    let tmp_source = tempname() . '.ps1'
    let source_script = [
      \   'try {',
      \   'git -C ''' . directory . ''' log ''' . target . '..HEAD'' --color=always --format=''' . format . '''',
      \   '} catch {',
      \   'Write-Error "Cannot list commits"',
      \   '}'
      \ ]
    call writefile(source_script, tmp_source)
    let pwsh = executable('pwsh') ? 'pwsh' : 'powershell'
    let cmd = pwsh . ' -NoLogo -NonInteractive -NoProfile -ExecutionPolicy bypass -File ' . tmp_source
    let options += ['--with-shell', pwsh . ' -NoLogo -NonInteractive -NoProfile -Command']
  else
    let cmd = 'git -C ' . directory . ' log ' . target . '..HEAD --color=always --format="' . format . '"'
  endif

  let options += ['--bind', 'start:reload:' . cmd]
  let options += s:get_options([])

  function! s:commits_sink(list) closure
    if empty(a:list)
      return
    endif

    enew
    exec 'silent! file ' . fnameescape('CompareCommits ' . target)
    for line in a:list
      let hash = split(line)[0]
      pu = system('git -C ' . directory . ' show ' . hash)
      pu = ''
    endfor
    silent call execute('normal ggdd')
    setlocal buftype=nofile bufhidden=wipe noswapfile
    setlocal nomodifiable readonly nomodified
    setlocal filetype=git
    setlocal foldmethod=syntax
  endfunction

  function! s:commits_exit(...) closure
    if !empty(tmp_source)
      silent call delete(tmp_source)
    endif
  endfunction

  let spec = {
    \   'sinklist': function('s:commits_sink'),
    \   'options': options,
    \   'exit': function('s:commits_exit'),
    \ }

  try
    call fzf#run(fzf#wrap('git_compare_commits', spec, a:fullscreen))
  catch /.*/
    echoerr '[CompareCommits] Could not compare'
  endtry
endfunction
