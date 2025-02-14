" Vim only version
function! lf#lf(path = '')
  if has('nvim')
    echo 'Cannot open in nvim. Use require("utils.lf").lf() instead.'
    return
  endif
  let temp = tempname()
  let path = ''

  " Logic to set the starting path
  if a:path == '.' || a:path == '%'
    let path = expand('%:p:h')
  elseif a:path == '~'
    let path = expand('~')
  elseif !empty(a:path)
    let path = fnamemodify(a:path, ':p:h')
  else
    let path = utils#git_path()
  endif

  let path = !empty(path) ? path : expand('%:p:h')
  if !isdirectory(path)
    let path = utils#find_root('.git')
    if empty(path)
      let path = expand('~')
    endif
  endif

  " Add padding space
  let path = empty(path) ? '' : ' ' . shellescape(path)

  exec 'silent !lf -selection-path=' . shellescape(temp) . path

  if !filereadable(temp)
    redraw!
    return
  endif
  let names = readfile(temp)
  if empty(names)
    redraw!
    return
  endif
  exec 'edit ' . fnameescape(names[0])
  for name in names[1:]
    exec 'argadd ' . fnameescape(name)
  endfor
  redraw!
endfunction

