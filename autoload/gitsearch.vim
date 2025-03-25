" Search interactively in git repository in the logs
" or in the patches by regex or literal string.
"
" Upon selecting commits the patches will be opened in a new temporary buffer
" for further inpection.
"
" Calling any of the functions with a '%' as query will start the search
" scoped to the current buffer.
"
" Dependencies:
" - git
" - fzf
" - fzf.vim
" - gitsearch_copy.ps1 for coping (windows only)
"
" Recommended Commands:
" command! -nargs=* -bang -bar GitSearchLog call gitsearch#log(<q-args>, <bang>0)
" command! -nargs=* -bang -bar GitSearchRegex call gitsearch#regex(<q-args>, <bang>0)
" command! -nargs=* -bang -bar GitSearchString call gitsearch#string(<q-args>, <bang>0)

if exists('g:loaded_git_search_commits')
  finish
endif

let g:loaded_git_search_commits = 1
let s:copy_helper = exists('g:gitsearch_scripts') ? g:gitsearch_scripts : expand('<sfile>:p:h:h') . '/utils'

function! gitsearch#open_commits(commits) abort
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
    setlocal nomodifiable readonly nomodified
    setlocal filetype=git
    setlocal foldmethod=syntax
  endif
endfunction

function s:GetCopyCmd() abort
  let os = substitute(system('uname'), '\n', '', '')

  if has('gui_win32') || has('win32')
    " NOTE: Manually point to the location of the helper script
    " Or return the specific command to copy
    let gitsearch_copy = substitute(s:copy_helper, '\\', '/', 'g') . '/gitsearch_copy.ps1'
    return 'powershell -NoLogo -NonInteractive -NoProfile -File ' . shellescape(gitsearch_copy) . ' "{+f}"'
  elseif has("gui_mac") || os ==? 'Darwin'
    return "awk '{ print $1 }' {+f} | pbcopy"
  elseif !empty($WAYLAND_DISPLAY) && executable('wl-copy')
    return "awk '{ print $1 }' {+f} | wl-copy --foreground --type text/plain"
  elseif !empty($DISPLAY) && executable('xsel')
    return "awk '{ print $1 }' {+f} | xsel -i -b"
  elseif !empty($DISPLAY) && executable('xclip')
    return "awk '{ print $1 }' {+f} | xclip -i -selection clipboard"
  endif
endfunction

function! gitsearch#search(query, fullscreen, options) abort
  let curr_path = getcwd()
  let gitpath = utils#git_path()

  if empty(gitpath)
    echohl hlgroup
    echo 'WARNING: Not in a git repository'
    echohl None
    return
  endif

  let source = get(a:options, 'source', 'git log --oneline || true')
  let name = get(a:options, 'name', 'git-search-commits')
  let fzf_options = get(a:options, 'options', [])

  " NOTE: ctrl-d doesn't work on Windows nvim

  " NOTE: this could use 'start:reload' instead of 'source'
  " '--bind', 'start:reload:'.source_command,
  " But git bash never starts the command until the query changes.
  " So passing the command as source seems like a better option for
  " cross platform commands.

  let spec = {
    \   'source': source,
    \   'sinklist': function('gitsearch#open_commits'),
    \   'options': [
    \     '--prompt', 'GitSearch> ',
    \     '--multi', '--ansi',
    \     '--layout=reverse',
    \     '--input-border',
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
    \   ] + fzf_options
    \ }

    try
      exec 'cd ' . gitpath
      call fzf#run(fzf#wrap(name, spec, a:fullscreen))
    finally
      exec 'cd ' . curr_path
    endtry
endfunction

function gitsearch#search_common(query, fullscreen, cmd) abort
  let query = a:query
  let cmd = a:cmd
  if query == '?'
    let query = ''
    let file = shellescape(expand('%'))
    let cmd = printf(a:cmd, '%s --follow -- ' . file)
  endif

  " NOTE: fzf#shellescape seems to break on windows.
  " Usual shellescape works fine.
  let source = printf(cmd, g:is_windows ? shellescape(query) : fzf#shellescape(query))
  let reload = printf(cmd, '{q}')
  let copy_cmd = s:GetCopyCmd()
  let preview = 'git show --color=always {1} ' . (executable('delta') ? '| delta' : '') . ' || true'
  let preview_window = a:fullscreen ? 'up,80%,wrap' : 'right,80%,wrap'
  let options = [
    \     '--prompt', 'GitSearch> ',
    \     '--disabled',
    \     '--header', 'ctrl-r: Interactive search | ctrl-f: Filtering results | ctrl-y: Copy hashes',
    \     '--preview', preview,
    \     '--preview-window', preview_window,
    \     '--bind', 'ctrl-y:execute-silent:' . copy_cmd,
    \     '--bind', 'ctrl-r:unbind(ctrl-r)+change-prompt(GitSearch> )+disable-search+reload(' . reload . ')+rebind(change,ctrl-f)',
    \     '--bind', 'ctrl-f:unbind(change,ctrl-f)+change-prompt(FzfFilter> )+enable-search+clear-query+rebind(ctrl-r)',
    \     '--bind', 'change:reload:'.reload,
    \ ]
  let search_options = { 'source': source, 'options': options }
  call gitsearch#search(query, a:fullscreen, search_options)
endfunction

function! gitsearch#log(query, fullscreen) abort
  let cmd = 'git log --color=always --oneline --branches --all --grep %s || true'
  call gitsearch#search_common(a:query, a:fullscreen, cmd)
endfunction

function! gitsearch#regex(query, fullscreen) abort
  let cmd = 'git log --color=always --oneline --branches --all -G %s || true'
  call gitsearch#search_common(a:query, a:fullscreen, cmd)
endfunction

function! gitsearch#string(query, fullscreen) abort
  let cmd = 'git log --color=always --oneline --branches --all -S %s || true'
  silent call gitsearch#search_common(a:query, a:fullscreen, cmd)
endfunction

function! gitsearch#file(file, fullscreen) abort
  let file = a:file
  if file == '?' || file == '' || empty(file)
    let file = expand('%')
  endif

  " TODO:Should I use the forward path version in all places?
  " It is needed for git to preview the file even on windows
  let escaped_file = shellescape(file)
  let forward_path = substitute(escaped_file, '\\', '/', 'g')
  let source = printf('git log --color=always --oneline --follow -- %s || true', escaped_file)
  let preview = 'git show --color=always %s'
  let preview_cmd = printf(preview, executable('delta') ? '{1} --follow -- ' . escaped_file . ' | delta' : '{1} --follow -- ' . escaped_file)
  let preview_all = printf(preview, executable('delta') ? '{1} | delta' : '{1}')
  let copy_cmd = s:GetCopyCmd()
  let preview_graph = 'git log --color=always --oneline --decorate --graph {1}'
  let preview_file = printf(preview, '{1}:'.forward_path)
  if executable('bat')
    let bat_style = empty($BAT_STYLE) ? 'numbers,header' : $BAT_STYLE
    let preview_file = preview_file . ' | bat --color=always --style=' . bat_style . ' --file-name ' . forward_path
  endif
  let preview_window = a:fullscreen ? 'up,70%,wrap' : 'right,70%,wrap'
  let options = { 'source': source, 'options': [
        \    '--prompt', 'File History> ',
        \    '--bind', 'ctrl-y:execute-silent(' . copy_cmd . ')+bell',
        \    '--header','File: ' .. file,
        \    '--preview', preview_cmd,
        \    '--preview-window', preview_window,
        \    '--bind', 'ctrl-a:change-preview:'.preview_all,
        \    '--bind', 'ctrl-d:change-preview:'.preview_cmd,
        \    '--bind', 'ctrl-f:change-preview:'.preview_file,
        \    '--bind', 'ctrl-g:change-preview:'.preview_graph,
        \  ] }

  " NOTE: No longer needed as we can change preview without transform
  " Fix for transform to work
  " if has('win32')
  "   let options.options = options.options + ['--with-shell', 'powershell -NoLogo -NonInteractive -NoProfile -Command']
  " endif
  silent call gitsearch#search('', a:fullscreen, options)
endfunction

