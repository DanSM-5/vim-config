" Functions for git

" Show list of commits that affect a fiven line or range of lines
" Requires fugitive
function! gitutils#gitlog(...) abort
  let line_start = get(a:, 1, line('.'))
  let line_end = string(get(a:, 2, '+1'))
  let bang = get(a:, 3, 0)
  let git_args = get(a:, 4, '')
  " Get file name for git
  " It could be parsed without a system call but easier to let
  " git handle it as it will accept even windows format
  " let absolute_path = expand('%:p')
  " let file = trim(system(printf('git ls-files --full-name %s', fnameescape(absolute_path))))
  let file = expand('%:p')

  let command_fmt = 'Git%s log --oneline --decorate --no-patch -L %d,%s:%s %s'
  let command = printf(
        \ command_fmt,
        \ bang ? '!' : '',
        \ line_start,
        \ line_end,
        \ file,
        \ git_args,
        \ )
  execute command
endfunction

" Blame the line under the cursor
" Limited to 5 commits in history, override with last argument
function! gitutils#blame(...) abort
  " get(a:, 1) returns empty string instead of default
  let commit_count = (exists('a:1') && !empty(a:1)) ? a:1 : '5'
  let root = utils#find_root('.git')
  let line = string(line('.'))
  let file = expand('%:p')
  let name = expand('%:t')
  if !filereadable(file)
    return
  endif

  " Command
  " git -C ./repo log -L <start>,<end>:file
  let command_fmt = 'git -C %s log -n %s -u -L %s,+1:%s'
  let command = printf(
        \ command_fmt,
        \ shellescape(root),
        \ commit_count,
        \ line,
        \ shellescape(file)
        \)
  echomsg command
  let blame_out = system(command)
  if empty(blame_out)
    return
  endif
  let buff_name = 'Blame ' . name

  " Display blame on buffer
  enew
  exec 'silent! file ' . buff_name
  pu = blame_out
  pu = ''
  silent call execute('normal ggdd')
  setlocal nomod readonly
  setlocal filetype=git
  setlocal foldmethod=syntax
endfunction
