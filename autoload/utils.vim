" Utility functions.
" They should avoid having dependencies

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
  let slashidx = stridx(path, '/')
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

function! utils#fzf_selected_list(list) abort
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
    call s:Fzf_vim_files(selectedList[0], s:fzf_preview_options, 0)
  elseif !empty(glob(selectedList[0])) " Is file
    " Open multiple files
    for sfile in selectedList
      exec ':e ' . sfile
    endfor
  endif
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

function! utils#windows_short_path(path) abort
  " From fzf.vim
  " Changes paths like 'C:/Program Files' that have spaces into C:/PROGRA~1
  " which is nicer as we avoid escaping
  return split(system('for %A in ("'. a:path .'") do @echo %~sA'), "\n")[0]
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

