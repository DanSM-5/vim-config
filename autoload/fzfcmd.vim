if exists('g:loaded_fzfcmd')
  finish
endif

let g:loaded_fzfcmd = 1
let s:is_windows = has('win32') || has('win32unix') || has('win64')
let s:is_gitbash = 0
if s:is_windows && ($MSYSTEM =~? 'MINGW' || $MSYSTEM =~? 'MSYS') && ($OSTYPE == 'msys')
  let s:is_gitbash = 1
endif

let s:fzfcmd_scripts = substitute(
  \ exists('g:fzfcmd_scripts') ? g:fzfcmd_scripts : expand('<sfile>:p:h:h') . '/utils',
  \ '\\', '/', 'g'
  \)
let s:fzfcmd_config = substitute(
  \ exists('g:fzfcmd_config') ? g:fzfcmd_config : $user_conf_path,
  \ '\\', '/', 'g'
  \)
let s:rg_args = ' --column --line-number --no-ignore --no-heading --color=always --smart-case --hidden --glob "!plugged" --glob "!.git" --glob "!node_modules" '

" Copied from fzf plugin to replace fzf#shellescape
" The intention is to remove fzf.vim as a dependency however
" I now know that fzf#shellescape comes with regular fzf plugin

" if s:is_windows
"   function! s:fzf_call(fn, ...)
"     let shellslash = &shellslash
"     try
"       set noshellslash
"       return call(a:fn, a:000)
"     finally
"       let &shellslash = shellslash
"     endtry
"   endfunction

" else

"   function! s:fzf_call(fn, ...)
"     return call(a:fn, a:000)
"   endfunction
" endif

" function! s:shellesc_cmd(arg)
"   let e = '"'
"   let slashes = 0
"   for c in split(a:arg, '\zs')
"     if c ==# '\'
"       let slashes += 1
"     elseif c ==# '"'
"       let e .= repeat('\', slashes + 1)
"       let slashes = 0
"     else
"       let slashes = 0
"     endif
"     let e .= c
"   endfor
"   let e .= repeat('\', slashes) .'"'
"   return substitute(substitute(e, '[&|<>()^!"]', '^&', 'g'), '%', '%%', 'g')
" endfunction

" function! fzfcmd#shellescape(arg, ...)
"   let shell = get(a:000, 0, s:is_windows ? 'cmd.exe' : 'sh')
"   if shell =~# 'cmd.exe$'
"     return s:shellesc_cmd(a:arg)
"   endif
"   try
"     let [shell, &shell] = [&shell, shell]
"     return s:fzf_call('shellescape', a:arg)
"   finally
"     let [shell, &shell] = [&shell, shell]
"   endtry
" endfunction

function! fzfcmd#fzf_selected_list(fzf_options, fullscreen, list) abort
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
    call fzfcmd#fzf_files(selectedList[0], a:fzf_options, a:fullscreen)
  elseif !empty(glob(selectedList[0])) " Is file
    " Open multiple files
    for sfile in selectedList
      exec ':e ' . sfile
    endfor
  endif
endfunction

function! fzfcmd#fzf_set_preview_window(spec, fullscreen) abort
  let new_spec = utils#clone_dictionary(a:spec)
  if a:fullscreen
    let new_spec.options = new_spec.options + [ '--preview-window', 'up,60%,wrap' ]
  else
    let new_spec.options = new_spec.options + [ '--preview-window', 'right,60%,wrap' ]
  endif

  return new_spec
endf

" Wrapper for fzf#vim#files that implement our preview window options
function! fzfcmd#fzf_files(query, options, fullscreen) abort
  " Get the fzf preview.sh script
  let spec = fzf#vim#with_preview({ 'options': [] }, a:fullscreen)
  " Inject preview window options
  let spec = fzfcmd#fzf_set_preview_window(spec, a:fullscreen)
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
function! fzfcmd#fzf_gitbash_files(query, preview_options, fullscreen) abort
  let placeholder = a:query == '?' ? '{2..}' : '{}'
  let options = a:preview_options + [
        \ '--layout=reverse',
        \ '--preview', 'bat -pp --color=always --style=numbers ' . placeholder
        \ ]
  let spec = a:query == '?' ? { 'placeholder': '', 'options': options } : { 'options': options }
  let spec = fzfcmd#fzf_set_preview_window(spec, a:fullscreen)
  call fzf#vim#gitfiles(a:query, spec, a:fullscreen)
endfunction

function! fzfcmd#change_project(query, fzf_options, fullscreen) abort
  let user_conf_path = s:fzfcmd_config
  let preview = user_conf_path . '/utils/fzf-preview.sh {}'
  let getprojects = user_conf_path . '/utils/getprojects'
  let reload_command = getprojects
  let files_command = "fd --type file --color=always --no-ignore --hidden --exclude plugged --exclude node_modules --exclude .git "

  " NOTE: Windows only block
  " The below if handles the function when called from powershell (pwsh)
  " And bash/zsh from MINGW (git bash)
  if s:is_windows
    let gitenv = utils#get_env()
    let bash = utils#get_bash()
    let preview = bash . ' ' . preview
    " Hack to run a bash script without adding -l or -i flags (faster)
    let getprojects = ' MSYS=enable_pcon MSYSTEM=MINGW64 enable_pcon=1 SHELL=/usr/bin/bash /usr/bin/bash -c "export PATH=/mingw64/bin:/usr/local/bin:/usr/bin:/bin:$PATH; export user_conf_path=' . user_conf_path . '; ' . getprojects . '"'

    " Subtle differences between git bash and powershell
    if s:is_gitbash
      " Update reload_command (can call script directly)
      let reload_command = 'user_conf_path=' . user_conf_path . ' ' . reload_command
      let getprojects = gitenv . getprojects
    else
      let home = substitute(expand('~'), '\\', '/', 'g')
      " Set get getprojects, then update reload_command
      let getprojects = gitenv . ' HOME=' . home . getprojects
      let reload_command = getprojects
      " Use fortward slash (/) as path separator if called from powershell
      " It is not needed for gitbash (it breaks).
      let files_command = files_command . ' --path-separator "/"'
    endif
  endif

  " Notice ctrl-d doesn't work on Windows nvim
  let spec = {
    \   'sinklist': function('fzfcmd#fzf_selected_list', [g:fzf_preview_options, a:fullscreen]),
    \   'source': getprojects,
    \   'options': [
    \     '--prompt', 'Projs> ',
    \     '--no-multi', '--ansi',
    \     '--query', a:query,
    \     '--layout=reverse',
    \     '--header', 'ctrl-f: Files | ctrl-r: Projects',
    \     '--bind', 'ctrl-f:change-prompt(Files> )+reload(' . files_command . ' . {})+clear-query+change-multi+unbind(ctrl-f)',
    \     '--bind', 'ctrl-r:change-prompt(Projs> )+reload(' . reload_command . ')+rebind(ctrl-f)+clear-query+change-multi(0)',
    \     '--preview', preview]
    \ }

  let spec.options = a:fzf_options + spec.options

  " Hope for the best
  call fzf#run(fzf#wrap('cproj', spec, a:fullscreen))
endfunction

function! fzfcmd#fzfrg_windows_preview(spec, fullscreen) abort

  let bash_path = shellescape(utils#get_bash())
  " let preview_path = substitute('/c' . $HOMEPATH . '/vim-config/utils/preview.sh', '\\', '/', 'g')
  let preview_path = utils#windows_to_msys_path(s:fzfcmd_scripts) . '/preview.sh'
  let command_preview = bash_path . ' ' . preview_path . ' {}'

  " Keep for debugging
  " echo command_preview

  if has_key(a:spec, 'options')
    let options = a:spec.options + ['--preview',  command_preview] + g:fzf_bind_options
  else
    let options = g:fzf_preview_options
  endif

  let spec = fzfcmd#fzf_set_preview_window({ 'options': options }, a:fullscreen)
  let a:spec.options = a:spec.options + spec.options

  return a:spec
endfunction

" function! fzfcmd#fzfrg_bindings(options) abort
"   return a:options + g:fzf_bind_options
" endfunction

function fzfcmd#fzfrg_base(opts) abort
  " Args
  let opts = type(a:opts) == v:t_dict ? a:opts : {}
  let command_fmt = get(opts, 'command_fmt', 'rg ' . s:rg_args)
  let query = get(opts, 'query', '')
  let prompt = get(opts, 'prompt', 'RG> ')
  let fullscreen = get(opts, 'fullscreen', 0)
  let options = get(opts, 'options', [])
  let directory = get(opts, 'directory', utils#git_path())

  " let options = type(a:options) == v:t_list ? a:options : []
  " Fixed initial load. It seems it broke on windows using fzf#shellescape
  " Usual shellescape works fine.
  let initial_command = printf(command_fmt, s:is_windows ? shellescape(query) : fzf#shellescape(query))
  let reload_command = printf(command_fmt, '{q}')
        " \     'source': initial_command,
        " \     'sink': 'e',
  let spec = {
        \     'options': ['--disabled', '--query', query,
        \                 '--ansi', '--prompt', prompt,
        \                 '--header', '| CTRL-R (RG mode) | CTRL-F (FZF mode) |',
        \                 '--multi', '--delimiter', ':', '--preview-window', '+{2}-/2,wrap',
        \                 '--bind', 'ctrl-r:unbind(ctrl-r)+change-prompt('.prompt.')+disable-search+reload(' . reload_command. ')+rebind(change,ctrl-f)',
        \                 '--bind', "ctrl-f:unbind(change,ctrl-f)+change-prompt(FZF> )+enable-search+clear-query+rebind(ctrl-r)",
        \                 '--bind', 'start:reload:'.initial_command,
        \                 '--bind', 'change:reload:'.reload_command] + options
        \}


  " TODO: From fzf.vim
  " The g:fzf_vim dictionary can be used to alter the behavior of the
  " preview
  " let g:fzf_vim.preview_bash = 'C:\Git\bin\bash.exe' " for setting gitbash
  " let g:fzf_vim.preview_window = ['hidden,right,50%,<70(up,40%)', 'ctrl-/']
  "
  " Consider using this instead of changing FZF_DEFAULT_OPTS environment
  " variable
  " let g:fzf_vim = {}
  " let g:fzf_vim.preview_window = ['right,80%', 'ctrl-/']
  " let g:fzf_vim.preview_bash = utils#get_bash()

  if s:is_windows
    let spec = fzfcmd#fzfrg_windows_preview(spec, fullscreen)
  else
    let spec = fzf#vim#with_preview(spec)
    let spec = fzfcmd#fzf_set_preview_window(spec, fullscreen)
    let spec.options = spec.options + g:fzf_bind_options
  endif

  " fzf.vim examples
  " call fzf#vim#grep2("rg --column --line-number --no-heading --color=always --smart-case -- ", <q-args>, fzf#vim#with_preview(), <bang>0)
  " call fzf#vim#grep2("rg --column --line-number --no-heading --color=always --smart-case -- ", a:query, fzf#vim#with_preview(), a:fullscreen)

  let curr_path = getcwd()

  try
    " Change path to get relative 'short' paths in the fzf search
    exec 'cd '. directory
    " NOTE: the first argument is not needed. It is overriden by the options
    " (third argument)
    " First argument is used to identify a command name
    "
    " In theory, we can replace the fzf#vim#grep2 function with the following
    " fzf#run function BUT there is an issue with the sink function. current
    " fzf#vim#grep2 is calling some reference functions in fzf.vim
    " 'sink*': function('499') and 'sinklist': function('500')
    " Until we know how fzf#vim#grep2 handles selected files to open them,
    " we need to rely on the fzf#vim#grep2 function to handle things.
    " call fzf#run(fzf#wrap('rg --column --line-number --no-heading --color=always --smart-case -- ', spec, a:fullscreen))
    call fzf#vim#grep2('rg', query, spec, fullscreen)
  finally
    exec 'cd '. curr_path
  endtry
endfunction

function! fzfcmd#fzfrg_rg(query, fullscreen)
  let fzf_rg_args = s:rg_args
  let command_fmt = 'rg' . fzf_rg_args . '-- %s || true'
  let opts = {
    \ 'command_fmt': command_fmt,
    \ 'query': a:query,
    \ 'prompt': 'RG> ',
    \ 'fullscreen': a:fullscreen,
    \ }

  " call fzfcmd#fzfrg_base(command_fmt, a:query, 'RG> ', a:fullscreen, [])
  call fzfcmd#fzfrg_base(opts)
endfunction

" Ripgrep on recently opened files
function fzfcmd#fzfrg_history(query, fullscreen) abort
  let fzf_rg_args = s:rg_args
  " Get recent files, expand ~, and use forward slash
  let files = join(map(fzf#vim#_recent_files(), 'substitute(expand(v:val), "\\", "/", "g")'), ' ')
  let command_fmt = 'rg' . fzf_rg_args . ' -- %s ' . files . ' || true'
  let opts = {
    \ 'command_fmt': command_fmt,
    \ 'query': a:query,
    \ 'prompt': 'RgHistory> ',
    \ 'fullscreen': a:fullscreen,
    \ }

  " call fzfcmd#fzfrg_base(command_fmt, a:query, 'RgHistory> ', a:fullscreen, [])
  call fzfcmd#fzfrg_base(opts)
endfunction

function! fzfcmd#fzfrg_fuzzy(query, fullscreen)
  let command_fmt = 'rg' . s:rg_args . '-- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let spec = {'options': []}

  if s:is_windows
    let spec = fzfcmd#fzfrg_windows_preview(spec, a:fullscreen)
  else
    let spec = fzf#vim#with_preview(spec)
    let spec = fzfcmd#fzf_set_preview_window(spec, a:fullscreen)
    let spec.options = spec.options + g:fzf_bind_options
  endif

  " Change path to get relative 'short' paths in the fzf search
  let curr_path = getcwd()
  let gitpath = utils#git_path()

  try
    exec 'cd '. gitpath

    call fzf#vim#grep(initial_command, spec, a:fullscreen)
  finally
    exec 'cd '. curr_path
  endtry
endfunction

function! fzfcmd#nofile_scratch()
  let l:bufname = empty(bufname()) ? 'nofile' : bufname() " Get name
  let l:bufname = substitute(l:bufname, '[\\\/ :!><|]', '_', 'g') " Clean name
  let l:filename = tempname() " Get temp
  let l:filename = fnamemodify(l:filename, ':p:h') " Only dir
  let l:filename = l:filename . '/' . l:bufname " Fullpath
  call writefile(getbufline('%', 1, '$'), l:filename) " Save buffer
  return l:filename
endfunction

" Variation of fzfcmd#fzfrg_rg that searches on the current buffer only
function! fzfcmd#fzfrg_current(query, fullscreen)
  let curr_file = ''
  let buff_path = ''

  " Allow grepping on nofile buffers or non-existing buffers
  if &buftype == 'nofile' || !filereadable(bufname())
    let scratch = fzfcmd#nofile_scratch()
    let curr_file = s:is_windows ? shellescape(fnamemodify(scratch, ':t')) : fzf#shellescape(fnamemodify(scratch, ':t'))
    let buff_path = fnamemodify(scratch, ':p:h')
  else
    let curr_file = s:is_windows ? shellescape(expand('%:t')) : fzf#shellescape(expand('%:t'))
    let buff_path = expand('%:p:h')
  endif

  let fzf_rg_args = s:rg_args . ' --with-filename '
  let curr_path = getcwd()
  let command_fmt = 'rg' . fzf_rg_args . '-- %s ' . curr_file  . ' || true'

  let opts = {
    \ 'command_fmt': command_fmt,
    \ 'query': a:query,
    \ 'prompt': 'Grep File> ',
    \ 'fullscreen': a:fullscreen,
    \ 'directory': buff_path,
    \ }

  call fzfcmd#fzfrg_base(opts)
endfunction

" On buff close callback from 'exit' on fzf#run spec
" Last argument is the exit code of fzf process
function fzfcmd#fzf_buffers_onclose(remove_list, ...) abort
  try
    if empty(a:remove_list) || !filereadable(a:remove_list)
      return
    endif

    let buffers = readfile(a:remove_list)
    if empty(buffers)
      return
    endif

    for buffer in buffers
      try
        let bufnr = str2nr(buffer)
        if bufloaded(bufnr)
          execute 'bd! ' . bufnr
        endif
      catch
      endtry
    endfor
  finally
    " Remove temporary file
    " List of opened buffers
    call delete(a:remove_list)
  endtry
endfunction

" Return list of listed buffers (bufnr)
function! fzfcmd#buffers_get_listed() abort
  return filter(range(1, bufnr('$')), 'buflisted(v:val) && getbufvar(v:val, "&filetype") != "qf"')
endfunction

" Sorter function for buffers
" Should return first the current buffer
function fzfcmd#buffers_sort_bufnr(...) abort
  let [b1, b2] = map(copy(a:000), 'get(g:fzf#vim#buffers, v:val, v:val)')
  " Using minus between a float and a number in a sort function causes an error
  return b1 < b2 ? 1 : -1
endfunction

" Wrapper for fzf#vim#buffers to enable closing buffer with ctrl-q
function fzfcmd#fzf_buffers(query, fullscreen) abort
  " let buffers = fzfcmd#buffers_get_listed()
  " Keep a list of the currently opened buffers
  " let opened_buffers = substitute(tempname(), '\\', '/', 'g')
  " Keep track of the marked for closing buffers
  let remove_list = substitute(tempname(), '\\', '/', 'g')
  let utils_prefix = ''

  " No longer needed. Using 'exit' callback from fzf spec. Leaving comment as
  " example of how to wrap functions with callbacks using autocmds
  " Ref: https://github.com/junegunn/fzf/commit/8cb59e6fcac3dce8dfa44b678fdc94cf81efa11b
  " if has('nvim')
  "   " Use nvim autocmd to use once
  "   lua vim.api.nvim_create_autocmd('TermLeave', { pattern = '*', once = true, callback = function () vim.fn['fzfcmd#fzf_buffers_onclose'](vim.g.fzf_buffers_remove_list) end })
  " else
  "   " NOTE: In vim it cannot use BufLeave because fzf opens in a popop window
  "   " and operations like buff delete are forbidden within a popop window.
  "   " We use BufEnter and make sure it is not of type 'terminal'.
  "   " For regular flows, this should be enough. It only affects the delete
  "   " buffer action which should not be abused.
  "   augroup FzfDeleteBuffers
  "     au!
  "     au BufEnter * ++once if &buftype != 'terminal' | call fzfcmd#fzf_buffers_onclose(g:fzf_buffers_remove_list) | autocmd! FzfDeleteBuffers | endif
  "   augroup END
  " endif

  " let buff_sorted = sort(buffers, 'fzfcmd#buffers_sort_bufnr')
  " Line format 'filename linenumber [bufnr] somesymbol? buffname' with ansi
  " escape colors
  " let buff_formatted = mapnew(buff_sorted, 'fzf#vim#_format_buffer(v:val)')
  " Store formatted buff names in file
  " call writefile(buff_formatted, opened_buffers)

  " Prepare remove command
  let remove_command = $HOME . '/vim-config/utils/remove_buff.sh'
  if g:is_windows
    let bash_path = utils#get_bash()
    " TODO: Should it use the hardcoded /vim-config/utils? Consider setting a
    " global variale for the git repository
    let utils_prefix = bash_path . ' /c' . substitute($HOMEPATH, '\\', '/', 'g') . '/vim-config/utils'
    let remove_command = utils_prefix . '/remove_buff.sh'
  endif

  " Use third element is "[bufnr]"
  let remove_command = remove_command . ' {3} "' . remove_list . '"'

  " TODO: Decide which is better between execute-silent and execute
  " The first one looks nicer with no reloads but the second is better as a
  " visual confirmation that the process has ended
  let spec = fzf#vim#with_preview({
    \ 'placeholder': '{1}',
    \ 'options': g:fzf_bind_options + [
    \   '--ansi',
    \   '--no-multi',
    \   '--bind', 'ctrl-q:execute-silent(' . remove_command . ')+exclude'],
    \  'exit': function('fzfcmd#fzf_buffers_onclose', [remove_list])
    \ })

  if g:is_gitbash || (g:is_windows && !has('nvim'))
    " preview to be used for windows only
    let preview = utils_prefix . '/preview.sh {1}'
    let spec.options = spec.options + ['--preview', preview]
  endif

  " Debug
  " echo spec

  " Call base command
  call fzf#vim#buffers(a:query, spec, a:fullscreen)
endfunction

function! fzfcmd#highlights(query, fullscreen) abort
  let highlight_colors = split(execute('hi'), '\n')
  let spec = {
    \   'source': highlight_colors,
    \   'sink*': { list -> setreg('"', join(list, "\n")) },
    \   'options': g:fzf_bind_options + [
    \     '--ansi', '--border', '--multi', 
    \     '--input-border',
    \     '--query', a:query,
    \   ]
    \ }
  
  call fzf#run(fzf#wrap('highlights', spec, a:fullscreen))
endfunction

let s:todo_keywords = [
  \  'TODO',
  \  'BUG',
  \  'WARNING',
  \  'TEST',
  \  'TESTING',
  \  'PASSED',
  \  'FAILED',
  \  'INFO',
  \  'WARN',
  \  'OPTIM',
  \  'NOTE',
  \  'OPTIMIZE',
  \  'XXX',
  \  'HACK',
  \  'FIX',
  \  'FIXME',
  \  'FIXIT',
  \  'ISSUE',
  \  'PERFORMANCE',
  \  'PERF'
  \]

" keywords: string | string[]
function fzfcmd#todo_comments(keywords, fullscreen) abort
  let keywords = type(a:keywords) == v:t_string ? map(split(a:keywords, ' '), 'trim(v:val)') : a:keywords
  let keys = empty(keywords) ? s:todo_keywords : keywords
  let search_query = '\b('.join(keys, '|').'):'
  
  call fzfcmd#fzfrg_base({
        \ 'command_fmt': 'rg ' . s:rg_args .. ' %s || true',
        \ 'query': search_query,
        \ 'prompt': 'TODOs> ',
        \ 'fullscreen': a:fullscreen
        \ })
endfunction

" A = ArgLead   the leading portion of the argument currently being completed on
" C = CmdLine   the entire command line
" P = CursorPos the cursor position in it (byte index)
function fzfcmd#todo_comments_completion(A, C, P) abort
  " let trimmed = trim(a:C)
  " let length = len(split(a:C, '\W\+'))
  " " Only complete first arg
  " if length > 2 || (length == 2 && a:C != trimmed)
  "   return
  " endif

  if type(a:A) == v:t_string && strlen(a:A) > 0
    " return get_matched(engines, current)
    return sort(utils#get_matched(s:todo_keywords, a:A))
  endif
   
  " Return all
  return s:todo_keywords
endfunction


" Like fzfcmd#fzfrg_rg but select a directory first
" The search will only include results under that directory
function! fzfcmd#fzfrg_dir(query, fullscreen) abort
  let dirs_cmd = 'fd --type directory --follow'
  let dirs_preview = ''
  let preview_dir = ''
  let shell_opts = []

  if s:is_windows
    if !s:is_gitbash
      let dirs_cmd .= ' --path-separator "/"'
    endif
    let pwsh = executable('pwsh') ? 'pwsh' : 'powershell'
    let shell_opts = ['--with-shell', pwsh . ' -NoLogo -NonInteractive -NoProfile -Command']
    let preview_dir = s:fzfcmd_scripts . '/preview.ps1 "{}"'
  else
    let preview_dir = s:fzfcmd_scripts . '/preview.sh "{}"'
  endif

  let options = exists('g:fzf_bind_options') ? g:fzf_bind_options : [
    \     '--cycle',
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

  function! s:local_rg(query, fullscreen, selected)
    if len(a:selected) == 0 || !isdirectory(a:selected[0])
      return
    endif

    let fzf_rg_args = s:rg_args
    let command_fmt = 'rg' . fzf_rg_args . '-- %s || true'
    let directory = a:selected[0]
    let opts = {
      \ 'command_fmt': command_fmt,
      \ 'query': a:query,
      \ 'prompt': 'Dir RG> ',
      \ 'fullscreen': a:fullscreen,
      \ 'directory': directory,
      \ }

    call fzfcmd#fzfrg_base(opts)
  endfunction

  let spec_dir = {
    \   'sinklist': function('s:local_rg', [a:query, a:fullscreen]),
    \   'options': [
    \     '--prompt', 'Dir> ',
    \     '--bind', 'start:reload:' . dirs_cmd,
    \     '--preview', preview_dir,
    \   ] + options + ['--no-multi'] + shell_opts
    \ }

  call fzf#run(fzf#wrap('fzfdir', spec_dir, a:fullscreen))
endfunction

function! fzfcmd#rg_files(fullscreen, ...) abort
  let query = a:1
  let files = join((a:000)[1:], ' ')
  let command_fmt = printf('rg ' . s:rg_args .. ' %s || true', '%s '.files)
  call fzfcmd#fzfrg_base({
        \ 'command_fmt': command_fmt,
        \ 'prompt': 'RgFiles> ',
        \ 'query': query,
        \ 'fullscreen': a:fullscreen
        \ })
endfunction

function! fzfcmd#paste(mode) abort
  let @" = getreg(nr2char(34)) 
  return a:mode
endfunction
function! fzfcmd#pastereg(mode) abort
  let @" = getreg(nr2char(getchar())) 
  return a:mode
endfunction

function! fzfcmd#helptags(fullscreen) abort
  if !s:is_windows
    let helptags_spec = fzf#vim#with_preview({ "placeholder": "--tag {2}:{3}:{4}" })
    let helptags_spec.options = g:fzf_preview_options + ['--no-multi', '--preview', "/usr/bin/bash '".s:fzfcmd_scripts."/tagpreview.sh' {2}:{3}:{4}"]

    call fzf#vim#helptags(helptags_spec, a:fullscreen)
    return
  endif

  " NOTE: The preview won't work correctly using windows powershell
  " It is related to extracting the line number from the help file
  " using vim/nvim. On windows powershell the command never returns.
  " Leaveing here as fallback but won't work.
  let pwsh = executable('pwsh') ? 'pwsh' : 'powershell'

  let helptags_spec = {
    \   'options': g:fzf_preview_options + [
    \     '--no-multi',
    \     '--with-shell', pwsh.' -NoLogo -NonInteractive -NoProfile -Command',
    \     '--preview', s:fzfcmd_scripts . "/tagpreview.ps1 {+f}",
    \   ],
    \   'placeholder': '--tag {2}:{3}:{4}'
    \ }

    call fzf#vim#helptags(helptags_spec, a:fullscreen)
endfunction
