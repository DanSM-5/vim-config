" Plugin to opent txt files from the g:txt_dir directory (fallbacks to
" '~/prj/txt')

if exists('g:loaded_fzftxt')
  finish
endif

let g:loaded_fzftxt = 1
let s:is_windows = has('win32') || has('win32unix')
let s:is_gitbash = 0
if s:is_windows && ($MSYSTEM =~? 'MINGW' || $MSYSTEM =~? 'MSYS')
  let s:is_gitbash = 1
endif

let s:fzftxt_scripts = exists('g:fzftxt_scripts') ? g:fzftxt_scripts : expand('<sfile>:p:h:h') . '/utils'

if g:is_windows
  let s:fzf_preview = substitute(s:fzftxt_scripts . '/rg_preview.ps1', '\\', '/', 'g')
  let s:fzf_preview = 'powershell -NoLogo -NonInteractive -NoProfile -File "' . s:fzf_preview . '" {}'
else
  let s:fzf_preview = substitute(s:fzftxt_scripts . '/rg_preview.sh', '\\', '/', 'g') . ' {}'
endif

function! fzftxt#format_qfl(list) abort
  let filename = s:is_gitbash ? substitute(a:list[0], '\\', '/', 'g') : a:list[0]
  let lnum = exists('a:list[1]') ? str2nr(a:list[1]) : 0
  let text = exists('a:list[2]') ? a:list[2] : '-'
  return { 'filename': filename, 'lnum': lnum, 'text': text } 
endfunction

function! fzftxt#sink(lines) abort
  " echomsg a:lines
  let list = map(filter(a:lines, 'len(v:val)'), 'split(v:val, ":")')
  " echomsg list
  if len(list) == 0
    return
  elseif len(list) == 1
    let file = s:is_gitbash ? substitute(list[0][0], '\\', '/', 'g') : list[0][0]
    silent execute ':e ' . file
    if exists('list[0][1]')
      silent execute list[0][1]
    endif
  else
    let entries = map(list, 'fzftxt#format_qfl(v:val)')
    " echomsg entries
    silent call utils#set_qfl(entries)
  endif
endfunction

function! fzftxt#select(query, fullscreen) abort
  let curr_path = getcwd()
  let txt_dir = exists('g:txt_dir') ? g:txt_dir : '~/prj/txt'
  let txt_dir = substitute(expand(txt_dir), '\\', '/', 'g')
  let files_command = 'fd --color=always --type file . '
  let grep_command='rg --with-filename --line-number --color=always {q}'

  silent call mkdir(txt_dir, 'p')

  if s:is_windows
    if !s:is_gitbash
      let files_command = files_command . ' --path-separator "/" '
    endif
    let grep_command = grep_command . ' || cd .'
  else
    let grep_command = grep_command . ' || true'
  endif

  try
    exec 'cd ' . txt_dir

    let spec = {
      \     'source': files_command,
      \     'sinklist': function('fzftxt#sink'),
      \     'options': [
      \     '--height', '80%', '--min-height', '20',
      \     '--delimiter', ':',
      \     '--preview-window', '+{2}-/2',
      \     '--prompt', 'Files> ',
      \     '--multi', '--ansi', '--border',
      \     '--info=inline', '--cycle',
      \     '--input-border',
      \     '--header', 'ctrl-f: File selection (reload alt-r) | ctrl-r: Search mode',
      \     '--bind', 'alt-c:clear-query',
      \     '--bind', 'alt-f:first',
      \     '--bind', 'alt-l:last',
      \     '--bind', 'alt-a:select-all',
      \     '--bind', 'alt-d:deselect-all',
      \     '--bind', 'ctrl-l:change-preview-window(down|hidden|)',
      \     '--bind', 'ctrl-/:change-preview-window(down|hidden|)',
      \     '--bind', 'alt-up:preview-page-up,alt-down:preview-page-down',
      \     '--bind', 'shift-up:preview-up,shift-down:preview-down',
      \     '--bind', 'ctrl-^:toggle-preview',
      \     '--bind', 'ctrl-s:toggle-sort',
      \     '--bind', 'alt-r:reload:' . files_command,
      \     '--bind', 'ctrl-f:unbind(change,ctrl-f)+change-prompt(Files> )+enable-search+clear-query+rebind(ctrl-r,alt-r)',
      \     '--bind', 'ctrl-r:unbind(ctrl-r,alt-r)+change-prompt(Search> )+disable-search+reload(' . grep_command . ')+rebind(change,ctrl-f)',
      \     '--bind', 'change:reload:' . grep_command,
      \     '--bind', 'start:unbind(change)',
      \     '--layout=reverse',
      \     '--preview-window', '60%',
      \     '--preview', s:fzf_preview,
      \     '--query', a:query]
      \ }

    " Hope for the best
    " let spec = fzf#wrap('ftxt', spec, a:fullscreen)
    " echom spec
    call fzf#run(fzf#wrap('ftxt', spec, a:fullscreen))
  finally
    " Recover cwd on end
    exec 'cd '. curr_path
  endtry
endfunction

function! fzftxt#select_simple(query, fullscreen) abort
  let curr_path = getcwd()
  let txt_dir = exists('g:txt_dir') ? g:txt_dir : '~/prj/txt'
  let txt_dir = substitute(expand(txt_dir), '\\', '/', 'g')
  let source_command = 'fd --color=always -tf '
  " let preview_window = a:fullscreen ? 'up,80%' : 'right,80%'
  " \     '--preview-window', preview_window,

  silent call mkdir(txt_dir, 'p')

  if g:is_windows
    if !g:is_gitbash
      let source_command = source_command . ' --path-separator "/" '
    endif
  endif

  try
    exec 'cd ' . txt_dir

    " \     '--height', '80%', '--min-height', '20',
    let spec = {
      \   'source': source_command,
      \   'sinklist': function('utils#fzf_selected_list'),
      \   'options': [
      \     '--prompt', 'Files> ',
      \     '--multi', '--ansi', '--border',
      \     '--info=inline', '--cycle',
      \     '--input-border',
      \     '--bind', 'alt-c:clear-query',
      \     '--bind', 'alt-f:first',
      \     '--bind', 'alt-l:last',
      \     '--bind', 'alt-a:select-all',
      \     '--bind', 'alt-d:deselect-all',
      \     '--bind', 'ctrl-l:change-preview-window(down|hidden|)',
      \     '--bind', 'ctrl-/:change-preview-window(down|hidden|)',
      \     '--bind', 'alt-up:preview-page-up,alt-down:preview-page-down',
      \     '--bind', 'shift-up:preview-up,shift-down:preview-down',
      \     '--bind', 'ctrl-^:toggle-preview',
      \     '--bind', 'ctrl-s:toggle-sort',
      \     '--layout=reverse',
      \     '--preview-window', '60%',
      \     '--query', a:query,
      \     '--preview', s:fzf_preview]
      \ }

    " Hope for the best
    call fzf#run(fzf#wrap('ftxt', spec, a:fullscreen))
  finally
    " Recover cwd on end
    exec 'cd '. curr_path
  endtry
endfunction

function! fzftxt#open(filename) abort
  let txt_dir = exists('g:txt_dir') ? g:txt_dir : '~/prj/txt'
  let txt_dir = substitute(expand(txt_dir), '\\', '/', 'g')
  let filename = ''

  if empty(a:filename)
    let temp_name = trim(system('date +%d-%m-%Y_%H-%M-%S'))
    let filename = 'note_' . temp_name . '.md'
  else
    let filename = trim(trim(a:filename, '/'), '\')
    " Remove special characters
    let filename = substitute(filename, '[()\[\]"?%<>:!^|*~]', '', 'g')
    let filename = substitute(filename, "[']", '', 'g')
  endif

  let filename = txt_dir . '/' . filename
  let dirlocation = fnamemodify(filename, ':h')

  silent call mkdir(dirlocation, 'p')

  exec 'edit ' . filename
endfunction

" A = ArgLead		the leading portion of the argument currently being completed on
" C = CmdLine		the entire command line
" P = CursorPos	the cursor position in it (byte index)
function fzftxt#completion(A, L, P) abort
  let txt_dir = exists('g:txt_dir') ? g:txt_dir : '~/prj/txt'
  let txt_dir = substitute(expand(txt_dir), '\\', '/', 'g')

  " TODO: Check later if we can add completion
  " for nested directories

  " let curr = a:A
  " let sep = ''
  " if match(a:A, '/') != -1
  "   let sep = '/'
  " elseif match(a:A, '\') != -1
  "   let sep = '\'
  " endif

  " if !empty(sep)
  "   let tmp = split(a:A, sep)
  "   if len(tmp) == 1
  "     let txt_dir = txt_dir . sep . tmp[0]
  "     let curr = '"."'
  "     let rest = tmp[0]
  "   else
  "     let rest = join(tmp[0:-2], sep)
  "     let txt_dir = txt_dir . sep . rest
  "     let curr = tmp[-1]
  "   endif
  "   
  "   if isdirectory(txt_dir)
  "     function! BuildPath (rest, sep, option, ...) abort
  "       return a:rest . a:sep . a:option
  "     endfunction
  "     function! FilterPath(curr, val, ...) abort
  "       return a:val =~ a:curr
  "     endfunction
  "     return readdir(expand(txt_dir))->map(function('BuildPath', [rest, sep]))->filter(function('FilterPath', [curr]))
  "   endif
  " endif

  " Show absolute path
  " return readdir(expand(txt_dir))->map('"'.txt_dir.'/"..v:val')->filter('v:val =~ a:A')
  return readdir(expand(txt_dir))->map('v:val')->filter('v:val =~ a:A')
endfunction

