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

function! utils#git_path (...) abort
  let path = (exists('a:1') && !empty(a:)) ? a:1 : expand('%:p:h')
  " Directory holding the current file
  let file_dir = trim(path)

  let gitcmd = printf('git -C %s rev-parse --show-toplevel', shellescape(file_dir))
  " if (has('win32') || has('win32unix')) && !has('nvim')
  "   " WARN: Weird behavior started to occur in which vim in windows
  "   " requires an additional shellescape to run when command has parenthesis
  "   " or when it has quotations
  "   let gitcmd = shellescape(gitcmd)
  " endif
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

" Tests
" Arrow marks always point correctly start and end
" 'v' and '.' may be reversed depending on which direction
" was used in the visual selection and require adjustment
"
" let v = getpos('v')
" let dot = getpos('.')
" let left = getpos("'<")
" let right = getpos("'>")
" echomsg 'Dot: '.join(dot,',')
" echomsg 'V: '.join(v,',')
" echomsg 'Left: '.join(left,',')
" echomsg 'Right: '.join(right,',')

" function! utils#get_selected_text_old()
"   let [begin, end] = [getpos("'<"), getpos("'>")]

"   " Check if there is any content selected
"   let content = getline(begin[1], end[1])
"   if len(content) == 0
"     return []
"   endif

"   let lastchar = matchstr(getline(end[1])[end[2]-1 :], '.')
"   if begin[1] ==# end[1]
"     let lines = [getline(begin[1])[begin[2]-1 : end[2]-2]]
"   else
"     let lines = [getline(begin[1])[begin[2]-1 :]]
"           \         + (end[1] - begin[1] <# 2 ? [] : getline(begin[1]+1, end[1]-1))
"           \         + [getline(end[1])[: end[2]-2]]
"   endif
"   return split(join(lines, '\n') . lastchar, '\n')
"   " return join(lines, '\n') . lastchar . (visualmode() ==# 'V' ? '\n' : '')
" endfunction

" Alternatives: https://stackoverflow.com/a/28398359/10393984

" Get selected text from mark references
function! utils#get_selected_text_marks(a_mark, b_mark, mode)
  let mode = a:mode
  let [line_start, column_start] = getpos(a:a_mark)[1:2]
  let [line_end, column_end] = getpos(a:b_mark)[1:2]

  " Mark could be reversed if starting selection from bottom to top or right to left
  if (line2byte(line_start)+column_start) > (line2byte(line_end)+column_end)
    let [line_start, column_start, line_end, column_end] =
      \   [line_end, column_end, line_start, column_start]
  end

  let lines = getline(line_start, line_end)

  " No selection, return empty
  if len(lines) == 0
    return []
  endif

  " Handle visual line selection
  if mode ==# 'V'
    return lines " No further process
  endif

  " Handle visual block selection
  if mode ==# "\<C-V>"
    " Selection can be reversed if started from right to left
    let [column_start, column_end] = column_end > column_start ? [column_start, column_end] : [column_end, column_start]

    if &selection ==# "exclusive"
      let column_end -= 1 " Needed to remove the last character to make it match the visual selction
    endif
    for idx in range(len(lines))
      let lines[idx] = lines[idx][: column_end - 1]
      let lines[idx] = lines[idx][column_start - 1:]
    endfor

    return lines
  endif

  " Handle visual mode 'v'
  if &selection ==# "exclusive"
    let column_end -= 1 " Needed to remove the last character to make it match the visual selction
  endif

  let lines[-1] = lines[-1][: column_end - 1]
  let lines[ 0] = lines[ 0][column_start - 1:]

  return lines
endfunction

function! utils#get_selected_text() abort
  " Check current mode
  let curr_mode = mode()
  if curr_mode ==# 'v' || curr_mode ==# 'V' || curr_mode ==# ''
    " This is valid if currently in a variation of visual mode 
    " trigger by something like `<cmd>call func(visual)<cr>`
    " We can use positions 'v' (cursor) and '.' (oposite end)
    return utils#get_selected_text_marks('v', '.', curr_mode)
  else
    " When current mode is not visual, it means the mode has ended
    " usually from things like `:<C-U>call func(visual)<cr>`
    " Then the last visual mode can be fetched with visualmode() and marks '< '>
    return utils#get_selected_text_marks("'<", "'>", visualmode())
  end
endfunction

function! utils#clone_dictionary(source)
    let dNew = {}
    for key in keys(a:source)
        let dNew[key] = a:source[key]
    endfor
    return dNew
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

function utils#register_move(destination, source) abort
  call setreg(a:destination, getreg(a:source))
endfunction

function utils#delete_marks_curr_line() abort
  let bufnr = bufnr('%')
  let cur_line = line('.')
  "                      [bufnum, lnum, col, off]
  " { mark: string; pos: [number, number, number, number] }[]
  let all_marks_local = getmarklist(bufnr)
  for mark in all_marks_local
    if mark.pos[1] == cur_line && mark.mark =~? "'[a-z]"
      echomsg 'Deleting mark: ' . mark.mark[1:1]
      exec 'delmarks ' . mark.mark[1:1]
    endif
  endfor

  let bufname = expand('%:p')
  "                                    [bufnum, lnum, col, off]
  " { file: string; mark: string; pos: [number, number, number, number] }[]
  let all_marks_global = getmarklist()
  for mark in all_marks_global
    let expanded_file_name = fnamemodify(mark.file, ':p')
    if bufname == expanded_file_name && mark.pos[1] == cur_line && mark.mark =~? "'[A-Z]"
      echomsg 'Deleting mark:' . mark.mark[1:1]
      exec 'delmarks ' . mark.mark[1:1]
    end
  endfor
endfunction

let g:utils_sid_cache = {}

" Attempt to get the <SID> of a script based on a
" pattern matching on the script's path
" using the operator '=~?'
function! utils#get_sid(pattern) abort
  let pattern = a:pattern

  " Cache lookup
  if !empty(get(g:utils_sid_cache, pattern, ''))
    return g:utils_sid_cache[pattern]
  endif

  " parse :scriptnames
  silent redir => all_scripts
    scriptnames
  redir end
  let all_scripts = split(all_scripts, '\n')

  " Find sid
  for line in all_scripts
    if line =~? pattern
      let sid = trim(split(line, ':')[0])
      break
    endif
  endfor

  " Not sid could be found
  if !sid
    return
  endif

  let g:utils_sid_cache[pattern] = sid
  return sid
endfunction

function utils#get_matched(list, value) abort
  let found = filter(copy(a:list), printf('v:val =~ "%s"', a:value))
  return empty(found) ? a:list : found
endfunction
