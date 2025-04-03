" Equivalent of lua/nvimstart.lua for neovim
" This script loads vim only code

let g:gitgutter_sign_added = '✚'
" let g:gitgutter_sign_modified = '✹'
let g:gitgutter_sign_modified = '󰜥'
let g:gitgutter_sign_removed = '✘'
let g:gitgutter_sign_removed_first_line = ''
let g:gitgutter_sign_removed_above_and_below = ''
let g:gitgutter_sign_modified_removed   = '󱣳'

" Defaults:
" let g:gitgutter_sign_added              = '+'
" let g:gitgutter_sign_modified           = '~'
" let g:gitgutter_sign_removed            = '_'
" let g:gitgutter_sign_removed_first_line = '‾'
" let g:gitgutter_sign_removed_above_and_below = '_¯'
" let g:gitgutter_sign_modified_removed   = '~_'

" Git gutter settings
" Navigation
nmap ]c <Plug>(GitGutterNextHunk)
nmap [c <Plug>(GitGutterPrevHunk)
" Text Object
omap ih <Plug>(GitGutterTextObjectInnerPending)
omap ah <Plug>(GitGutterTextObjectOuterPending)
xmap ih <Plug>(GitGutterTextObjectInnerVisual)
xmap ah <Plug>(GitGutterTextObjectOuterVisual)
" Actions
nnoremap <leader>hr <Plug>(GitGutterUndoHunk)
nnoremap <leader>hR <cmd>Git checkout -- %<cr>
nnoremap <leader>hU <cmd>Git reset -- %<cr>
nnoremap <leader>hS <cmd>Git add -- %<cr>
" `<leader>hs` is already implemented by gitgutter
" and `<leader>hu` (unstage) is not possible. It defaults
" to GitGutterUndoHunk same as `<leader>hr`

" Quickfix
function s:Gqf(bang) abort
  if a:bang
    GitGutterQuickFixCurrentFile | copen
  else
    GitGutterQuickFix | copen
  endif
endfunction

command! -bang -bar Gqf call s:Gqf(<bang>0)

" NOTE: Uncomment to enable gitgutter logs
" let g:gitgutter_log = 1

if executable('rg')
  let g:gitgutter_grep = 'rg'
endif

" Quickfix movement
nnoremap ]q <cmd>silent! cnext<cr>
nnoremap [q <cmd>silent! cprev<cr>

function! s:VimConfig() abort
  " Remap vinegar to <leader>-
  if hasmapto('<Plug>VinegarUp')
    nunmap -
    nmap <leader>- <Plug>VinegarUp
  endif

  " runtime utils/vimsuggest_config.vim
endfunction

autocmd VimEnter * call s:VimConfig()

" Remap vinegar to <leader>-
" autocmd VimEnter *
"     \  if hasmapto('<Plug>VinegarUp')
"     \|   nunmap -
"     \|   nmap <leader>- <Plug>VinegarUp
"     \| endif

if g:is_windows
  " NOTE:
  " Vim from scoop is compiled with lua
  " but lua binary from scoop is not in the path (shimmed)
  " The alternative is to set &luadll manually
  " Check if exists and add it. This will cause `has('lua')` to return 1.
  let lua_dll_dir = expand('~/scoop/apps/lua/current/bin')
  if isdirectory(lua_dll_dir)
    let &luadll = lua_dll_dir . '\lua54.dll'

    " use embedded lua for `:Flog`
    let g:flog_use_internal_lua = 1
  endif
else
  if has('lua')
    " If vim is compiled with lua, use that one
    let g:flog_use_internal_lua = 1
  endif
endif

" Set wildmenu completions
set wildmenu
set wildmode=list:longest,full

" clear search highlight
nnoremap <silent> <c-l> :<c-u>nohlsearch<cr>

" augroup CursorColorOnRecord
"   autocmd!
"   autocmd RecordingEnter * silent execute('hi Cursor guifg=#282c34 guibg=#16e81e') 
"   autocmd!
"   autocmd RecordingLeave * silent execute('hi ' . g:theme_cursor) 
" augroup END

" Change , and ; behavior
" Ref: https://www.reddit.com/r/vim/comments/43j5jr/comment/cziloc7
" function! s:InitConsistentRepeat(command)
"     if a:command =~# '[FT]'
"         noremap ; ,
"         noremap , ;
"     else
"         silent! unmap ;
"         silent! unmap ,
"     endif
"     return a:command
" endfunction

" noremap <expr> f <SID>InitConsistentRepeat('f')
" noremap <expr> t <SID>InitConsistentRepeat('t')
" noremap <expr> F <SID>InitConsistentRepeat('F')
" noremap <expr> T <SID>InitConsistentRepeat('T')


" Ref: https://www.reddit.com/r/vim/comments/3gpqjs/comment/cu0abeh
if exists('*getcharsearch')
  NXOnoremap <expr>; getcharsearch().forward ? ';' : ','
  NXOnoremap <expr>, getcharsearch().forward ? ',' : ';'
else
  " ~~Will probably implement, but it's not simple considering multi-bytes, etc.~~
  " It turns out doable. TODO: support Input Method
  "
  " command! -nargs=1 NOnoremap nnoremap <args><Bar> onoremap <args>
  " I use the mark `z`(as well the register `z`) exclusively in scripts.
  " NOnoremap <silent>F :<C-u>execute 'silent! normal! mzf'.nr2char(getchar()).'g`z'.v:count1.','<CR>
  " xnoremap <silent>F :<C-u>execute 'silent! normal! mzf'.nr2char(getchar()).'g`zgv'.v:count1.','<CR>
  " NOnoremap <silent>T :<C-u>execute 'silent! normal! mzt'.nr2char(getchar()).'g`z'.v:count1.','<CR>
  " xnoremap <silent>T :<C-u>execute 'silent! normal! mzt'.nr2char(getchar()).'g`zgv'.v:count1.','<CR>

  " Change , and ; behavior
  " Ref: https://www.reddit.com/r/vim/comments/43j5jr/comment/cziloc7
  function! s:InitConsistentRepeat(command)
      if a:command =~# '[FT]'
          noremap ; ,
          noremap , ;
      else
          silent! unmap ;
          silent! unmap ,
      endif
      return a:command
  endfunction

  noremap <expr> f <SID>InitConsistentRepeat('f')
  noremap <expr> t <SID>InitConsistentRepeat('t')
  noremap <expr> F <SID>InitConsistentRepeat('F')
  noremap <expr> T <SID>InitConsistentRepeat('T')
endif


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
    \ "nfile"   : "<C-L>",
    \ "pfile"   : "<C-H>",
    \ "pquit"   : "q",
    \ "loclist" : "<C-Q>",
    \ "chgmode" : "M",
    \ "stop"    : "<C-C>",
    \ }

    " nfile   : "<C-D>",
    " pfile   : "<C-U>",

  nmap     <C-s>f <Plug>CtrlSFCwordPrompt
  nmap     <C-s>w <Plug>CtrlSFCwordExec
  vmap     <C-s>w <Plug>CtrlSFVwordExec
  nmap     <C-s>s <Plug>CtrlSFPwordExec
  nnoremap <C-s>o <cmd>CtrlSFOpen<CR>
  nnoremap <C-s><C-s> <cmd>CtrlSFToggle<CR>
endf


" Quickfix navigation
nnoremap <expr> ]q '<cmd>'.v:count1.'cnext<cr>zvzz'
nnoremap <expr> [q '<cmd>'.v:count1.'cprev<cr>zvzz'
nnoremap <expr> ]Q '<cmd>'.(v:count != 0 ? v:count : '').'clast<cr>zvzz'
nnoremap <expr> [Q '<cmd>'.(v:count != 0 ? v:count : '').'cfirst<cr>zvzz'
nnoremap <expr> ]<C-q> '<cmd>'.v:count1.'cnfile<cr>zvzz'
nnoremap <expr> [<C-q> '<cmd>'.v:count1.'cpfile<cr>zvzz'

" Location list navigation
nnoremap <expr> ]l '<cmd>'.v:count1.'lnext<cr>zvzz'
nnoremap <expr> [l '<cmd>'.v:count1.'lprev<cr>zvzz'
nnoremap <expr> ]L '<cmd>'.(v:count != 0 ? v:count : '').'llast<cr>zvzz'
nnoremap <expr> [L '<cmd>'.(v:count != 0 ? v:count : '').'lfirst<cr>zvzz'
nnoremap <expr> ]<C-l> '<cmd>'.v:count1.'lnfile<cr>zvzz'
nnoremap <expr> [<C-l> '<cmd>'.v:count1.'lpfile<cr>zvzz'

" Arguments navigation
nnoremap <expr> ]a '<cmd>'.v:count1.'next<cr>zvzz'
nnoremap <expr> [a '<cmd>'.v:count1.'previous<cr>zvzz'
nnoremap <expr> ]A '<cmd>'.(v:count != 0 ? v:count.'argument' : 'last').'<cr>zvzz'
nnoremap <expr> [A '<cmd>'.(v:count != 0 ? v:count.'argument' : 'first').'<cr>zvzz'

" Tags navigation
nnoremap <expr> ]t '<cmd>'.v:count1.'tnext<cr>zvzz'
nnoremap <expr> [t '<cmd>'.v:count1.'tpreview<cr>zvzz'
nnoremap <expr> ]T '<cmd>'.(v:count != 0 ? v:count.'tfirst' : 'tlast').'<cr>zvzz'
nnoremap <expr> [T '<cmd>'.(v:count != 0 ? v:count : '').'tfirst<cr>zvzz'
nnoremap <expr> ]<C-t> '<cmd>'.v:count1.'ptnext<cr>zvzz'
nnoremap <expr> [<C-t> '<cmd>'.v:count1.'ptprevious<cr>zvzz'

" Buffers navigation
nnoremap <expr> ]b '<cmd>'.v:count1.'bnext<cr>zvzz'
nnoremap <expr> [b '<cmd>'.v:count1.'bprevious<cr>zvzz'
nnoremap <expr> ]B '<cmd>'.(v:count != 0 ? v:count.'buffer' : 'blast').'<cr>zvzz'
nnoremap <expr> [B '<cmd>'.(v:count != 0 ? v:count.'buffer' : 'bfirst').'<cr>zvzz'


function! s:BlankUp() abort
  let cmd = 'put!=repeat(nr2char(10), v:count1)|silent '']+'
  if &modifiable
    let cmd .= '|silent! call repeat#set("\<Plug>(unimpaired-blank-up)", v:count1)'
  endif
  return cmd
endfunction

function! s:BlankDown() abort
  let cmd = 'put =repeat(nr2char(10), v:count1)|silent ''[-'
  if &modifiable
    let cmd .= '|silent! call repeat#set("\<Plug>(unimpaired-blank-down)", v:count1)'
  endif
  return cmd
endfunction

nnoremap <silent> <Plug>(unimpaired-blank-down) <cmd>exe <SID>BlankDown()<cr>
nnoremap <silent> <Plug>(unimpaired-blank-up) <cmd>exe <SID>BlankUp()<cr>

nnoremap <silent> <Plug>unimpairedBlankDown <cmd>exe <SID>BlankDown()<cr>
nnoremap <silent> <Plug>unimpairedBlankUp <cmd>exe <SID>BlankUp()<cr>

nnoremap <silent> ]<space> <Plug>(unimpaired-blank-down)
nnoremap <silent> [<space> <Plug>(unimpaired-blank-up)


" Search brackets forward/backward
" nnoremap <silent> ]} :<C-u>silent call search('}')<cr>
" nnoremap <silent> [} :<C-u>silent call search('}', 'b')<cr>
" nnoremap <silent> ]{ :<C-u>silent call search('{')<cr>
" nnoremap <silent> [{ :<C-u>silent call search('{', 'b')<cr>
nnoremap <silent> ]} :<C-u>silent call search('[{}]')<cr>
nnoremap <silent> [} :<C-u>silent call search('[{}]', 'b')<cr>
nnoremap <silent> ]{ :<C-u>silent call searchpair('{', '', '}')<cr>
nnoremap <silent> [{ :<C-u>silent call searchpair('{', '', '}', 'b')<cr>

" Indent text object. Consider to use blockwise variants for python
" :h indent-object
" Inner indent
xmap ii <Plug>(indent-object_linewise-none)
omap ii <Plug>(indent-object_linewise-none)
" omap ii <Plug>(indent-object_blockwise-none)
" Outher indent considering both start and end
xmap ia <Plug>(indent-object_linewise-both)
omap ia <Plug>(indent-object_linewise-both)
" omap ia <Plug>(indent-object_blockwise-both)


" vim-sandwich

" add
silent! nmap <unique> ys <Plug>(sandwich-add)
silent! xmap <unique> ys <Plug>(sandwich-add)
silent! omap <unique> ys <Plug>(sandwich-add)
silent! xmap <unique> S <Plug>(sandwich-add)

" delete
silent! nmap <unique> ds <Plug>(sandwich-delete)
silent! xmap <unique> ds <Plug>(sandwich-delete)
silent! nmap <unique> dss <Plug>(sandwich-delete-auto)

" replace
silent! nmap <unique> cs <Plug>(sandwich-replace)
silent! xmap <unique> cs <Plug>(sandwich-replace)
silent! nmap <unique> css <Plug>(sandwich-replace-auto)

" auto
" Textobjects to select the nearest surrounded text automatically.
silent! omap <unique> iq <Plug>(textobj-sandwich-auto-i)
silent! xmap <unique> iq <Plug>(textobj-sandwich-auto-i)
silent! omap <unique> aq <Plug>(textobj-sandwich-auto-a)
silent! xmap <unique> aq <Plug>(textobj-sandwich-auto-a)

" query (brackets)
" Textobjects to select a text surrounded by braket or same characters user input.
silent! omap <unique> ib <Plug>(textobj-sandwich-query-i)
silent! xmap <unique> ib <Plug>(textobj-sandwich-query-i)
silent! omap <unique> ab <Plug>(textobj-sandwich-query-a)
silent! xmap <unique> ab <Plug>(textobj-sandwich-query-a)

" Custom surrounding pair
" Textobjects to select a text surrounded by same characters user input.
silent! xmap im <Plug>(textobj-sandwich-literal-query-i)
silent! xmap am <Plug>(textobj-sandwich-literal-query-a)
silent! omap im <Plug>(textobj-sandwich-literal-query-i)
silent! omap am <Plug>(textobj-sandwich-literal-query-a)


" Copy vim-surround
" runtime macros/sandwich/keymap/surround.vim

" Recepies
let g:sandwich#recipes = [
\   {
\     'buns':         ['{', '}'],
\     'nesting':      1,
\     'skip_break':   1,
\     'input':        ['{', '}', 'B'],
\   },
\
\   {
\     'buns':         ['[', ']'],
\     'nesting':      1,
\     'input':        ['[', ']', 'r'],
\   },
\
\   {
\     'buns':         ['(', ')'],
\     'nesting':      1,
\     'input':        ['(', ')', 'b'],
\   },
\
\   {'buns': ['{ ', ' }'], 'nesting': 1, 'match_syntax': 1,
\    'kind': ['add', 'replace'], 'action': ['add'], 'input': ['{']},
\
\   {'buns': ['[ ', ' ]'], 'nesting': 1, 'match_syntax': 1,
\    'kind': ['add', 'replace'], 'action': ['add'], 'input': ['[']},
\
\   {'buns': ['( ', ' )'], 'nesting': 1, 'match_syntax': 1,
\    'kind': ['add', 'replace'], 'action': ['add'], 'input': ['(']},
\
\   {'buns': ['{\s*', '\s*}'],   'nesting': 1, 'regex': 1,
\    'match_syntax': 1, 'kind': ['delete', 'replace', 'textobj'],
\    'action': ['delete'], 'input': ['{']},
\
\   {'buns': ['\[\s*', '\s*\]'], 'nesting': 1, 'regex': 1,
\    'match_syntax': 1, 'kind': ['delete', 'replace', 'textobj'],
\    'action': ['delete'], 'input': ['[']},
\
\   {'buns': ['(\s*', '\s*)'],   'nesting': 1, 'regex': 1,
\    'match_syntax': 1, 'kind': ['delete', 'replace', 'textobj'],
\    'action': ['delete'], 'input': ['(']},
\   {
\     'buns': ['\s\+', '\s\+'],
\     'regex': 1,
\     'kind': ['delete', 'replace', 'query'],
\     'input': [' ']
\   },
\
\ ]

" \   {
" \     'buns':         ['', ''],
" \     'action':       ['add'],
" \     'motionwise':   ['line'],
" \     'linewise':     1,
" \     'input':        ["\<CR>"]
" \   },
" \
" \   {
" \     'buns':         ['^$', '^$'],
" \     'regex':        1,
" \     'linewise':     1,
" \     'input':        ["\<CR>"]
" \   },
" \
" \   {
" \     'buns':         ['<', '>'],
" \     'expand_range': 0,
" \     'input':        ['>', 'a'],
" \   },
" \   {
" \     'buns': 'sandwich#magicchar#t#tag()',
" \     'listexpr': 1,
" \     'kind': ['add'],
" \     'action': ['add'],
" \     'input': ['t', 'T'],
" \   },
" \
" \   {
" \     'buns': 'sandwich#magicchar#t#tag()',
" \     'listexpr': 1,
" \     'kind': ['replace'],
" \     'action': ['add'],
" \     'input': ['T', '<'],
" \   },
" \
" \   {
" \     'buns': 'sandwich#magicchar#t#tagname()',
" \     'listexpr': 1,
" \     'kind': ['replace'],
" \     'action': ['add'],
" \     'input': ['t'],
" \   },
" \
" \   {
" \     'external': ["\<Plug>(textobj-sandwich-tag-i)", "\<Plug>(textobj-sandwich-tag-a)"],
" \     'noremap': 0,
" \     'kind': ['delete', 'textobj'],
" \     'expr_filter': ['operator#sandwich#kind() !=# "replace"'],
" \     'linewise': 1,
" \     'input': ['t', 'T', '<'],
" \   },
" \
" \   {
" \     'external': ["\<Plug>(textobj-sandwich-tag-i)", "\<Plug>(textobj-sandwich-tag-a)"],
" \     'noremap': 0,
" \     'kind': ['replace', 'query'],
" \     'expr_filter': ['operator#sandwich#kind() ==# "replace"'],
" \     'input': ['T', '<'],
" \   },
" \
" \   {
" \     'external': ["\<Plug>(textobj-sandwich-tagname-i)", "\<Plug>(textobj-sandwich-tagname-a)"],
" \     'noremap': 0,
" \     'kind': ['replace', 'textobj'],
" \     'expr_filter': ['operator#sandwich#kind() ==# "replace"'],
" \     'input': ['t'],
" \   },
" \
" \   {
" \     'buns': ['sandwich#magicchar#f#fname()', '")"'],
" \     'kind': ['add', 'replace'],
" \     'action': ['add'],
" \     'expr': 1,
" \     'input': ['f']
" \   },
" \
" \   {
" \     'external': ["\<Plug>(textobj-sandwich-function-ip)", "\<Plug>(textobj-sandwich-function-i)"],
" \     'noremap': 0,
" \     'kind': ['delete', 'replace', 'query'],
" \     'input': ['f']
" \   },
" \
" \   {
" \     'external': ["\<Plug>(textobj-sandwich-function-ap)", "\<Plug>(textobj-sandwich-function-a)"],
" \     'noremap': 0,
" \     'kind': ['delete', 'replace', 'query'],
" \     'input': ['F']
" \   },
" \
" \   {
" \     'buns': 'sandwich#magicchar#i#input("operator")',
" \     'kind': ['add', 'replace'],
" \     'action': ['add'],
" \     'listexpr': 1,
" \     'input': ['i'],
" \   },
" \
" \   {
" \     'buns': 'sandwich#magicchar#i#input("textobj", 1)',
" \     'kind': ['delete', 'replace', 'query'],
" \     'listexpr': 1,
" \     'regex': 1,
" \     'input': ['i'],
" \   },
" \
" \   {
" \     'buns': 'sandwich#magicchar#i#lastinput("operator", 1)',
" \     'kind': ['add', 'replace'],
" \     'action': ['add'],
" \     'listexpr': 1,
" \     'input': ['I'],
" \   },
" \
" \   {
" \     'buns': 'sandwich#magicchar#i#lastinput("textobj")',
" \     'kind': ['delete', 'replace', 'query'],
" \     'listexpr': 1,
" \     'regex': 1,
" \     'input': ['I'],
" \   },

