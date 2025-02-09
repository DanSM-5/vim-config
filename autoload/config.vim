
let s:mac = 'mac'
let s:windows = 'windows'
let s:linux = 'linux'
let s:termux = 'termux'
let s:wsl = 'wsl'
" if shell is powershell.exe, system calls will be utf16 files with BOM
let s:cleanrgx = '[\xFF\xFE\x01\r\n]'

let g:bash = '/usr/bin/bash'
let g:is_linux = 0
let g:is_wsl = 0
let g:is_gitbash = 0
let g:is_windows = 0
let g:is_mac = 0
let g:is_termux = 0
let g:is_container = 0

" General options
let s:rg_args = ' --column --line-number --no-ignore --no-heading --color=always --smart-case --hidden --glob "!plugged" --glob "!.git" --glob "!node_modules" '
let s:fzf_base_options = [ '--multi', '--ansi', '--bind', 'alt-c:clear-query', '--input-border' ]
let s:fzf_bind_options = s:fzf_base_options + [
      \      '--bind', 'ctrl-l:change-preview-window(down|hidden|)',
      \      '--bind', 'ctrl-/:change-preview-window(down|hidden|)',
      \      '--bind', 'alt-up:preview-page-up,alt-down:preview-page-down',
      \      '--bind', 'shift-up:preview-up,shift-down:preview-down',
      \      '--bind', 'ctrl-^:toggle-preview',
      \      '--bind', 'ctrl-s:toggle-sort',
      \      '--cycle',
      \      '--bind', 'alt-f:first',
      \      '--bind', 'alt-l:last',
      \      '--bind', 'alt-a:select-all',
      \      '--bind', 'alt-d:deselect-all']
let g:fzf_preview_options = s:fzf_bind_options + [
      \ '--layout=reverse',
      \ '--preview-window', '60%',
      \ '--preview', 'bat -pp --color=always --style=numbers {}'
      \ ]
let s:fzf_original_default_opts = $FZF_DEFAULT_OPTS

" Options with only bind commands
let s:fzf_options_with_binds = { 'options': s:fzf_bind_options }

" Options with bindings + preview
let s:fzf_options_with_preview = {'options': g:fzf_preview_options }

" Test options for formationg window
" let g:fzf_preview_window = ['right:60%', 'ctrl-/']
" let s:fzf_options_with_binds = { 'window': { 'width': 0.9, 'height': 0.6 } }
" let s:fzf_options_with_binds = { 'window': { 'up': '60%' } }

func! s:SetConfigurationsBefore () abort
  silent call s:SetCamelCaseMotion()
  silent call s:SetRG()
  silent call s:SetCtrlSF()
  silent call s:DefineCommands()

  " Paste with register bindings
  nmap cr  <Plug>ReplaceWithRegisterOperator
  nmap crr <Plug>ReplaceWithRegisterLine
  xmap cr  <Plug>ReplaceWithRegisterVisual

  " Jump conflict bindings
  nmap [n <Plug>(jumpconflict-context-previous)
  nmap ]n <Plug>(jumpconflict-context-next)
  xmap [n <Plug>(jumpconflict-context-previous)
  xmap ]n <Plug>(jumpconflict-context-next)
  omap [n <Plug>(jumpconflict-context-previous)
  omap ]n <Plug>(jumpconflict-context-next)

  " Auto increment letters when using ctrl-a
  set nrformats+=alpha

  " Enable fold method using indent
  " Ref: https://www.reddit.com/r/neovim/comments/10q2mjq/comment/j6nmuw8
  " also consider plugin: https://github.com/kevinhwang91/nvim-ufo
  exec 'set fillchars=fold:\ ,foldopen:,foldsep:\ ,foldclose:'
  set foldmethod=indent
  set nofoldenable
  set foldlevel=99
  set foldlevelstart=99
  " enable markdown folding
  let g:markdown_folding = 1
  " lua version:
  " vim.opt.fillchars = { fold = ' ' }
  " vim.opt.foldmethod = 'indent'
  " vim.opt.foldenable = false
  " vim.opt.foldlevel = 99
  " g.markdown_folding = 1 -- enable markdown folding

  " ignore case in searches
  set ignorecase
  " Ignore casing unless using uppercase characters
  set smartcase

  " always open on the right
  set splitright
  " always split below
  set splitbelow

  " Set relative numbers
  set number relativenumber

  " diffopt
  " Default
  " set diffopt=internal,filler,closeoff
  " set diffopt=internal,filler,closeoff,linematch:60
  " set diffopt=internal,filler,closeoff,algorithm:histogram,context:5,linematch:60
  if has('nvim')
    " neovim implements 'linematch:{n}'
    " Ref: https://github.com/neovim/neovim/pull/14537
    set diffopt=internal,filler,closeoff,indent-heuristic,linematch:60,algorithm:histogram
  else
    set diffopt=internal,filler,closeoff,indent-heuristic,algorithm:histogram
  endif

  " Briefly move cursor to matching pair: [], {}, ()
  " set showmatch
  " Add angle brackets as matching pair.
  set matchpairs+=<:>
endf

func! s:SetConfigurationsAfter () abort
  " Configure FZF
  silent call s:SetFZF()


  " Filter quickfix with :Cfilter :Lfilter
  autocmd QuickFixCmdPost *grep* cwindow
  if has('nvim')
    " NOTE:
    " Loading modules from neovim from nix causes it to load lua files
    " with long names which causes issues with the cache loader of neovim
    " Workaround is to diable the loader temporarily
    " Ref: https://github.com/neovim/neovim/issues/25008
    lua if vim.loader.disable ~= nil then vim.loader.disable() else vim.loader.enable(false) end
    packadd cfilter
    lua vim.loader.enable(true)
  else
    packadd! cfilter
  endif

  " For suda.vim to edit with sudo permission in vim and nvim
  " :SudoRead
  " :SudoWrite
  let g:suda_smart_edit = 1

  " Change cursor.
  " if ! has('nvim') && ! has('gui_mac') && ! has('gui_win32')
  "
  "   " Set up vertical vs block cursor for insert/normal mode
  "   if &term =~ "screen."
  "     let &t_ti.="\eP\e[1 q\e\\"
  "     let &t_SI.="\eP\e[5 q\e\\"
  "     let &t_EI.="\eP\e[1 q\e\\"
  "     let &t_te.="\eP\e[0 q\e\\"
  "   else
  "     let &t_ti.="\<Esc>[1 q"
  "     let &t_SI.="\<Esc>[5 q"
  "     let &t_EI.="\<Esc>[1 q"
  "     let &t_te.="\<Esc>[0 q"
  "   endif
  " endif
  " let &t_SI = "\<esc>[5 q"  " blinking I-beam in insert mode
  " let &t_SR = "\<esc>[3 q"  " blinking underline in replace mode
  " let &t_EI = "\<esc>[ q"  " default cursor (usually blinking block) otherwise

  let &t_SI = "\<esc>[5 q" " I beam cursor for insert mode
  let &t_EI = "\<esc>[1 q" " block cursor for normal mode
  let &t_SR = "\<esc>[3 q" " underline cursor for replace mode

  if has('nvim')
  " Enable blinking together with different cursor shapes for insert/command mode, and cursor highlighting:
    set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
      \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
      \,sm:block-blinkwait175-blinkoff150-blinkon175

    " Fix cursor shape on exit
    " Windows version of neovim won't set back the cursor shape
    augroup RestoreCursorShapeOnExit
      autocmd!
      autocmd VimLeave * set guicursor=a:ver100-blinkon100
    augroup END
  else
    " Fix cursor shape in command mode vim
    " WARN: it does not work in the editor when pressing <C-f>
    au CmdlineEnter * call echoraw(&t_SI)
    au CmdlineLeave * call echoraw(&t_EI)

    " Fix cursor shape on exit
    " autocmd VimLeave * let &t_te="\e[?1049l\e[23;0;0t"
    " autocmd VimLeave * let &t_ti="\e[?1049h\e[22;0;0t"
    " autocmd VimLeave * silent !echo -ne "\e[5 q"
    autocmd VimLeave * call echoraw(&t_SI)
  endif

"   if has('nvim')
"     set guicursor=n:block
"     set guicursor=i:ver30
"   endif
endf

func! s:SetBufferOptions () abort
  " Start with unix fileformat by default
  " But allow auto match other formats like
  " dos (windows), and mac
  set fileformats=unix,dos,mac

  augroup userconfiles
    au!
    au BufNewFile,BufRead *.uconfrc,*.uconfgrc,*.ualiasrc,*.ualiasgrc setfiletype sh
  augroup END

  augroup flog
    " autocmd FileType floggraph nno <buffer> <leader>gb :<C-U>call flog#run_command("GBrowse %(h)")<CR>
    " autocmd FileType floggraph nno <buffer> <leader>gb :<C-U>call flog#Exec("GBrowse <cword>")<CR>
    autocmd FileType floggraph nno <buffer> <leader>gb :<C-U>call flog#Exec('GBrowse ' .. substitute(matchstr(getline(line('.')), '\[\(\w\+\)\]'), '[\[\]]', '', 'g'))<CR>
    autocmd FileType git nno <buffer> <leader>gb :<C-U>execute 'GBrowse ' .. expand('<cword>')<CR>
  augroup END
endf

function! s:ToggleScroll() abort
  if &scrolloff == 0
    let &scrolloff=5
  elseif &scrolloff == 5
    let &scrolloff=999
  else
    let &scrolloff=0
  endif
endfunction

" keymaps
func! s:Set_user_keybindings () abort
  silent call s:SetVimSystemCopyMaps()
  silent call s:SetCtrlSFMaps()

  " Map clipboard functions
  xnoremap <silent> <Leader>y :<C-u>call clipboard#yank()<cr>
  nnoremap <expr> <Leader>p clipboard#paste('p')
  nnoremap <expr> <Leader>P clipboard#paste('P')
  xnoremap <expr> <Leader>p clipboard#paste('p')
  xnoremap <expr> <Leader>P clipboard#paste('P')

  " Quick buffer overview an completion to change
  nnoremap <leader>gb :ls<CR>:b<Space>

  " Change to normal mode from terminal mode
  tnoremap <leader><Esc> <C-\><C-n>

  " Clean carriage returns '^M'
  nnoremap <silent> <Leader>cr :%s/\r$//g<cr>

  " Paste text override word under the cursor
  nmap <leader>vp ciw<C-r>0<ESC>

  " Remove all trailing spaces in current buffer
  nnoremap <silent> <leader>cc :%s/\s\+$//e<cr>

  " Move between buffers with tab
  nnoremap <silent> <tab> :bn<cr>
  nnoremap <silent> <s-tab> :bN<cr>

  " vim-asterisk
  let g:asterisk#keeppos = 1
  map *   <Plug>(asterisk-*)
  map #   <Plug>(asterisk-#)
  map g*  <Plug>(asterisk-g*)
  map g#  <Plug>(asterisk-g#)
  map z*  <Plug>(asterisk-z*)
  map gz* <Plug>(asterisk-gz*)
  map z#  <Plug>(asterisk-z#)
  map gz# <Plug>(asterisk-gz#)

  " Set stay behavior by default
  " map *  <Plug>(asterisk-z*)
  " map #  <Plug>(asterisk-z#)
  " map g* <Plug>(asterisk-gz*)
  " map g# <Plug>(asterisk-gz#)

  " Command mode open in buffer ctrl+e
  cnoremap <C-e> <C-f>
  " Command mode open in buffer leader+t+e from normal mode
  nnoremap <leader>cl q:

  " Call vim fugitive
  nnoremap <leader>gg <cmd>Git<cr>

  " ]<End> or ]<Home> move current line to the end or the begin of current buffer
  nnoremap <silent>]<End> ddGp``
  nnoremap <silent>]<Home> ddggP``
  vnoremap <silent>]<End> dGp``
  vnoremap <silent>]<Home> dggP``

  " Select blocks after indenting
  xnoremap < <gv
  xnoremap > >gv|

  " Use tab for indenting in visual mode
  xnoremap <Tab> >gv|
  xnoremap <S-Tab> <gv
  nnoremap > >>_
  nnoremap < <<_

  " smart up and down
  nmap <silent><down> gj
  nmap <silent><up> gk
  " nnoremap <expr> k (v:count == 0 ? 'gk' : 'k')
  " nnoremap <expr> j (v:count == 0 ? 'gj' : 'j')

  " Fast saving
  nnoremap <C-s> :<C-u>w<CR>
  vnoremap <C-s> :<C-u>w<CR>
  cnoremap <C-s> <C-u>w<CR>

  " VimSmoothie remap
  vnoremap <S-down> <cmd>call smoothie#do("\<C-D>")<CR>
  nnoremap <S-down> <cmd>call smoothie#do("\<C-D>")<CR>
  vnoremap <S-up> <cmd>call smoothie#do("\<C-U>")<CR>
  nnoremap <S-up> <cmd>call smoothie#do("\<C-U>")<CR>
  vnoremap zz <Cmd>call smoothie#do("zz")<CR>
  nnoremap zz <Cmd>call smoothie#do("zz")<CR>

  " Quickfix navigation
  nnoremap ]q <cmd>cnext<cr>zz
  nnoremap [q <cmd>cprev<cr>zz
  " Location list navigation
  nnoremap [l <cmd>lnext<cr>zz
  nnoremap ]l <cmd>lprev<cr>zz

  " Window resize vsplit
  nnoremap <A-,> <C-w>5<
  nnoremap <A-.> <C-w>5>
  " Window resize split taller/shorter
  nnoremap <A-t> <C-w>+
  nnoremap <A-s> <C-w>-

  " Quick scroll buffer
  nnoremap <C-d> <C-d>zz
  nnoremap <C-u> <C-u>zz

  " " line text-objects
  " xnoremap il g_o0
  " omap il :<C-u>normal vil<CR>
  " xnoremap al $o0
  " omap al :<C-u>normal val<CR>

  " " buffer text-object
  " xnoremap i% GoggV
  " omap i% :<C-u>normal vi%<CR>

  " Exit insert mode
  inoremap jk <Esc>

  " clear search
  nnoremap <leader>es <cmd>CleanSearch<cr>

  " windows navigation
  nnoremap <A-k> <c-w><c-k>
  nnoremap <A-j> <c-w><c-j>
  nnoremap <A-h> <c-w><c-h>
  nnoremap <A-l> <c-w><c-l>

  " Set common behavior in vim and nvim
  " :help Y-default
  nnoremap Y y$
  " :help i_CTRL-U-default
  " Delete text before
  inoremap <C-U> <C-G>u<C-U>
  " :help i_CTRL-W-default
  " Delete word before.
  inoremap <C-W> <C-G>u<C-W>

  if g:is_windows && !has('nvim')
    " Delete word backward
    inoremap <c-bs> <c-w>
  endif

  " Delete word forward
  inoremap <c-del> <cmd>normal! dw<cr>

  " Toggle undo tree
  nnoremap <leader>u <cmd>UndotreeToggle<cr>

  " Search and replace word under the cursor
  " Using : instead of <cmd> so it doesn't need to end with <cr>
  nnoremap <leader>sr :%s/\<<C-r><C-w>\>//g<Left><Left>

  if exists(':Repeatable')
    " Duplicate and comment current line
    if has('nvim')
      Repeatable nmap yc :<C-U>t.<cr>kgccj
      Repeatable nmap yC :<C-U>t.<cr>gcck
    else
      Repeatable nmap yc yygccp
      Repeatable nmap yC yypgcck
    endif
  endif

  " Duplicate line above and below without moving cursor
  if has('nvim')
    nnoremap <A-y> :<C-U>t.<CR>
    nnoremap <A-e> :<C-U>t-1<CR>
    inoremap <A-y> <esc>:<C-U>t.<CR>a
    inoremap <A-e> <esc>:<C-U>t-1<CR>a
  else
    nnoremap <A-y> v0yO<esc>pjly$kp`[jh
    nnoremap <A-e> v0yO<esc>pjly$kp`[h
    inoremap <A-y> <esc>lv0yO<esc>pjly$kp`[jhi
    inoremap <A-e> <esc>lv0yO<esc>pjly$kp`[hi
  endif

  " We use the map <C-o> specially which conflict with jump
  " list backward function. The regular motion still works
  " but with a delay or double <C-o> will execute it immediately.
  " However, there is no easy way to cancel when in operation pending mode
  " (o-pending). Thus this map exists as a hack for NOOP with <C-o>.
  nnoremap <C-o><esc> <esc>

  " Keymaps for diffget. Useful when resolving conflicts
  " Cursor must be on conflict hunk
  " grab the changes on the left
  " nnoremap gh <cmd>diffget //2<cr>
  " grab the changes on the right
  " nnoremap gl <cmd>diffget //3<cr>

  " Keycode examples
  " <A-UP> | <Esc>[1;3A
  " <A-Down> | <Esc>[1;3B
  " <A-b>=^[b
  " <Esc> == \e == ^[

  " Set key codes for vim
  if g:is_linux && !has('nvim')
    execute "set <A-,>=\e,"
    execute "set <A-.>=\e."
    " a-z
    " for i in range(97,122)
    "   let c = nr2char(i)
    "   execute "set <A-".c.">=\e".c
    " endfor

    " Used alt keys vim
    " WARN: Do not map common keys like
    " Alt+o or Alt+u because in vim that alt mappings are
    " recognized as <esc>KEY
    execute "set <A-p>=\ep"
    execute "set <A-l>=\el"
    execute "set <A-h>=\eh"
    execute "set <A-k>=\ek"
    execute "set <A-j>=\ej"
    execute "set <A-s>=\es"
    execute "set <A-t>=\et"
    execute "set <A-e>=\ee"
    execute "set <A-y>=\ey"

    " Alt-arrow combinations throw error
    " execute "set <A-Up>=\e[1;3A"
    " execute "set <A-Down>=\e[1;3B"
    " execute "set <A-Right>=\e[1;3C"
    " execute "set <A-Left>=\e[1;3D"
  elseif g:is_mac && !has('nvim')
    execute "set <A-p>=π"
  endif

  " Change anonymous register with unnamed plus register
  nnoremap <silent> yd :<C-u>silent call utils#register_move('+', '"')<cr>
  nnoremap <silent> yD :<C-u>silent call utils#register_move('"', '+')<cr>

  " Search brackets forward/backward
  " nnoremap <silent> ]} :<C-u>silent call search('}')<cr>
  " nnoremap <silent> [} :<C-u>silent call search('}', 'b')<cr>
  " nnoremap <silent> ]{ :<C-u>silent call search('{')<cr>
  " nnoremap <silent> [{ :<C-u>silent call search('{', 'b')<cr>
  nnoremap <silent> ]} :<C-u>silent call search('[{}]')<cr>
  nnoremap <silent> [} :<C-u>silent call search('[{}]', 'b')<cr>
  nnoremap <silent> ]{ :<C-u>silent call searchpair('{', '', '}')<cr>
  nnoremap <silent> [{ :<C-u>silent call searchpair('{', '', '}', 'b')<cr>

  " Make search consistent in direction
  NXOnoremap <expr>n (v:searchforward ? 'n' : 'N').'zv'
  NXOnoremap <expr>N (v:searchforward ? 'N' : 'n').'zv'

  " Indent text object
  " :h indent-object
  xmap ii <Plug>(indent-object_linewise-none)
  omap ii <Plug>(indent-object_blockwise-none)
endf

func! s:Set_os_specific_before () abort
  let os = g:host_os
  if g:is_wsl
    " We are inside wsl
    silent call s:WSL_conf_before()
  elseif g:is_termux
    silent call s:Termux_conf_before()
  elseif g:is_linux
    silent call s:Linux_conf_before()
  elseif os == s:windows
    silent call s:Windows_conf_before()
  elseif os == s:mac
    " silent call s:Mac_conf_before()
  endif
endf

func! s:Set_os_specific_after () abort
  let os = g:host_os
  if g:is_wsl
    " We are inside wsl
    silent call s:WSL_conf_after()
  elseif g:is_termux
    silent call s:Termux_conf_after()
  elseif g:is_linux
    silent call s:Linux_conf_after()
  elseif os == s:windows
    silent call s:Windows_conf_after()
  elseif os == s:mac
    silent call s:Mac_conf_after()
  endif
endf

" **************  WINDOWS specific ********************
func! s:Windows_conf_before () abort
  " Set pwsh or powershell
  " exe 'set shell='.fnameescape("pwsh -ExecutionPolicy Bypass")
  " set shellcmdflag=-c
  set shell=cmd
  set shellcmdflag=/c

  let g:bash = substitute(system('where.exe bash | awk "/[Gg]it/ {print}" | tr -d "\r\n"'), '\n', '', '')
  " if has("gui_running") || ! has('nvim')
  "   " Vim and Gvim requires additional escaping on \r\n
  "   let g:bash = substitute(system('where.exe bash | awk '"/[Gg]it/ {print}" | tr -d '"\r\n"'), '\n', '', '')
  "   let g:bash = substitute(system("where.exe bash | awk \"/[Gg]it/ {print}\" | tr -d \"\\r\\n\" "), '\n', '', '')
  " else
  "   let g:bash = substitute(system("where.exe bash | awk \"/[Gg]it/ {print}\" | tr -d \"\r\n\" "), '\n', '', '')
  " endif

  if g:is_gitbash
    let g:fzf_vim.preview_bash = substitute(config#windows_short_path(g:bash), '\', '/', 'g')
  else
    let g:fzf_vim.preview_bash = config#windows_short_path(g:bash)
  endif

  let g:python3_host_prog = '~/AppData/local/Programs/Python/Python3*/python.exe'
  " let g:python3_host_prog = '$HOME\AppData\Local\Programs\Python\Python*\python.exe'
endf

func! s:Windows_conf_after () abort
  if executable('pbcopy.exe')
    " Set paste command with pwsh core
    let g:system_copy#paste_command = 'pbpaste.exe'
    let g:system_copy#copy_command = 'pbcopy.exe'
  endif

  if executable('tldr')
    set keywordprg=tldr
  endif

  if has("gui_win32")
    silent call s:MoveLinesBlockMapsGvim()
  else
    silent call s:MoveLinesBlockMapsWin()
  endif
endf

" **************  WSL specific ********************
func! s:WSL_conf_before () abort
  if has('nvim')
    let g:python3_host_prog = 'python3'
  endif
endf

func! s:WSL_conf_after () abort
  if $IS_WSL1 == 'true'
    " Set copy and paste commands
    let g:system_copy#paste_command = 'pbpaste.exe'
    let g:system_copy#copy_command = 'pbcopy.exe'

    call clipboard#set(g:system_copy#copy_command, g:system_copy#paste_command)
  elseif !empty($DISPLAY) && executable('xsel')
    let g:system_copy#copy_command = 'xsel -i -b'
    let g:system_copy#paste_command = 'xsel -o -b'
  elseif !empty($DISPLAY) && executable('xclip')
    let g:system_copy#copy_command = 'xclip -i -selection clipboard'
    let g:system_copy#paste_command = 'xclip -o -selection clipboard'
  elseif !empty($WAYLAND_DISPLAY) && executable('wl-copy') && executable('wl-paste')
    let g:system_copy#copy_command = 'wl-copy --foreground --type text/plain'
    let g:system_copy#paste_command = 'wl-paste --no-newline'
  elseif executable('pbpaste.exe')
    let g:system_copy#paste_command = 'pbpaste.exe'
    let g:system_copy#copy_command = 'pbcopy.exe'

    call clipboard#set(g:system_copy#copy_command, g:system_copy#paste_command)
  else
    let g:system_copy#paste_command = 'pwsh.exe -NoLogo -NonInteractive -NoProfile -Command Get-Clipboard'
    let g:system_copy#copy_command = 'pwsh.exe -NoLogo -NonInteractive -NoProfile -Command Set-Clipboard'
  endif

  silent call s:MoveLinesBlockMapsLinux()
endf

" **************  TERMUX specific ********************
func! s:Termux_conf_before () abort
  " let g:rooter_change_directory_for_non_project_files = 'current'
  " let g:rooter_patterns = ["!.SpaceVim.d/", '".git/", '"/home/".$USER."/.SpaceVim.d"]

  " Prevent changing to .SpaceVim.d directory on /mnt/c/
  " let g:spacevim_project_rooter_patterns = ["!.SpaceVim.d/"] + g:spacevim_project_rooter_patterns
  " Not implemented
  " let g:spacevim_custom_plugins = [
  "   \ ['/home/linuxbrew/.linuxbrew/opt/fzf'],
  "   \ ]

  if has('nvim')
    let g:python3_host_prog = 'python3'
  endif
endf

func! s:Termux_conf_after () abort
  " Set copy and paste commands
  let g:system_copy#paste_command = 'termux-clipboard-get'
  let g:system_copy#copy_command = 'termux-clipboard-set'
  " silent call s:MoveLinesBlockMapsLinux()
endf

" **************  LINUX specific ********************
func! s:Linux_conf_before () abort
  if has('nvim')
    let g:python3_host_prog = 'python3'
  endif

  let g:rooter_change_directory_for_non_project_files = 'current'
endf

func! s:Linux_conf_after () abort
  " Use filesystem clipboard in container
  if g:is_container
    let g:system_copy#paste_command = 'fs-paste'
    let g:system_copy#copy_command = 'fs-copy'
    call clipboard#set(g:system_copy#copy_command, g:system_copy#paste_command)
  endif

  " Run after
  silent call s:MoveLinesBlockMapsLinux()
endf

" **************  MAC specific ********************
func! s:Mac_conf_before () abort
  " Run before
endf

func! s:Mac_conf_after () abort
  " Set system_copy variables
  let g:system_copy#paste_command = 'pbpaste'
  let g:system_copy#copy_command = 'pbcopy'

  if $TERM_PROGRAM =~? 'iTerm.app'
    " do not remap
  else
    silent call s:MoveLinesBlockMapsMac()
  endif
endf

func! s:CallCleanCommand (comm) abort
  return substitute(system(a:comm), '\', 'g', '\\')
endf

func! s:CleanCR () abort
  " normal :%s/\r$//g<cr>
  try
    silent exec '%s/\r$//g'
  catch
  endtry
endf

func! s:CleanTrailingSpaces () abort
  silent exec '%s/\s\+$//e'
endf

func! s:SetCamelCaseMotion () abort
  let g:camelcasemotion_key = '<leader>'
endf

func! s:SetRG () abort
  if executable('rg')
    " In-built grep functionality
    set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case\ --no-ignore\ --hidden\ -g\ '!plugged'\ -g\ '!.git'\ -g\ '!node_modules'
    set grepformat=%f:%l:%c:%m
  endif
endf

func! s:SetCtrlSF () abort
  " Plugin help
  " :h CtrlSF

  " In CtrlSF window:
  "
  " Enter, o, double-click - Open corresponding file of current line in the window which CtrlSF is launched from.
  " <C-O> - Like Enter but open file in a horizontal split window.
  " t - Like Enter but open file in a new tab.
  " p - Like Enter but open file in a preview window.
  " P - Like Enter but open file in a preview window and switch focus to it.
  " O - Like Enter but always leave CtrlSF window opening.
  " T - Like t but focus CtrlSF window instead of new opened tab.
  " M - Switch result window between normal view and compact view.
  " q - Quit CtrlSF window.
  " <C-J> - Move cursor to next match.
  " <C-N> - Move cursor to next file's first match.
  " <C-K> - Move cursor to previous match.
  " <C-P> - Move cursor to previous file's first match.
  " <C-C> - Stop a background searching process.
  " <C-T> - (If you have fzf installed) Use fzf for faster navigation. In the fzf window, use <Enter> to focus specific match and <C-O> to open matched file.

  " let g:ctrlsf_toggle_map_key = '\t'
  " Highligth matching line in file and preview window
  let g:ctrlsf_selected_line_hl = 'op'
  let g:ctrlsf_default_root = 'cwd'
  let g:ctrlsf_backend = 'rg'
  let g:ctrlsf_extra_backend_args = {
      \ 'rg': '--hidden --glob "!plugged" --glob "!.git" --glob "!node_modules"'
      \ }
  let g:ctrlsf_ignore_dir = ['.git', 'node_modules', 'plugged']

  let g:ctrlsf_mapping = {
    \ "open"    : ["<CR>", "o"],
    \ "openb"   : { 'key': "O", 'suffix': "<C-w>p" },
    \ "split"   : "<C-O>",
    \ "vsplit"  : "<C-I>",
    \ "tab"     : "t",
    \ "tabb"    : "T",
    \ "popen"   : "p",
    \ "popenf"  : "P",
    \ "quit"    : "q",
    \ "next"    : "<C-J>",
    \ "prev"    : "<C-K>",
    \ "nfile"   : "<C-D>",
    \ "pfile"   : "<C-U>",
    \ "pquit"   : "q",
    \ "loclist" : "",
    \ "chgmode" : "M",
    \ "stop"    : "<C-C>",
    \ }
endf

" func! GitPath () abort
"   let gitcmd = 'cd '.shellescape(expand('%:p:h')).' && git rev-parse --show-toplevel'
"   if g:is_windows && !has('nvim')
"     " WARN: Weird behavior started to occur in which vim in windows
"     " requires an additional shellescape to run when command has parenthesis
"     " or when it has quotations
"     let gitcmd = shellescape(gitcmd)
"   endif
"   let gitpath = trim(system(gitcmd))
"   " exe 'FZF ' . path
"   " For debug
"   " echohl String | echon 'Path: ' . gitpath | echohl None
"   if isdirectory(gitpath)
"     return gitpath
"   else
"     return GetCurrentBufferPath()
"   endif
" endf

function! FzfChangeProject(query, fullscreen) abort
  let user_conf_path = substitute($user_conf_path, '\\', '/', 'g')
  let preview = user_conf_path . '/utils/fzf-preview.sh {}'
  let getprojects = user_conf_path . '/utils/getprojects'
  let reload_command = getprojects
  let files_command = "fd --type file --color=always --no-ignore --hidden --exclude plugged --exclude node_modules --exclude .git "

  " NOTE: Windows only block
  " The below if handles the function when called from powershell (pwsh)
  " And bash/zsh from MINGW (git bash)
  if g:is_windows
    " Get env.exe from gitbash
    let gitenv = substitute(system('where.exe env | awk "/[Gg]it/ {print}" | tr -d "\r\n"'), '\n', '', '')
    let gitenv = config#windows_short_path(gitenv)
    let gitenv = shellescape(substitute(gitenv, '\\', '/', 'g'))
    let bash = substitute(config#windows_short_path(g:bash), '\\', '/', 'g')
    let preview = bash . ' ' . preview
    " Hack to run a bash script without adding -l or -i flags (faster)
    let getprojects = ' MSYS=enable_pcon MSYSTEM=MINGW64 enable_pcon=1 SHELL=/usr/bin/bash /usr/bin/bash -c "export PATH=/mingw64/bin:/usr/local/bin:/usr/bin:/bin:$PATH; export user_conf_path=' . user_conf_path . '; ' . getprojects . '"'

    " Subtle differences between git bash and powershell
    if $IS_GITBASH == 'true'
      " Update reload_command (can call script directly)
      let reload_command = 'user_conf_path=' . user_conf_path . ' ' . reload_command
      let getprojects = gitenv . getprojects
    else
      let home = substitute($USERPROFILE, '\\', '/', 'g')
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

  let spec.options = s:fzf_bind_options + spec.options

  " Hope for the best
  call fzf#run(fzf#wrap('cproj', spec, a:fullscreen))
endfunction

function! s:FzfRgWindows_preview(spec, fullscreen) abort

  let bash_path = shellescape(substitute(g:bash, '\\', '/', 'g'))
  let preview_path = substitute('/c' . $HOMEPATH . '/vim-config/utils/preview.sh', '\\', '/', 'g')
  let command_preview = bash_path . ' ' . preview_path . ' {}'

  " Keep for debugging
  " echo command_preview

  if has_key(a:spec, 'options')
    let options = a:spec.options + ['--preview',  command_preview] + s:fzf_bind_options
  else
    let options = g:fzf_preview_options
  endif

  let spec = utils#fzf_set_preview_window({ 'options': options }, a:fullscreen)
  let a:spec.options = a:spec.options + spec.options

  return a:spec
endfunction

function! s:FzfRg_bindings(options) abort
  return a:options + s:fzf_bind_options
endfunction

" Variation of RipgrepFzf that searches on the current buffer only
function! LiveGrep(query, fullscreen)
  let fzf_rg_args = s:rg_args . ' --with-filename '
  let curr_path = getcwd()
  let buff_path = expand('%:p:h')

  try
    " Change path to get relative 'short' paths in the fzf search
    exec 'cd '. buff_path

    let curr_file = g:is_windows ? shellescape(expand('%')) : fzf#shellescape(expand('%'))
    let command_fmt = 'rg' . fzf_rg_args . '-- %s ' . curr_file  . ' || true'
    " Fixed initial load. It seems it broke on windows using fzf#shellescape
    " Usual shellescape works fine.
    let initial_command = printf(command_fmt, g:is_windows ? shellescape(a:query) : fzf#shellescape(a:query))
    let reload_command = printf(command_fmt, '{q}')
    let spec = {
          \     'options': ['--disabled', '--query', a:query,
          \                 '--ansi', '--prompt', 'LG> ',
          \                 '--header', '| CTRL-R (LG mode) | CTRL-F (FZF mode) |',
          \                 '--multi', '--delimiter', ':', '--preview-window', '+{2}-/2',
          \                 '--bind', 'ctrl-r:unbind(ctrl-r)+change-prompt(LG> )+disable-search+reload(' . reload_command. ')+rebind(change,ctrl-f)',
          \                 '--bind', "ctrl-f:unbind(change,ctrl-f)+change-prompt(FZF> )+enable-search+clear-query+rebind(ctrl-r)",
          \                 '--bind', 'start:reload:'.initial_command,
          \                 '--bind', 'change:reload:'.reload_command]
          \}

    if g:is_windows
      let spec = s:FzfRgWindows_preview(spec, a:fullscreen)
    else
      let spec = fzf#vim#with_preview(spec)
      let spec = utils#fzf_set_preview_window(spec, a:fullscreen)
      let spec.options = spec.options + s:fzf_bind_options
    endif

    call fzf#vim#grep2('rg', a:query, spec, a:fullscreen)
  finally
    " Recover cwd on end
    exec 'cd '. curr_path
  endtry
endfunction

function RipgrepBase(command_fmt, query, prompt, fullscreen, options) abort
  let options = type(a:options) == v:t_list ? a:options : []
  " Fixed initial load. It seems it broke on windows using fzf#shellescape
  " Usual shellescape works fine.
  let initial_command = printf(a:command_fmt, g:is_windows ? shellescape(a:query) : fzf#shellescape(a:query))
  let reload_command = printf(a:command_fmt, '{q}')
        " \     'source': initial_command,
        " \     'sink': 'e',
  let spec = {
        \     'options': ['--disabled', '--query', a:query,
        \                 '--ansi', '--prompt', a:prompt,
        \                 '--header', '| CTRL-R (RG mode) | CTRL-F (FZF mode) |',
        \                 '--multi', '--delimiter', ':', '--preview-window', '+{2}-/2',
        \                 '--bind', 'ctrl-r:unbind(ctrl-r)+change-prompt('.a:prompt.')+disable-search+reload(' . reload_command. ')+rebind(change,ctrl-f)',
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

  if g:is_windows
    let spec = s:FzfRgWindows_preview(spec, a:fullscreen)
  else
    let spec = fzf#vim#with_preview(spec)
    let spec = utils#fzf_set_preview_window(spec, a:fullscreen)
    let spec.options = spec.options + s:fzf_bind_options
  endif

  " fzf.vim examples
  " call fzf#vim#grep2("rg --column --line-number --no-heading --color=always --smart-case -- ", <q-args>, fzf#vim#with_preview(), <bang>0)
  " call fzf#vim#grep2("rg --column --line-number --no-heading --color=always --smart-case -- ", a:query, fzf#vim#with_preview(), a:fullscreen)

  let curr_path = getcwd()
  let gitpath = utils#git_path()

  try
    " Change path to get relative 'short' paths in the fzf search
    exec 'cd '. gitpath
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
    call fzf#vim#grep2('rg', a:query, spec, a:fullscreen)
  finally
    exec 'cd '. curr_path
  endtry
endfunction

function! RipgrepFzf(query, fullscreen)
  let fzf_rg_args = s:rg_args
  let command_fmt = 'rg' . fzf_rg_args . '-- %s || true'
  call RipgrepBase(command_fmt, a:query, 'RG> ', a:fullscreen, [])
endfunction

" Ripgrep on recently opened files
function RipgrepHistory(query, fullscreen) abort
  let fzf_rg_args = s:rg_args
  " Get recent files, expand ~, and use forward slash
  let files = join(map(fzf#vim#_recent_files(), 'substitute(expand(v:val), "\\", "/", "g")'), ' ')
  let command_fmt = 'rg' . fzf_rg_args . ' -- %s ' . files . ' || true'
  call RipgrepBase(command_fmt, a:query, 'RgHistory> ', a:fullscreen, [])
endfunction

function! RipgrepFuzzy(query, fullscreen)
  let command_fmt = 'rg' . s:rg_args . '-- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  " Hide query for now
  " let spec = {'options': ['--query', a:query]}
  let spec = {'options': []}

  if g:is_windows
    let spec = s:FzfRgWindows_preview(spec, a:fullscreen)
  else
    let spec = fzf#vim#with_preview(spec)
    let spec = utils#fzf_set_preview_window(spec, a:fullscreen)
    let spec.options = spec.options + s:fzf_bind_options
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

" function! NewTxt(filename) abort
"   let txt_dir = substitute(expand('~/prj/txt'), '\\', '/', 'g')
"   let filename = ''

"   if empty(a:filename)
"     let temp_name = trim(system('uuidgen 2>/dev/null || date +%d-%m-%Y_%H-%M-%S'))
"     let filename = 'tmp-' . temp_name . '.md'
"   else
"     let filename = a:filename
"   endif

"   let filename = txt_dir . '/' . filename
"   let dirlocation = fnamemodify(filename, ':h')

"   silent call mkdir(dirlocation, 'p')

"   exec 'edit ' . filename
" endfunction

" function! FzfTxt(query, fullscreen) abort
"   let curr_path = getcwd()
"   let user_conf_path = substitute($user_conf_path, '\\', '/', 'g')
"   let preview = user_conf_path . '/utils/fzf-preview.sh {}'
"   let txt_dir = substitute(expand('~/prj/txt'), '\\', '/', 'g')
"   let source_command = 'fd --color=always -tf '
"   " let preview_window = a:fullscreen ? 'up,80%' : 'right,80%'
"   " \     '--preview-window', preview_window,

"   silent call mkdir(txt_dir, 'p')

"   if g:is_windows
"     let gitenv = substitute(system('where.exe env | awk "/[Gg]it/ {print}" | tr -d "\r\n"'), '\n', '', '')
"     let gitenv = config#windows_short_path(gitenv)
"     let gitenv = shellescape(substitute(gitenv, '\\', '/', 'g'))
"     let bash = substitute(config#windows_short_path(g:bash), '\\', '/', 'g')
"     let preview = bash . ' ' . preview
"     if !g:is_gitbash
"       let source_command = source_command . ' --path-separator "/" '
"     endif
"   endif

"   try
"     exec 'cd ' . txt_dir

"     let spec = {
"       \   'source': source_command,
"       \   'sinklist': function('utils#fzf_selected_list'),
"       \   'options': s:fzf_bind_options + [
"       \     '--prompt', 'Open Txt> ',
"       \     '--multi', '--ansi',
"       \     '--layout=reverse',
"       \     '--preview-window', '60%',
"       \     '--query', a:query,
"       \     '--preview', preview]
"       \ }

"     " Hope for the best
"     call fzf#run(fzf#wrap('ftxt', spec, a:fullscreen))
"   finally
"     " Recover cwd on end
"     exec 'cd '. curr_path
"   endtry
" endfunction

function InsertEmoji(use_name, mode, list) abort
  if len(a:list) == 0
    return
  endif

  let parsed_list = map(a:list, 'split(v:val)' . (a:use_name ? '[1]' : '[0]'))

  " Copy to register and paste
  let @" = join(parsed_list, '')
  silent exec 'normal! p'

  " If comming from command line mode (using command)
  " exit without changing mode explicitly
  if a:mode != 'i'
    return
  endif

  " Go back to insert mode
  " Copied from fzf.vim
  if mode() =~ 't'
    call feedkeys('a', 'n')
  elseif has('nvim')
    execute "normal! \<esc>la"
  else
    call feedkeys("\<Plug>(-fzf-complete-finish)")
    " Definition
    " nnoremap <silent> <Plug>(-fzf-complete-finish) a
    " inoremap <silent> <Plug>(-fzf-complete-finish) <c-o>l
  endif

  " let text = join(parsed_list)
  " let cur_line_num = line('.')
  " let cur_col_num = col('.')
  " let orig_line = getline('.')
  " let modified_line = strpart(orig_line, 0, cur_col_num) . text . strpart(orig_line, cur_col_num - 1)
  " call setline(cur_line_num, modified_line)
endfunction

function Emoji(query, use_name, mode) abort
  let emoji_file = $user_config_cache . '/emojis/emoji'

  if !filereadable(emoji_file)
    echo 'No emojis downloaded'
    return
  endif

  let source = 'cat ' . emoji_file
  let spec = {
    \   'source': source,
    \   'sinklist': function('InsertEmoji', [a:use_name, a:mode]),
    \   'options': s:fzf_bind_options + [
    \     '--prompt', 'Emoji> ',
    \     '--multi', '--ansi',
    \     '--layout=reverse',
    \     '--query', a:query,
    \     '--height', '80%', '--min-height', '20', '--border',
    \     '--bind', 'ctrl-/:change-preview-window(down|hidden|)',
    \     '--bind', 'alt-up:preview-page-up,alt-down:preview-page-down',
    \     '--bind', 'ctrl-s:toggle-sort',
    \     '--bind', 'alt-f:first',
    \     '--bind', 'alt-l:last',
    \     '--bind', 'alt-c:clear-query']
    \ }

  call fzf#run(fzf#wrap('emoji', spec, 0))
endfunction

" Return list of listed buffers (bufnr)
function! GetBuflisted() abort
  return filter(range(1, bufnr('$')), 'buflisted(v:val) && getbufvar(v:val, "&filetype") != "qf"')
endfunction

" Sorter function for buffers
" Should return first the current buffer
function BufSorterFunc(...) abort
  let [b1, b2] = map(copy(a:000), 'get(g:fzf#vim#buffers, v:val, v:val)')
  " Using minus between a float and a number in a sort function causes an error
  return b1 < b2 ? 1 : -1
endfunction


" On buff close callback from 'exit' on fzf#run spec
" Last argument is the exit code of fzf process
function Fzf_vim_close_buffers(remove_list, opened_buffers, ...) abort
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
    " Buffers to remove
    call delete(a:opened_buffers)
    " Remove temporary file
    " List of opened buffers
    call delete(a:remove_list)
  endtry
endfunction

" Wrapper for fzf#vim#buffers to enable closing buffer with ctrl-q
function FzfBuffers(query, fullscreen) abort
  let buffers = GetBuflisted()
  " Keep a list of the currently opened buffers
  let opened_buffers = substitute(tempname(), '\\', '/', 'g')
  " Keep track of the marked for closing buffers
  let remove_list = substitute(tempname(), '\\', '/', 'g')
  let utils_prefix = ''

  " No longer needed. Using 'exit' callback from fzf spec. Leaving comment as
  " example of how to wrap functions with callbacks using autocmds
  " Ref: https://github.com/junegunn/fzf/commit/8cb59e6fcac3dce8dfa44b678fdc94cf81efa11b
  " if has('nvim')
  "   " Use nvim autocmd to use once
  "   lua vim.api.nvim_create_autocmd('TermLeave', { pattern = '*', once = true, callback = function () vim.fn.Fzf_vim_close_buffers(vim.g.fzf_buffers_remove_list) end })
  " else
  "   " NOTE: In vim it cannot use BufLeave because fzf opens in a popop window
  "   " and operations like buff delete are forbidden within a popop window.
  "   " We use BufEnter and make sure it is not of type 'terminal'.
  "   " For regular flows, this should be enough. It only affects the delete
  "   " buffer action which should not be abused.
  "   augroup FzfDeleteBuffers
  "     au!
  "     au BufEnter * ++once if &buftype != 'terminal' | call Fzf_vim_close_buffers(g:fzf_buffers_remove_list) | autocmd! FzfDeleteBuffers | endif
  "   augroup END
  " endif
  let buff_sorted = sort(buffers, 'BufSorterFunc')
  let buff_formatted = mapnew(buff_sorted, 'fzf#vim#_format_buffer(v:val)')
  " Store formatted buff names in file
  call writefile(buff_formatted, opened_buffers)

  " Prepare remove command
  let remove_command = $HOME . '/vim-config/utils/remove_buff.sh'
  if g:is_windows
    let bash_path = config#windows_short_path(substitute(g:bash, '\\', '/', 'g'))
    if g:is_gitbash
      let bash_path = substitute(bash_path, '\\', '/', 'g')
    endif
    " let bash_path = shellescape(substitute(g:bash, '\\', '/', 'g'))
    " TODO: Should it use the hardcoded /vim-config/utils? Consider setting a
    " global variale for the git repository
    let utils_prefix = bash_path . ' /c' . substitute($HOMEPATH, '\\', '/', 'g') . '/vim-config/utils'
    let remove_command = utils_prefix . '/remove_buff.sh'
  endif

  " /path/to/remove_buff.sh [selected/file] [buffs/file] [delete/file]
  let remove_command = remove_command . ' {+f} ' . opened_buffers . ' ' . remove_list
  " Reload command
  let reload_command = 'cat ' . opened_buffers

  " TODO: Decide which is better between execute-silent and execute
  " The first one looks nicer with no reloads but the second is better as a
  " visual confirmation that the process has ended
  let spec = fzf#vim#with_preview({
    \ 'placeholder': '{1}',
    \ 'options': s:fzf_bind_options + [
    \   '--ansi',
    \   '--no-multi',
    \   '--bind', 'ctrl-q:execute-silent(' . remove_command . ')+reload:' . reload_command],
    \  'exit': function('Fzf_vim_close_buffers', [remove_list, opened_buffers])
    \ })

  if g:is_gitbash || (g:is_windows && !has('nvim'))
    " preview to be used for windows only
    let preview = utils_prefix . '/preview.sh {1}'
    let spec.options = spec.options + ['--preview', preview]
  endif

  " Debug
  " echo buff_sorted
  " echo spec

  " Call base command
  call fzf#vim#buffers(a:query, buff_sorted, spec, a:fullscreen)
endfunction

function ExecuteRGVisual() abort
  let text = utils#get_selected_text()
  let text = split(text, '\n')[0]
  " Remove trailing space
  let text = trim(text)
  exe "RG " . text
endfunction

func! s:SetFZF () abort
  " fzf commands
  " fzf
  nnoremap <leader>ff <cmd>Files<cr>
  " Lines in buffers
  nnoremap <leader>fl <cmd>Lines<cr>
  " Lines in current buffer
  nnoremap <leader>fb <cmd>BLines<cr>
  " git ls-files
  nnoremap <leader>fn <cmd>GFiles<cr>
  " git status
  nnoremap <leader>gs <cmd>GFiles?<cr>
  " Themes (color schemes)
  nnoremap <leader>ft <cmd>Colors<cr>
  " Open windows
  nnoremap <leader>fw <cmd>Windows<cr>
  " Previously Opened files
  nnoremap <leader>fh <cmd>History<cr>
  " Previous search
  nnoremap <leader>f/ <cmd>History/<cr>
  " Command history
  nnoremap <leader>f; <cmd>History:<cr>
  " Commands
  nnoremap <leader>f: <cmd>Commands<cr>
  " Maps
  nnoremap <leader>fm <cmd>Maps<cr>
  " Jump list
  nnoremap <leader>fj <cmd>Jumps<cr>
  " Changes across buffers
  nnoremap <leader>fc <cmd>Changes<cr>

  " Set grep commands
  nnoremap <leader>lg <cmd>Lg<cr>
  nnoremap <leader>fg <cmd>RG<cr>
  nnoremap <leader>fG <cmd>Rg<cr>

  " Mapping selecting mappings in respective mode using fzf
  " nmap <leader><tab> <plug>(fzf-maps-n)
  " xmap <leader><tab> <plug>(fzf-maps-x)
  " omap <leader><tab> <plug>(fzf-maps-o)

  " Insert mode completion
  imap <c-o><c-k> <plug>(fzf-complete-word)
  imap <c-o><c-f> <plug>(fzf-complete-path)
  imap <c-o><c-l> <plug>(fzf-complete-line)

  command! -nargs=* -bang -bar GitSearchLog call gitsearch#log(<q-args>, <bang>0)
  command! -nargs=* -bang -bar GitSearchRegex call gitsearch#regex(<q-args>, <bang>0)
  command! -nargs=* -bang -bar GitSearchString call gitsearch#string(<q-args>, <bang>0)
  command! -nargs=? -bang -bar -complete=file GitSearchFile call gitsearch#file(<q-args>, <bang>0)

  command! -nargs=* -bang -complete=customlist,fzftxt#completion FTxt call fzftxt#select(<q-args>, <bang>0)
  command! -nargs=* -bang CPrj call FzfChangeProject(<q-args>, <bang>0)
  command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)
  command! -nargs=* -bang Rg call RipgrepFuzzy(<q-args>, <bang>0)
  command! -nargs=* -bang Lg call LiveGrep(<q-args>, <bang>0)
  command! -nargs=* -bang RgHistory call RipgrepHistory(<q-args>, <bang>0)

  command! -bang -nargs=? -complete=dir Files
    \ call utils#fzf_files(<q-args>, g:fzf_preview_options, <bang>0)
  command! -bar -bang -nargs=? -complete=buffer Buffers call FzfBuffers(<q-args>, <bang>0)

  " NOTE: Under gitbash previews doesn't work due to how fzf.vim
  " builds the paths for the bash.exe executable
  " On powershell, however, vim has issues not showing preview window
  " and it may get stuck as in git bash if called before fzf#vim#with_preview
  if g:is_gitbash || (!has('nvim') && g:is_windows)
    command! -bang -nargs=? GFiles
      \ call utils#fzf_gitbash_files(<q-args>, g:fzf_preview_options, <bang>0)
  endif

  " fzf options with custom preview
  if g:is_windows || g:is_termux
    command! -bang -nargs=? -complete=dir FzfFiles
      \ call utils#fzf_files(<q-args>, g:fzf_preview_options, <bang>0)
    command! -bang -nargs=? -complete=dir GitFZF
      \ call utils#fzf_files(empty(<q-args>) ? utils#git_path() : <q-args>, g:fzf_preview_options, <bang>0)

  " fzf options that only include common bindings
  else

    command! -bang -nargs=? -complete=dir FzfFiles
      \ call utils#fzf_files(<q-args>, s:fzf_bind_options, <bang>0)
    command! -bang -nargs=? -complete=dir GitFZF
      \ call utils#fzf_files(empty(<q-args>) ? utils#git_path() : <q-args>, s:fzf_bind_options, <bang>0)
  endif


  " Set keymappings
  " Open File fullscreen
  nnoremap <A-p> :<C-u>GitFZF!<CR>
  " Open File
  nnoremap <C-P> :<C-u>GitFZF<CR>
  " Open from project
  nnoremap <C-o>p :<C-u>CPrj<CR>
  " Open from notes (txt)
  nnoremap <C-o>t :<C-u>FTxt<CR>
  " Search word under the cursor (RG)
  nnoremap <leader>fr :execute 'RG '.expand('<cword>')<cr>
  " NOTE: We need a wrapper to trim new lines for RG
  " xnoremap <leader>fr :<C-u>execute 'RG '.GetSelectionText()<cr>
  xnoremap <leader>fr :<C-u>call ExecuteRGVisual()<cr>
  " Opened buffers
  nnoremap <C-o>b <cmd>Buffers<cr>
  " Set usual ctrl-o behavior to double the sequence
  nnoremap <C-o><C-o> <C-o>
endf

func! s:SetVimSystemCopyMaps () abort
  nmap zy <Plug>SystemCopy
  xmap zy <Plug>SystemCopy
  nmap zY <Plug>SystemCopyLine
  nmap zp <Plug>SystemPaste
  xmap zp <Plug>SystemPaste
  nmap zP <Plug>SystemPasteLine
endf

func! s:SetCtrlSFMaps () abort
  " Note: <C-M> and <Enter> (also <CR>) are the same
  " for vim and nvim

  nmap     <C-t>f <Plug>CtrlSFPrompt
  vmap     <C-t>f <Plug>CtrlSFVwordPath
  vmap     <C-t>F <Plug>CtrlSFVwordExec
  nmap     <C-t>m <Plug>CtrlSFCwordPath
  nmap     <C-t>p <Plug>CtrlSFPwordPath
  nnoremap <C-t>o :CtrlSFOpen<CR>
  nnoremap <C-t>t :CtrlSFToggle<CR>
  inoremap <C-O>t <Esc>:CtrlSFToggle<CR>
endf

func! BufferCd () abort
  let buffer_path = utils#git_path()
  if !empty(buffer_path)
    exec 'cd '. buffer_path
    echon 'Changed to: ' . buffer_path
  else
    echon 'Unable to cd into: ' . buffer_path
  endif
endf

function s:OpenCommitInBrowser() abort
  execute 'GBrowse ' . expand('<cword>')
endfunction

" Return output of command in a new buffer
" Ref: https://stackoverflow.com/questions/49078827/can-listings-in-the-awful-more-be-displayed-instead-in-a-vim-window
function! Redir(cmd)
    for win in range(1, winnr('$'))
        if getwinvar(win, 'scratch')
            execute win . 'windo close'
        endif
    endfor
    if a:cmd =~ '^!'
        execute "let output = system('" . substitute(a:cmd, '^!', '', '') . "')"
    else
        redir => output
        execute a:cmd
        redir END
    endif
    vnew
    let w:scratch = 1
    setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile
    call setline(1, split(output, "\n"))
endfunction

" User commands
func! s:DefineCommands () abort
  " Shorthand for creating nxo mappings
  " Ref: https://www.reddit.com/r/vim/comments/3gpqjs/comment/cu0abeh/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
  command! -nargs=1 NXOnoremap nnoremap <args><Bar>xnoremap <args><Bar>onoremap <args>

  " Call command and remove carriage return
  command! -nargs=1 -complete=shellcmd CallCleanCommand call s:CallCleanCommand(<f-args>)
  command! CleanCR call s:CleanCR()
  command! CleanTrailingSpaces call s:CleanTrailingSpaces()

  command! -bar CBrowse call s:OpenCommitInBrowser()

  command! -nargs=1 Redir silent call Redir(<f-args>)

  command! Bcd call BufferCd()
  nnoremap <silent> <leader>cd <cmd>Bcd<cr>

  " Toggle scrolloff
  " nnoremap <Leader>zz :let &scrolloff=999-&scrolloff<CR>
  command! -bar ToggleScroll :call s:ToggleScroll()
  nnoremap <Leader>zz <cmd>ToggleScroll<cr>
  let &scrolloff=5

  " Background color toggle
  command! ToggleBg call g:ToggleBg()
  nnoremap <silent><leader>tb :ToggleBg<CR>

  " Tab config toggle
  command! -nargs=? SetTab call g:SetTab(<q-args>)
  nnoremap <silent><leader>st :SetTab<CR>

  " Call SudoSave (Vim only)
  command! -nargs=? -complete=buffer SudoSave
        \ call SudoSave(<q-args>)

  command! -nargs=? -bang -bar Emoji call Emoji(<q-args>, <bang>0, 'n')
  inoremap <c-x><c-r> <cmd>call Emoji('', 0, 'i')<cr>

  " Open terminal
  if has('nvim')
    command! Term :term
    command! -bar Vterm :vs|te
    command! -bar Sterm :sp|te
    augroup custom_term
      function s:NeovimTerminalStartup() abort
        setlocal nonumber norelativenumber bufhidden=hide
        startinsert
      endfunction
      autocmd!
      autocmd TermOpen * call s:NeovimTerminalStartup()
    augroup END
  else
    " in Vim you can list open terminal windows with 'call term_open()'
    command! Term :terminal ++curwin
    command! Vterm :vert term
    command! Sterm :term
    augroup custom_term
      autocmd!
      autocmd TerminalOpen * setlocal nonumber norelativenumber bufhidden=hide
    augroup END
  endif

  " Terminal mappings
  nnoremap <leader>te :Term<cr>
  nnoremap <leader>tv :Vterm<cr>
  nnoremap <leader>ts :Sterm<cr>

  " Buffer management
  " BCloseCurrent defined in plugin/bclose.vim
  command -bar BCloseOthers :%bd|e#|bn|bd
  command! -bar BCloseAllBuffers :%bd

  " Close all buffers but current one
  " noremap <leader><S-Tab> <cmd>BCloseOthers<CR>
  " Close current buffer without affecting opened windows
  " See definition in plugin/bclose.vim
  " nmap <leader><Tab> <Plug>BCloseCurrent

  " Vim buffet similar commands
  " noremap <leader><Tab> :Bw<CR>
  " noremap <Leader><S-Tab> :Bonly<CR>
  " noremap <Leader><S-Tab> :Bw!<CR>
  " noremap <C-t> :tabnew split<CR>


  " Use lf to select files to open in vim
  " NOTE: It does not work on nvim
  command! -bar -complete=dir -nargs=? LF call LF(<q-args>)

  " Create new txt file
  command! -nargs=? -complete=customlist,fzftxt#completion NTxt call fzftxt#open(<q-args>)

  " clear search
  command! -nargs=0 CleanSearch :nohlsearch

  " BlameLine
  command! -bar -nargs=? BlameLine call BlameLine(<q-args>)

  " Commands for diffget. Useful when resolving conflicts.
  " Open fugitive `:Git` and open conflicted file in vsplit `dv` (Gvdiffsplit)
  " Cursor must be on conflict hunk. E.g. `]n` and `[n`
  " Select the changes on the left
  command! -bar GitSelectLeft :diffget //2
  " grab the changes on the right
  command! -bar GitSelectRight :diffget //3

  " Use as :Mkdr! for creating the path of a buffer which path doesn't exit
  command! -bar -bang -nargs=* Mkdr call utils#mkdir(<q-args>, <bang>0)

  " Change position of window
  command! -bar -nargs=0 WToHorizontal :execute "normal! \<C-w>t\<C-w>K"
  command! -bar -nargs=0 WToVertical :execute "normal! \<C-w>t\<C-w>H"
endf

func! s:RemapAltUpDownNormal () abort
  " move selected lines up one line
  vnoremap <silent><A-up> :m '<-2<CR>gv=gv

  " move selected lines down one line
  vnoremap <silent><A-down> :m '>+1<CR>gv=gv

  " move current line up one line
  nnoremap <silent><A-up> :<C-u>m .-2<CR>==

  " move current line down one line
  nnoremap <silent><A-down> :<C-u>m .+1<CR>==

  " move current line up in insert mode
  inoremap <silent><A-up> <Esc>:m .-2<CR>==gi

  " move current line down in insert mode
  inoremap <silent><A-down> <Esc>:m .+1<CR>==gi
endf

func! s:RemapAltUpDownSpecial () abort
  " NOTE: vim requires extra handling for special maps
  " (specially alt). The options are mapping the keycode directly
  " like below or first set the keycode to be used
  " set <A-up>=[1;3A
  " Ref: https://superuser.com/questions/508655/map-shift-f3-in-vimrc
  " Ref: https://vim.fandom.com/wiki/Mapping_fast_keycodes_in_terminal_Vim

  " move selected lines up one line
  vnoremap <silent><Esc>[1;3A :m '<-2<CR>gv=gv

  " move selected lines down one line
  vnoremap <silent><Esc>[1;3B :m '>+1<CR>gv=gv

  " move current line up one line
  nnoremap <silent><Esc>[1;3A :<C-u>m .-2<CR>==

  " move current line down one line
  nnoremap <silent><Esc>[1;3B :<C-u>m .+1<CR>==

  " move current line up in insert mode
  inoremap <silent><Esc>[1;3A <Esc>:m .-2<CR>==gi

  " move current line down in insert mode
  inoremap <silent><Esc>[1;3B <Esc>:m .+1<CR>==gi
endf

" No longer in used
" func! s:RemapAltUpDownJK () abort
"   " move selected lines up one line
"   vnoremap <silent><C-k> :m '<-2<CR>gv=gv
"
"   " move selected lines down one line
"   vnoremap <silent><C-j> :m '>+1<CR>gv=gv
"
"   " move current line up one line
"   nnoremap <silent><C-k> :<C-u>m .-2<CR>==
"
"   " move current line down one line
"   nnoremap <silent><C-j> :<C-u>m .+1<CR>==
"
"   " move current line up in insert mode
"   inoremap <silent><C-k> <Esc>:m .-2<CR>==gi
"
"   " move current line down in insert mode
"   inoremap <silent><C-j> <Esc>:m .+1<CR>==gi
" endf

func! s:RemapVisualMultiUpDown () abort
  " Map usual <C-Up> <C-Down> to <C-y> and <C-h> for use in vim windows
  nmap <C-y> <Plug>(VM-Select-Cursor-Up)
  nmap <C-h> <Plug>(VM-Select-Cursor-Down)

  " Other ways to remap
  " let g:VM_custom_remaps = { '<C-h>': 'Up', '<C-H>': 'Down' }
  " let g:VM_maps = { 'Select Cursor Down': '<C-h>', 'Select Cursor Up': '<C-y>' }
  " let g:VM_maps["Select Cursor Down"] = '<C-h>'
  " let g:VM_maps["Select Cursor Up"]   = '<C-H>'
endf

func! s:MoveLinesBlockMapsWin () abort
  " silent call s:RemapAltUpDownJK()
  silent call s:RemapAltUpDownNormal()
  if exists(':Repeatable')
    Repeatable nnoremap <silent>mlu :<C-U>m-2<CR>==
    Repeatable nnoremap <silent>mld :<C-U>m+<CR>==
  endif

  " if !has('nvim')
  "   silent call s:RemapVisualMultiUpDown()
  " endif
endf

func! s:MoveLinesBlockMapsLinux () abort
  " Allow motion mlu/d
  if exists(':Repeatable')
    Repeatable nnoremap <silent>mlu :<C-U>m-2<CR>==
    Repeatable nnoremap <silent>mld :<C-U>m+<CR>==
  endif

  silent call s:RemapAltUpDownNormal()

  " silent call s:RemapAltUpDownJK()
  " if has('nvim')
  "   silent call s:RemapAltUpDownNormal()
  " else
  "   silent call s:RemapAltUpDownSpecial()
  " endif
endf

func! s:MoveLinesBlockMapsGvim () abort
  " Allow motion mlu/d
  if exists(':Repeatable')
    Repeatable nnoremap <silent>mlu :<C-U>m-2<CR>==
    Repeatable nnoremap <silent>mld :<C-U>m+<CR>==
  endif

  " silent call s:RemapAltUpDownJK()
  silent call s:RemapAltUpDownNormal()
endf

func! s:MoveLinesBlockMapsMac () abort
  " Allow motion mlu/d
  if exists(':Repeatable')
    Repeatable nnoremap <silent>mlu :<C-U>m-2<CR>==
    Repeatable nnoremap <silent>mld :<C-U>m+<CR>==
  endif

  " silent call s:RemapAltUpDownJK()

  " Not needed remap on regular vim
  if has('nvim')
    silent call s:RemapAltUpDownNormal()
  endif
endf

func s:SetUndodir () abort
  let undo_dir = ''

  if has('nvim')
    let undo_dir = expand('~/.cache/nvim/undodir')
  else
    let undo_dir = expand('~/.cache/vim/undodir')
  endif

  if !isdirectory(undo_dir)
    " Make directory. This should work in windows and linux
    " and it should not fail if the directory already exists
    " Vim used to fail before patch 8.0.1708
    silent call mkdir(undo_dir, 'p')

    " NOTE: Kept as reference
    " if g:is_windows
    "   silent call system('powershell -NoLogo -NoProfile -NonInteractive -Command New-Item -Path "' . undo_dir . '" -ItemType Directory -ErrorAction SilentlyContinue')
    " else
    "   silent call system('mkdir -p "' . undo_dir . '"')
    " endif
  endif

  let &undodir = undo_dir

  if has('persistent_undo')
    set undofile        " keep an undo file (undo changes after closing)
  endif
endf

function! config#CurrentOS ()
  let known_os = 'unknown'

  " Remove annoying error log for MSYS bash and zsh on start (uname not
  " available)
  " echo ''
  if has("gui_mac") || has('mac') || has('macunix')
    let g:is_mac = 1
    let known_os = s:mac
  " TODO: Fix windows falling in this detection
  " Gitbash and Msys zsh does not report ming on first run
  elseif $MSYSTEM =~? 'cygwin' || $MSYSTEM =~? 'MINGW' || $MSYSTEM =~? 'MSYS' || $IS_GITBASH == 'true'
    if $IS_POWERSHELL == 'true' || $IS_CMD == 'true'
      let g:is_gitbash = 0
    else
      let g:is_gitbash = 1
    endif

    set shell=cmd
    set shellcmdflag=/c
    let g:is_windows = 1
    let known_os = s:windows
  elseif has('win32') || has("gui_win32") || $OS == 'Windows_NT'
    set shell=cmd
    set shellcmdflag=/c
    let g:is_windows = 1
    let known_os = s:windows
  elseif has('linux')
    let known_os = s:linux
    let g:is_linux = 1
    if $IS_FROM_CONTAINER == 'true'
      let g:is_container = 1
    elseif has('wsl') || system('cat /proc/version') =~ '[Mm]icrosoft'
      let g:is_wsl = 1
    elseif executable('termux-open-url') || $IS_TERMUX =~ 'true'
      " Don't want to relay on config settings but it will do for now
      " untested way: command -v termux-setup-storage &> /dev/null
      " the termux-setup-storage should only exist on termux
      let g:is_termux = 1
    endif
  else
    exec "normal \<Esc>"
    throw "unknown OS: " . substitute(system('uname'), '\n', '', 'g')
  endif

  return known_os
endfunction

" func! s:ToggleBg ()
"   let highlight_value = execute('hi Normal')
"   let ctermbg_value = matchstr(highlight_value, 'ctermbg=\zs\S*')
"   let guibg_value = matchstr(highlight_value, 'guibg=\zs\S*')

"   if ctermbg_value == '' && guibg_value ==? ''
"     silent execute('hi ' . g:theme_normal)
"   else
"     silent execute('hi Normal guibg=NONE ctermbg=NONE')
"   endif
" endfunction

function BlameLine(...) abort
  let commit_count = empty(a:1) ? '5' : a:1
  let root = utils#find_root('.git')
  let line = line('.')
  let file = expand('%:p')
  let name = expand('%:t')
  if !filereadable(file)
    return
  endif

  " Command
  let args = 'git -C ' . shellescape(root) . ' log -n ' . commit_count . ' -u -L ' . line .. ',+1:' .. shellescape(file)
  let blame_out = system(args)
  if empty(blame_out)
    return
  endif
  let buff_name = 'Blame ' . name

  " Display blame on buffer
  enew
  exec 'silent! file ' . buff_name
  pu = blame_out
  pu = ''
  silent call execute('normal ggdd')
  setlocal nomod readonly
  setlocal filetype=git
  setlocal foldmethod=syntax
endfunction

" Vim only version
function! LF(path = '')
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

function! SudoSave (fileName) abort
  let file = ''

  if ! executable('sudo')
    echo 'No sudo available'
    return
  endif

  if empty(a:fileName)
    let file = "%"
  else
    let file = a:fileName
  endif

  exec 'write !sudo tee ' . file
endfunction

" func! s:NetrwMapping () abort
"   nnoremap <leader>q <cmd>quit<cr>
" endfunction

function OpenNetrw() abort
  let cur_dir = getcwd()
  let cur_file = expand('%:t')
  let file_dir = expand('%:p:h')

  try
    " NOTE: set nohidden to avoid orphan buffers
    set nohidden

    " Check if Netrw is open
    let netrw_open = 0
    " let buffers = range(1, bufnr('$'))
    " for buffer in buffers
    "   if bufname(buffer) =~ 'NetrwTreeListing'
    "     let netrw_open = 1
    "     break
    "   endif
    " endfor
    let buffers = getbufinfo()
    for buffer in buffers
      if buffer.name =~ 'NetrwTreeListing'
        let netrw_open = 1
        break
      endif
    endfor

    if cur_file != 'NetrwTreeListing' && !netrw_open
      exec 'cd ' . file_dir
      let gitpath = utils#git_path()
      " WARN: Need to call Lex with the path or netrw will open on the
      " previous window.
      " Issue: https://groups.google.com/g/vim_dev/c/np1yarYC4Uo
      silent exec 'Lex! ' . file_dir
      " exec 'Ntree ' . file_dir
      exec 'cd ' . gitpath
      " NOTE: Need to check for an optional trailing '*'
      silent call search(' ' . cur_file . '\*\?$')
      echo 'Opening ' . cur_file
    else
      Lex!
    endif
  catch /.*/
    " rollback to curr dir
    exec 'cd ' . cur_dir
  finally
    set hidden
  endtry
endfunction

func! s:Set_netrw () abort
  let g:netrw_banner = 0
  let g:netrw_browse_split = 4
  let g:netrw_altv = 1
  let g:netrw_winsize = 25
  let g:netrw_liststyle = 3
  let g:netrw_fastbrowse = 0

  " NOTE: Makes netrw buffer stick around after :bd
  " let g:netrw_liststyle = 3
  " Workarounds:
  " - :%bd to close all opened buffers (it also kills netrw)
  " - Netrw creates a directory buffer (as showed by buffet) so kille that one
  "   with :bd <buffer_id> instead of netrw
  " - Set 'g:netrw_fastbrowse = 0' (buffers hide but still leaves hidden
  "   orphans)
  " - Do not use 'g:netrw_listsyle = 3' (treeview) though still leaves hidden
  "   orphan buffers
  " More: https://github.com/tpope/vim-vinegar/issues/13

  nnoremap <leader>ve <cmd>call OpenNetrw()<cr>

  " nnoremap <leader>se <cmd>Hex<cr>

  autocmd FileType netrw setl bufhidden=delete
  " autocmd FileType netrw setl bufhidden=wipe

  " augroup netrw_mapping
  "   autocmd!
  "   autocmd filetype netrw call s:NetrwMapping()
  " augroup END
endfunction

function! config#windows_short_path(path) abort
  " From fzf.vim
  " Changes paths like 'C:/Program Files' that have spaces into C:/PROGRA~1
  " which is nicer as we avoid escaping
  return split(system('for %A in ("'. a:path .'") do @echo %~sA'), "\n")[0]
endfunction

func! config#before () abort
  " Can be used to set different undodir between vim and nvim
  silent call s:SetUndodir()

  " Fzf configs
  let g:fzf_vim = {}
  let g:fzf_history_dir = '~/.cache/fzf-history'

  silent call s:Set_netrw()
  silent call s:Set_os_specific_before()
  silent call s:SetBufferOptions()
  silent call s:SetConfigurationsBefore()
endf

func! config#after () abort
  silent call s:Set_user_keybindings()
  silent call s:Set_os_specific_after()
  silent call s:SetConfigurationsAfter()
endf

