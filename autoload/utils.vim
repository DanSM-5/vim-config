" Utility functions.
" They should avoid having dependencies
" No function should be called on startup

if exists('g:loaded_utils')
  finish
endif

let g:loaded_utils = 1

" For quick path transformation as calling cygpath
" will be slower. This has some assuptions like
" the path being absolute.
function! utils#msys_to_windows_path(path) abort
  let splitted = split(a:path, '/')

  " Safety check. If a path contains a ':' in the first segment
  " it is very likely it is already a windows path
  if stridx(splitted[0], ':') != -1
    return a:path
  endif

  let pathFromDrive = join(splitted[1:-1], '/')
  let driveLetter = toupper(splitted[0])
  return driveLetter.':/'.pathFromDrive
endfunction

function! utils#windows_to_msys_path(path) abort
  let slashidx = stridx(a:path, '/')
  if slashidx == 0
    " If the very first characted of the path is a '/'
    " then it should be already in msys format
    return a:path
  elseif slashidx == -1
    " If no forward slash exist, it must have backslashes
    let splitted = split(a:path, '\')
  else
    let splitted = split(a:path, '/')
  endif

  let pathFromDrive = join(splitted[1:-1], '/')
  let driveLetter = tolower(splitted[0][0])
  return '/'.driveLetter.'/'.pathFromDrive
endfunction

function! utils#set_qfl(list)
  call setqflist(a:list)
  copen
  wincmd p
  cfirst
  normal! zvzz
endfunction

function! utils#set_loclist(list)
  call setloclist(0, a:list)
  lopen
  wincmd p
  lfirst
  normal! zvzz
endfunction

function! utils#current_buffer_path () abort
  " NOTE: Git Bash and Git Zsh
  " fzf#vim#grep command will fail if '\' is not escaped
  " fzf#vim#files command will fail if '\' is escaped
  " Both functions work if '\' is replaced by '/'
  return substitute(trim(expand('%:p:h')), '\', '/', 'g')
  " return trim(expand('%:p:h'))
  " return trim(shellescape(expand('%:p:h')))
endfunction

function! utils#git_path () abort
  " Directory holding the current file
  let file_dir = trim(expand('%:p:h'))

  let gitcmd = 'cd '.shellescape(file_dir).' && git rev-parse --show-toplevel'
  if (has('win32') || has('win32unix')) && !has('nvim')
    " WARN: Weird behavior started to occur in which vim in windows
    " requires an additional shellescape to run when command has parenthesis
    " or when it has quotations
    let gitcmd = shellescape(gitcmd)
  endif
  let gitpath = trim(system(gitcmd))

  if isdirectory(gitpath)
    return gitpath
  endif

  let buffpath = utils#current_buffer_path()
  if isdirectory(buffpath)
    return buffpath
  endif
endfunction

" Find a directory containing 'lookFor'
function! utils#find_root(lookFor) abort
  let pathMaker = '%:p'
  while(len(expand(pathMaker)) > len(expand(pathMaker.':h')))
    let pathMaker = pathMaker.':h'
    let fileToCheck = expand(pathMaker).'/'.a:lookFor
    if filereadable(fileToCheck) || isdirectory(fileToCheck)
      return expand(pathMaker)
    endif
  endwhile
  return 0
endfunction

" Make directory utility that handles expanding special
" characted like '~' or '%'
function utils#mkdir(path, current) abort
  if a:current
    let path = '%:p:h'
  else
    let path = a:path
  endif
  call mkdir(expand(path), 'p')
endfunction

function! utils#get_selected_text()
  let [begin, end] = [getpos("'<"), getpos("'>")]
  let lastchar = matchstr(getline(end[1])[end[2]-1 :], '.')
  if begin[1] ==# end[1]
    let lines = [getline(begin[1])[begin[2]-1 : end[2]-2]]
  else
    let lines = [getline(begin[1])[begin[2]-1 :]]
          \         + (end[1] - begin[1] <# 2 ? [] : getline(begin[1]+1, end[1]-1))
          \         + [getline(end[1])[: end[2]-2]]
  endif
  return join(lines, '\n') . lastchar . (visualmode() ==# 'V' ? '\n' : '')
endfunction

function! utils#clone_dictionary(source)
    let dNew = {}
    for key in keys(a:source)
        let dNew[key] = a:source[key]
    endfor
    return dNew
endfunction
" Fzf functions

function! utils#fzf_selected_list(fzf_options, fullscreen, list) abort
  if len(a:list) == 0
    return
  endif

  if g:is_gitbash
    let selectedList = map(a:list, 'utils#msys_to_windows_path(v:val)')
  else
    let selectedList = a:list
  endif

  if isdirectory(selectedList[0])
    " Use first selected directory only!
    call utils#fzf_files(selectedList[0], a:fzf_options, a:fullscreen)
  elseif !empty(glob(selectedList[0])) " Is file
    " Open multiple files
    for sfile in selectedList
      exec ':e ' . sfile
    endfor
  endif
endfunction

function! utils#fzf_set_preview_window(spec, fullscreen) abort
  let new_spec = utils#clone_dictionary(a:spec)
  if a:fullscreen
    let new_spec.options = new_spec.options + [ '--preview-window', 'up,60%,wrap' ]
  else
    let new_spec.options = new_spec.options + [ '--preview-window', 'right,60%,wrap' ]
  endif

  return new_spec
endf

" Wrapper for fzf#vim#files that implement our preview window options
function! utils#fzf_files(query, options, fullscreen) abort
  " Get the fzf preview.sh script
  let spec = fzf#vim#with_preview({ 'options': [] }, a:fullscreen)
  " Inject preview window options
  let spec = utils#fzf_set_preview_window(spec, a:fullscreen)
  " Append options after to get better keybindings for 'ctrl-/'
  let spec.options = spec.options + a:options

  try
    call fzf#vim#files(a:query, spec, a:fullscreen)
  finally
  endtry
endfunction

" NOTE: Under gitbash previews doesn't work due to how fzf.vim
" builds the paths for the bash.exe executable
" On powershell, however, vim has issues not showing preview window
" and it may get stuck as in git bash if called before fzf#vim#with_preview
" This wrapper over fzf#vim#gitfiles is used to override GFiles command from
" fzf.vim.
function! utils#fzf_gitbash_files(query, preview_options, fullscreen) abort
  let placeholder = a:query == '?' ? '{2..}' : '{}'
  let options = a:preview_options + [
        \ '--layout=reverse',
        \ '--preview', 'bat -pp --color=always --style=numbers ' . placeholder
        \ ]
  let spec = a:query == '?' ? { 'placeholder': '', 'options': options } : { 'options': options }
  let spec = utils#fzf_set_preview_window(spec, a:fullscreen)
  call fzf#vim#gitfiles(a:query, spec, a:fullscreen)
endfunction

function utils#register_move(destination, source) abort
  call setreg(a:destination, getreg(a:source))
endfunction

function! utils#windows_short_path(path) abort
  " From fzf.vim
  " Changes paths like 'C:/Program Files' that have spaces into C:/PROGRA~1
  " which is nicer as we avoid escaping
  return split(system('for %A in ("'. a:path .'") do @echo %~sA'), "\n")[0]
endfunction

" Requires awk and tr in the path
function! utils#get_bash() abort
  if has('win32')
    let bash = substitute(
      \ system('where.exe bash | awk "/[Gg]it/ {print}" | tr -d "\r\n"'),
      \ '\n', '', '')
    return substitute(utils#windows_short_path(bash), '\\', '/', 'g')
  endif

  return '/bin/bash'
endfunction

" Requires awk and tr in the path
function! utils#get_env() abort
  if has('win32')
    let env = substitute(
      \ system('where.exe env | awk "/[Gg]it/ {print}" | tr -d "\r\n"'),
      \ '\n', '', '')
    return substitute(utils#windows_short_path(env), '\\', '/', 'g')
  endif

  return '/usr/bin/env'
endfunction

