" Add icons to Netrw
" Ref: https://gist.github.com/AndrewRadev/ea55ba1923da3f5074cad06144e8aed3
" Save as ~/.vim/ftplugin/netrw_icons.vim

if exists('b:netrw_icons_loaded')
  finish
endif
let b:netrw_icons_loaded = 1

" We only want this to be added in vim
if has('nvim')
  finish
endif

autocmd TextChanged <buffer> call s:NetrwAddIcons()

" NOTE:
" Cannot use netrwDir or netrwSymLink as they are not
" available yet. Could update using `prop_type_change`
" but netrw highlight come from the used below.
let s:netrw_props = [{
      \ 'name': 'netrw_dir_icon',
      \ 'highlight': 'Directory',
      \ }, {
      \ 'name': 'netrw_symlink_icon',
      \ 'highlight': 'Question',
      \ }, {
      \ 'name': 'netrw_file_icon',
      \ 'highlight': 'Normal',
      \ }]

let cur_buf = bufnr('%')
for netrw_prop in s:netrw_props
  if empty(prop_type_get(netrw_prop.name, {'bufnr': cur_buf}))
    call prop_type_add(netrw_prop.name, {
          \ 'bufnr': cur_buf,
          \ 'highlight': netrw_prop.highlight,
          \ 'combine': v:true
          \ })
  endif
endfor

let s:skip = 'synIDattr(synID(line("."), col("."), 0), "name") !~ "netrwDir\\|netrwExe\\|netrwSymLink\\|netrwPlain"'


let s:NetrwGetWordRef = 0

function s:netrw_gx()
  if exists('*netrw#GX')
    return netrw#GX()
  endif

  if s:NetrwGetWordRef
    return s:NetrwGetWordRef()
  endif

  let sid = utils#get_sid('autoload.netrw.vim')

  if !sid
     return
  endif

  " Build func ref
  let s:NetrwGetWordRef = function("<SNR>".sid.'_NetrwGetWord')
  return s:NetrwGetWordRef()
endfunction

function s:NetrwAddIcons() abort
  if !exists('b:netrw_curdir')
    return
  endif

  " Clear out any previous matches
  for netrw_prop in s:netrw_props
    call prop_remove({'type': netrw_prop.name, 'all': v:true})
  endfor

  " restore cursor position
  let saved_view = winsaveview()
  defer winrestview(saved_view)

  let current_dir = b:netrw_curdir

  " Keep track of nodes we've already annotated:
  " let seen = {}

  " Start from the beginning of the file
  normal! gg0

  let pattern = '\f\+'

  if get(b:, 'netrw_liststyle') == 1
    " The timestamps shown at the side should not be iterated, so let's take
    " the list of files to determine what the last column should be:
    let files = readdir(current_dir)
    let max_length = max(map(files, {_, f -> len(f)}))

    let max_col = max_length + 2
    let pattern = '\f\+\%<'..max_col..'c'
  endif

  while search(pattern, 'W', 0, 0, s:skip) > 0
    let pos = getpos('.')
    let node = s:netrw_gx()
    call setpos('.', pos)

    if node =~ '/$'
      let is_dir = 1
    else
      let is_dir = 0
    endif

    if s:CurrentSyntaxName() == 'netrwSymLink'
      let is_symlink = 1
    else
      let is_symlink = 0
    endif

    if exists('*WebDevIconsGetFileTypeSymbol')
      let symbol = WebDevIconsGetFileTypeSymbol(b:netrw_curdir..'/'..node, is_dir)
    endif

    if is_symlink
      let type = s:netrw_props[1].name
      let symbol = empty(symbol) ? '' : symbol
      " let symbol = '🔗'
    elseif is_dir
      let type = s:netrw_props[0].name
      let symbol = empty(symbol) ? '' : symbol
      " let symbol = '📁'
    else
      let type = s:netrw_props[2].name
      let symbol = empty(symbol) ? '󰈙' : symbol
      " let symbol = '📄'
    endif

    if symbol != ''
      call prop_add(line('.'), col('.'), {
            \ 'type': type,
            \ 'text': symbol..' ',
            \ })
    endif

    " move to the end of the node
    call search('\V'..escape(node, '\'), 'We', line('.'))

    if is_symlink
      " if there's a -->, then the view is long and we can just go to the end
      " of the line
      if search('\s\+-->\s*\f\+', 'Wn', line('.'))
        normal! $
      endif
    endif
  endwhile
endfunction

function! s:CurrentSyntaxName() abort
  return synIDattr(synID(line("."), col("."), 0), "name")
endfunction
