if exists('g:loaded_fzfcmd')
  finish
endif

let g:loaded_fzfcmd = 1
let s:is_windows = has('win32') || has('win32unix')
let s:is_gitbash = 0
if s:is_windows && ($MSYSTEM =~? 'MINGW' || $MSYSTEM =~? 'MSYS')
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
    \   'sinklist': function('utils#fzf_selected_list', [g:fzf_preview_options, a:fullscreen]),
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
  echomsg s:fzfcmd_scripts
  let preview_path = utils#windows_to_msys_path(s:fzfcmd_scripts) . '/preview.sh'
  let command_preview = bash_path . ' ' . preview_path . ' {}'

  " Keep for debugging
  " echo command_preview

  if has_key(a:spec, 'options')
    let options = a:spec.options + ['--preview',  command_preview] + g:fzf_bind_options
  else
    let options = g:fzf_preview_options
  endif

  let spec = utils#fzf_set_preview_window({ 'options': options }, a:fullscreen)
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
  " let g:fzf_vim.preview_bash = g:bash

  if s:is_windows
    let spec = fzfcmd#fzfrg_windows_preview(spec, fullscreen)
  else
    let spec = fzf#vim#with_preview(spec)
    let spec = utils#fzf_set_preview_window(spec, fullscreen)
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
    let spec = utils#fzf_set_preview_window(spec, a:fullscreen)
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

" Variation of fzfcmd#fzfrg_rg that searches on the current buffer only
function! fzfcmd#fzfrg_current(query, fullscreen)
  let fzf_rg_args = s:rg_args . ' --with-filename '
  let curr_path = getcwd()
  let buff_path = expand('%:p:h')
  let curr_file = s:is_windows ? shellescape(expand('%:t')) : fzf#shellescape(expand('%'))
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

