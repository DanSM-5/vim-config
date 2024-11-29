if exists('g:loaded_git_search_commits')
  finish
endif

let g:loaded_git_search_commits = 1

function! s:GitPath () abort
  " Directory holding the current file
  let file_dir = trim(expand('%:p:h'))

  let gitcmd = 'cd '.shellescape(file_dir).' && git rev-parse --show-toplevel'
  if g:is_windows && !has('nvim')
    " WARN: Weird behavior started to occur in which vim in windows
    " requires an additional shellescape to run when command has parenthesis
    " or when it has quotations
    let gitcmd = shellescape(gitcmd)
  endif
  let gitpath = trim(system(gitcmd))

  return gitpath
endfunction

function! s:OpenTempGitCommit(commits) abort
  if len(a:commits) == 0
    return
  else
    enew
    exec 'file Commits'
    for commit in a:commits
      let hash = split(commit)[0]
      pu = system('git show ' . hash)
      pu = ''
    endfor
    silent call execute('normal ggdd')
    setlocal nomod readonly
    setlocal filetype=git
    setlocal foldmethod=syntax
  endif
endfunction

function s:GetCopyCmd() abort
  let os = substitute(system('uname'), '\n', '', '')

  if has('gui_win32') || has('win32')
    " NOTE: Manually point to the location of the helper script
    " Or return the specific command to copy
    let gitsearch_copy = substitute($USERPROFILE, '\\', '/', 'g') . (has('nvim') ? '/AppData/Local/nvim' : '/vimfiles') . '/utils/gitsearch_copy.ps1'
    return 'powershell -NoLogo -NonInteractive -NoProfile -File ' . shellescape(gitsearch_copy) . ' "{+f}"'
  elseif has("gui_mac") || os ==? 'Darwin'
    return "cat {+f} | awk '{ print $1 }' | pbcopy"
  elseif !empty($WAYLAND_DISPLAY) && executable('wl-copy')
    return "cat {+f} | awk '{ print $1 }' | wl-copy --foreground --type text/plain"                             
  elseif !empty($DISPLAY) && executable('xsel')                                     
    return "cat {+f} | awk '{ print $1 }' | xsel -i -b"                                                         
  elseif !empty($DISPLAY) && executable('xclip')                                    
    return "cat {+f} | awk '{ print $1 }' | xclip -i -selection clipboard"                                      
  endif
endfunction

function! gitsearch#search(query, fullscreen, cmd) abort
  let curr_path = getcwd()
  let gitpath = s:GitPath()

  if empty(gitpath)
    echohl hlgroup
    echo 'WARNING: Not in a git repository'
    echohl None
    return
  endif

  " NOTE: fzf#shellescape seems to break on windows.
  " Usual shellescape works fine.
  let source_command = printf(a:cmd, g:is_windows ? shellescape(a:query) : fzf#shellescape(a:query))
  let reload_command = printf(a:cmd, '{q}')
  let preview = 'git show --color=always {1} ' . (executable('delta') ? '| delta' : '') . '|| true'
  let preview_window = a:fullscreen ? 'up,80%' : 'right,80%'
  let copy_cmd = s:GetCopyCmd()

  " NOTE: ctrl-d doesn't work on Windows nvim

  " NOTE: this could use 'start:reload' instead of 'source'
  " '--bind', 'start:reload:'.source_command,
  " But git bash never starts the command until the query changes.
  " So passing the command as source seems like a better option for
  " cross platform commands.

  let spec = {
    \   'source': source_command,
    \   'sinklist': function('s:OpenTempGitCommit'),
    \   'options': [
    \     '--prompt', 'GitSearch> ',
    \     '--header', 'ctrl-r: Interactive search | ctrl-f: Filtering results',
    \     '--multi', '--ansi',
    \     '--layout=reverse',
    \     '--disabled',
    \     '--info=inline',
    \     '--cycle',
    \     '--bind', 'alt-up:preview-page-up,alt-down:preview-page-down',
    \     '--bind', 'shift-up:preview-up,shift-down:preview-down',
    \     '--bind', 'ctrl-s:toggle-sort',
    \     '--bind', 'ctrl-l:change-preview-window(down|hidden|)',
    \     '--bind', 'ctrl-/:change-preview-window(down|hidden|)',
    \     '--bind', 'ctrl-^:toggle-preview',
    \     '--bind', 'alt-f:first',
    \     '--bind', 'alt-l:last',
    \     '--bind', 'alt-a:select-all',
    \     '--bind', 'alt-d:deselect-all',
    \     '--bind', 'alt-c:clear-query',
    \     '--query', a:query,
    \     '--bind', 'ctrl-y:execute-silent:'.copy_cmd,
    \     '--bind', 'ctrl-r:unbind(ctrl-r)+change-prompt(GitSearch> )+disable-search+reload(' . reload_command . ')+rebind(change,ctrl-f)',
    \     '--bind', "ctrl-f:unbind(change,ctrl-f)+change-prompt(FzfFilter> )+enable-search+clear-query+rebind(ctrl-r)",
    \     '--bind', 'change:reload:'.reload_command,
    \     '--preview-window', preview_window,
    \     '--preview', preview
    \   ]
    \ }

    try
      exec 'cd ' . gitpath
      call fzf#run(fzf#wrap('git', spec, a:fullscreen))
    finally
      exec 'cd ' . curr_path
    endtry
endfunction

function! gitsearch#log(query, fullscreen) abort
  let query = a:query
  let cmd = 'git log --color=always --oneline --branches --all --grep %s || true'
  if query == '?'
    let query = ''
    let file = shellescape(expand('%:p'))
    let cmd = printf(cmd, '%s -- ' . file)
  endif
  silent call gitsearch#search(query, a:fullscreen, cmd)
endfunction

function! gitsearch#regex(query, fullscreen) abort
  let query = a:query
  let cmd = 'git log --color=always --oneline --branches --all -G %s || true'
  if query == '?'
    let query = ''
    let file = shellescape(expand('%:p'))
    let cmd = printf(cmd, '%s -- ' . file)
  endif
  silent call gitsearch#search(query, a:fullscreen, cmd)
endfunction

function! gitsearch#string(query, fullscreen) abort
  let query = a:query
  let cmd = 'git log --color=always --oneline --branches --all -S %s || true'
  if query == '?'
    let query = ''
    let file = shellescape(expand('%:p'))
    let cmd = printf(cmd, '%s -- ' . file)
  endif
  silent call gitsearch#search(query, a:fullscreen, cmd)
endfunction

