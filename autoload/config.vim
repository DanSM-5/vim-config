
let s:mac = 'mac'
let s:windows = 'windows'
let s:linux = 'linux'
let s:termux = 'termux'
let s:wsl = 'wsl'
" if shell is powershell.exe, system calls will be utf16 files with BOM
let s:cleanrgx = '[\xFF\xFE\x01\r\n]'

let g:is_linux = 0
let g:is_wsl = 0
let g:is_gitbash = 0
let g:is_windows = 0
let g:is_mac = 0
let g:is_termux = 0
let g:is_container = 0

" General options
let g:fzf_base_options = [ '--multi', '--ansi', '--bind', 'alt-c:clear-query', '--input-border' ]
let g:fzf_bind_options = g:fzf_base_options + [
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
let g:fzf_preview_options = g:fzf_bind_options + [
      \ '--layout=reverse',
      \ '--preview-window', '60%,wrap',
      \ '--preview', 'bat -pp --color=always --style=numbers {}'
      \ ]

func! s:SetConfigurationsBefore () abort
  silent call s:SetCamelCaseMotion()
  silent call s:SetRG()
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

  " Move to next/previous tab
  " nnoremap <silent> ]T <cmd>tabnext<cr>
  " nnoremap <silent> [T <cmd>tabprevious<cr>
  nnoremap <silent> ]<tab> <cmd>tabnext<cr>
  nnoremap <silent> [<tab> <cmd>tabprevious<cr>

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

  " Completion menu
  " Show menu even when there is a single match
  " Auto select best match but do not insert
  " set completeopt=menu,menuone,preview,noselect,noinsert,popup
  set completeopt=menuone,noinsert,popup

  if has('nvim')
    " diffopt
    " Default
    " set diffopt=internal,filler,closeoff
    " set diffopt=internal,filler,closeoff,linematch:60
    " set diffopt=internal,filler,closeoff,algorithm:histogram,context:5,linematch:60
    " neovim implements 'linematch:{n}'
    " Ref: https://github.com/neovim/neovim/pull/14537
    set diffopt=internal,filler,closeoff,indent-heuristic,linematch:120,algorithm:histogram

    " Set signcolumn
    set signcolumn=auto:2
  else
    set diffopt=internal,filler,closeoff,indent-heuristic,algorithm:histogram

    " Set signcolumn
    set signcolumn=auto

    " Undercurl (not working)
    " let &t_Cs = "\e[4:3m"
    " let &t_Ce = "\e[4:0m"
  endif

  " Set wrap on lines
  set wrap

  " Briefly move cursor to matching pair: [], {}, ()
  " set showmatch
  " Add angle brackets as matching pair.
  set matchpairs+=<:>

  " Reduce default update time to 1 second
  set updatetime=1000

  " Explicit default of incsearch.
  " Visually show and highlight search matches.
  set incsearch

  " Recognize `@` symbol in filenames for things like `gf`
  set isfname+=@-@
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

    autocmd VimLeave * call echoraw(&t_SI)
  endif

endf

func! s:SetBufferOptions () abort
  " Start with unix fileformat by default
  " But allow auto match other formats like
  " dos (windows), and mac
  set fileformats=unix,dos,mac

  " Appropriate width for a line
  set textwidth=120

  " Wrap lines at characters present in `breakat` rather than
  " on last fitting character on screen.
  set linebreak

  " Auto read changes on files made outside vim
  set autoread

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

  " Cache fugitive sid to avoid duplicate parsing
  let s:fugitive_sid = 0
  let s:MapRef = 0
  augroup fugitiveCustom
    " NOTE: Hack to bring back the 'a' map 😎

    function! s:fugitive_keymap_set() abort
      let sid = 0

      if type(s:fugitive_sid) != 1
        let sid = utils#get_sid('autoload.fugitive.vim')

        if !sid
          return
        endif

        let s:fugitive_sid = sid
        " Build func ref
        let s:MapRef = function("<SNR>".sid.'_Map')
      else
        if type(s:MapRef) != 2
          let sid = s:fugitive_sid
          let s:MapRef = function("<SNR>".sid.'_Map')
        endif
      endif

      " Create the keymap
      call s:MapRef('n', 'a', ":<C-U>execute <SID>Do('Toggle',0)<CR>", '<silent>')
    endfunction
    au!
    autocmd FileType fugitive silent call s:fugitive_keymap_set()
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

  " Map clipboard functions
  xnoremap <silent> <Leader>y :<C-u>call clipboard#yank()<cr>
  nnoremap <expr> <Leader>p clipboard#paste('p')
  nnoremap <expr> <Leader>P clipboard#paste('P')
  xnoremap <expr> <Leader>p clipboard#paste('p')
  xnoremap <expr> <Leader>P clipboard#paste('P')

  " Quick buffer overview an completion to change
  nnoremap <leader>gb :<C-u>ls<CR>:b<Space>

  " Quick buffer overview an completion to change
  nnoremap g` :<C-u>marks<CR>:normal! `

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
  " nnoremap <C-s> :<C-u>w<CR>
  " vnoremap <C-s> :<C-u>w<CR>
  cnoremap <C-s> <cmd>write<cr>

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
  nnoremap [Q <cmd>cfirst<cr>zz
  nnoremap ]Q <cmd>clast<cr>zz
  " Location list navigation
  nnoremap [l <cmd>lnext<cr>zz
  nnoremap ]l <cmd>lprev<cr>zz
  nnoremap [L <cmd>lfirst<cr>zz
  nnoremap ]L <cmd>llast<cr>zz

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
  nnoremap <leader>rs :%s/\<<C-r><C-w>\>//g<left><left>
  " Similar to above but apply change to quickfix
  nnoremap <leader>rq :cdo %s/\<<C-r><C-w>\>//g<left><left>
  " Alternative to set same word as initial value
  " nnoremap <leader>rq :cdo %s/\<<C-r><C-w>\>/<C-r><C-w>/g<left><left>

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

  " Delete marks in line under cursor
  nnoremap <leader>`d <cmd>call utils#delete_marks_curr_line()<cr>

  " Reselect previous yank
  " This obscures default gV that prevents reselection of :vmenu commands
  nnoremap gV `[v`]

  " Search in visual selected area
  xnoremap g/ <esc>/\%V
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
  " set shell=pwsh
  " let &shellcmdflag = '-NoLogo -NonInteractive -NoProfile -ExecutionPolicy Bypass -Command Remove-Alias -Force -ErrorAction SilentlyContinue tee;'
  " set shellxquote=
  " set shellpipe=>%s\ 2>&1
  " set shellredir=>%s\ 2>&1

  " neovim recommended `:h shell-powershell`
  " let &shellcmdflag = '-NoLogo -NonInteractive -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues[''Out-File:Encoding'']=''utf8'';$PSStyle.OutputRendering=''plaintext'';Remove-Alias -Force -ErrorAction SilentlyContinue tee;'

  " Ensure cmd shell
  set shell=cmd
  set shellcmdflag=/c

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
    let &grepprg = 'rg --vimgrep --no-heading --smart-case --no-ignore --engine=pcre2 --hidden -g "!plugged" -g "!.git" -g "!node_modules"'
    set grepformat=%f:%l:%c:%m
  endif
endf

" Search using fzfrg function
" on visual selected text.
" Multiline search is trucated to first line
function ExecuteRGVisual() abort
  let text = utils#get_selected_text()
  if len(text) == 0
    return
  endif

  " Use first line
  let text = text[0]
  " Remove trailing space
  let text = trim(text)
  call fzfcmd#fzfrg_rg(text, 0)
endfunction

" Grep a string on current file or
" in all files.
function QueryGrep(query, all) abort
  let escaped = escape(a:query, '<>\/()[]{}.*+^$?|"'."'")
  if a:all
    execute 'silent grep "'.escaped.'"'
  else
    execute 'silent grep "'.escaped.'" %'
  endif
endfunction

" Wrapper to grep last visual selected text
" Multiline search is trucated to first line
function GrepVisual() abort
  let text = utils#get_selected_text()
  if len(text) == 0
    return
  endif

  " Use first line
  let text = text[0]
  " Remove trailing space
  let text = trim(text)
  call QueryGrep(text, 1)
endfunction

" Vimgrep last search to fill the quickfix list
function SearchGrep(all) abort
  if a:all
    " Also consider using :grep
    exec "normal! :\<C-u>vimgrep /\<C-r>//j **/* \<cr>|:cw\<cr>"
  else
    exec "normal! :\<C-u>vimgrep /\<C-r>//j %\<cr>|:cw\<cr>"
  endif
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
  command! -nargs=* -bang CPrj call fzfcmd#change_project(<q-args>, g:fzf_bind_options, <bang>0)
  command! -nargs=* -bang RG call fzfcmd#fzfrg_rg(<q-args>, <bang>0)
  command! -nargs=* -bang Rg call fzfcmd#fzfrg_fuzzy(<q-args>, <bang>0)
  command! -nargs=* -bang Lg call fzfcmd#fzfrg_current(<q-args>, <bang>0)
  command! -nargs=* -bang RgHistory call fzfcmd#fzfrg_history(<q-args>, <bang>0)
  command! -nargs=* -bang Highlights call fzfcmd#highlights(<q-args>, <bang>0)

  command! -bang -nargs=? -complete=dir Files
    \ call fzfcmd#fzf_files(<q-args>, g:fzf_preview_options, <bang>0)
  command! -bar -bang -nargs=? -complete=buffer Buffers call fzfcmd#fzf_buffers(<q-args>, <bang>0)

  " NOTE: Under gitbash previews doesn't work due to how fzf.vim
  " builds the paths for the bash.exe executable
  " On powershell, however, vim has issues not showing preview window
  " and it may get stuck as in git bash if called before fzf#vim#with_preview
  if g:is_gitbash || (!has('nvim') && g:is_windows)
    command! -bang -nargs=? GFiles
      \ call fzfcmd#fzf_gitbash_files(<q-args>, g:fzf_preview_options, <bang>0)
  endif

  " fzf options with custom preview
  if g:is_windows || g:is_termux
    command! -bang -nargs=? -complete=dir FzfFiles
      \ call fzfcmd#fzf_files(<q-args>, g:fzf_preview_options, <bang>0)
    command! -bang -nargs=? -complete=dir GitFZF
      \ call fzfcmd#fzf_files(empty(<q-args>) ? utils#git_path() : <q-args>, g:fzf_preview_options, <bang>0)

  " fzf options that only include common bindings
  else

    command! -bang -nargs=? -complete=dir FzfFiles
      \ call fzfcmd#fzf_files(<q-args>, g:fzf_bind_options, <bang>0)
    command! -bang -nargs=? -complete=dir GitFZF
      \ call fzfcmd#fzf_files(empty(<q-args>) ? utils#git_path() : <q-args>, g:fzf_bind_options, <bang>0)
  endif


  " Set keymappings
  " Open File fullscreen
  nnoremap <A-p> <cmd>exec 'GitFZF ' . getcwd()<cr>
  " Open File
  nnoremap <C-P> <cmd>GitFZF<cr>
  " Open from project
  nnoremap <C-o>p <cmd>CPrj<cr>
  " Open from notes (txt)
  nnoremap <C-o>t <cmd>FTxt<cr>
  " Search word under the cursor
  nnoremap <leader>fr <cmd>call fzfcmd#fzfrg_rg(expand('<cword>'), 0)<cr>
  " Search visual selection using RG
  xnoremap <leader>fr <cmd>call ExecuteRGVisual()<cr>
  "
  nnoremap <leader>fq <cmd>call QueryGrep(expand('<cword>'), 1)<cr>
  xnoremap <leader>fq <cmd>call GrepVisual()<cr>
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

function! WinToTab() abort
  let win = win_getid()
  tab split
  call win_execute(win, 'close')
endfunction

function! ExecuteCmd(cmd) abort
  if a:cmd =~ '^!'
    execute "let output = system('" . substitute(a:cmd, '^!', '', '') . "')"
  else
    redir => output
    execute a:cmd
    redir END
  endif
  return output
endfunction

" Return output of command in a new buffer
" Ref: https://stackoverflow.com/questions/49078827/can-listings-in-the-awful-more-be-displayed-instead-in-a-vim-window
function! Redir(cmd)
    for win in range(1, winnr('$'))
        if getwinvar(win, 'scratch')
            execute win . 'windo close'
        endif
    endfor
    let output = ExecuteCmd(a:cmd)
    vnew
    let w:scratch = 1
    setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile
    call setline(1, split(output, "\n"))
endfunction

function! Eval(cmd) abort
  let output = ExecuteCmd(a:cmd)
  let output = split(output, "\n")
  put = output
endfunction

" User commands
func! s:DefineCommands () abort
  " Shorthand for creating nxo mappings
  " Ref: https://www.reddit.com/r/vim/comments/3gpqjs/comment/cu0abeh/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
  command! -nargs=1 NXOnoremap nnoremap <args><Bar>xnoremap <args><Bar>onoremap <args>

  " Call command and remove carriage return
  command! -nargs=1 -complete=shellcmd CallCleanCommand call s:CallCleanCommand(<f-args>)
  command! -nargs=0 CleanCR call s:CleanCR()
  command! -nargs=0 CleanTrailingSpaces call s:CleanTrailingSpaces()

  command! -bar CBrowse call s:OpenCommitInBrowser()

  command! -nargs=1 Redir silent call Redir(<f-args>)

  command! -nargs=1 Eval silent call Eval(<f-args>)

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

  command! -nargs=? -bang -bar Emoji call emoji#open(<q-args>, <bang>0, 'n')
  inoremap <c-x><c-r> <cmd>call emoji#open('', 0, 'i')<cr>

  " Open terminal
  if has('nvim')
    function! s:open_term(bang) abort
      if a:bang
        tabnew
      endif
      term
    endfunction
    command! -bang -bar Term call s:open_term(<bang>0)
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
    function! s:open_term(bang) abort
      if a:bang
        tabnew
      endif
      terminal ++curwin
    endfunction
    " in Vim you can list open terminal windows with 'call term_open()'
    command! -bang -bar Term call s:open_term(<bang>0)
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
  " command! -bar BCloseOthers :%bd|e#|bn|bd
  " command! -bar BCloseAllBuffers :%bd
  command! -bang -bar BCloseOthers call bda#bdo(<bang>0)
  command! -bang -bar BCloseAllBuffers call bda#bda(<bang>0)

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
  command! -bar -complete=dir -nargs=? LF call lf#lf(<q-args>)

  " Create new txt file
  command! -nargs=? -complete=customlist,fzftxt#completion NTxt call fzftxt#open(<q-args>)

  " clear search
  command! -nargs=0 CleanSearch :nohlsearch

  " BlameLine
  command! -bar -nargs=? BlameLine call BlameLine(<q-args>)

  " Commands for diffget. Useful when resolving conflicts (tree-way diff).
  " Open fugitive `:Git` and open conflicted file in vsplit `dv` (Gvdiffsplit)
  " Cursor must be on conflict hunk. E.g. `]n` and `[n` (`[c` and `]c` should
  " work as well in diff view mode)
  "
  " ```bash
  " git checkout `target`
  " git merge `merge`
  " ```
  "
  " Select the changes on the left (target)
  command! -bar GitSelectLeft :diffget //2 | diffupdate
  " grab the changes on the right (merge)
  command! -bar GitSelectRight :diffget //3 | diffupdate
  " Fugitive always set the buffer name with `//2` to the file to the left and
  " `//3` to the file to the right.

  " You can add the diff from one of the side buffers using `:diffput` or `dp` mapping.
  " Notice that `dp` does not require to run `:diffupdate` after
  "
  " In two-way diff you can use `do` mapping for `:diffget`
  "
  " Use `:only` from the main file to close the diff windows
  " or `:Gwrite` to save, stage and close the diff windows.
  "
  " Run `:Gwrite!` from target or merge to keep only changed from that file.
  " Be careful as this override the index.

  " Use as :Mkdr! for creating the path of a buffer which path doesn't exit
  command! -bar -bang -nargs=* Mkdr call utils#mkdir(<q-args>, <bang>0)

  " Change position of window
  command! -bar -nargs=0 WToHorizontal :execute "normal! \<C-w>t\<C-w>K"
  command! -bar -nargs=0 WToVertical :execute "normal! \<C-w>t\<C-w>H"
  command! -bar -nargs=0 WToTab silent call WinToTab()

  command! -bar -bang -nargs=* QueryGrep call QueryGrep(<q-args>, <bang>0)
  command! -bar -bang -nargs=0 SearchGrep call SearchGrep(<bang>0)
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


func! s:MoveLinesBlockMapsWin () abort
  " silent call s:RemapAltUpDownJK()
  silent call s:RemapAltUpDownNormal()
  if exists(':Repeatable')
    Repeatable nnoremap <silent>mlu :<C-U>m-2<CR>==
    Repeatable nnoremap <silent>mld :<C-U>m+<CR>==
  endif

endf

func! s:MoveLinesBlockMapsLinux () abort
  " Allow motion mlu/d
  if exists(':Repeatable')
    Repeatable nnoremap <silent>mlu :<C-U>m-2<CR>==
    Repeatable nnoremap <silent>mld :<C-U>m+<CR>==
  endif

  silent call s:RemapAltUpDownNormal()

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
  if has("gui_mac") || has('mac') || has('macunix') || $OSTYPE == 'darwin'
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

    " set shell=cmd
    " set shellcmdflag=/c
    let g:is_windows = 1
    let known_os = s:windows
  elseif has('win32') || has("gui_win32") || $OS == 'Windows_NT'
    " set shell=cmd
    " set shellcmdflag=/c
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

function! SudoSave (fileName) abort
  let file = ''

  if has('nvim')
    echo 'Not supported'
    return
  endif

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

  " Set bufhidden=wipe to prevent netrw buffers hanging around
  augroup netrw
    autocmd!
    autocmd FileType netrw setlocal bufhidden=wipe
  augroup end
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

