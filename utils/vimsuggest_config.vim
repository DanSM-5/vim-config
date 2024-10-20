" Configuration for vimsuggest
" Ref: https://github.com/girishji/vimsuggest

" Highlight groups
" - VimSuggestMatch: Highlights matched portion of the text. Linked to PmenuMatch by default.
" - VimSuggestMatchSel: Highlights matched text in the selected item of the menu. Linked to PmenuMatchSel by default.
" - VimSuggestMute: Highlights passive text like line numbers in grep output. Linked to NonText by default.

if !exists('g:VimSuggestSetOptions')
  finish
endif

let s:vim_suggest = {}

" Command completion
let s:vim_suggest.cmd = {
  \ 'enable': v:true,
  \ 'pum': v:true,
  \ 'fuzzy': v:true,
  \ 'exclude': [],
  \ 'onspace': [],
  \ 'alwayson': v:true,
  \ 'popupattrs': {},
  \ 'wildignore': v:true,
  \ 'addons': v:true,
  \ 'ctrl_np': v:false,
\ }

" Search configuration
let s:vim_suggest.search = {
    \ 'enable': v:true,
    \ 'pum': v:true,
    \ 'fuzzy': v:true,
    \ 'alwayson': v:true,
    \ 'popupattrs': {
    \   'maxheight': 12
    \ },
    \ 'range': 100,
    \ 'timeout': 200,
    \ 'async': v:true,
    \ 'async_timeout': 3000,
    \ 'async_minlines': 1000,
    \ 'highlight': v:true,
    \ 'ctrl_np': v:false,
\ }

" Open quickfix with <C-q>
augroup vimsuggest-qf-show
  autocmd!
  autocmd QuickFixCmdPost clist cwindow
augroup END

" Set external tools
" Fuzzy find files
" :VSFind [dirpath] [fuzzy_pattern]
let g:vimsuggest_fzfindprg = 'fd --type f .'
" Live Grep
" :VSGrep {pattern} [directory]
let g:vimsuggest_grepprg = 'rg --vimgrep --smart-case'
" Live File Search
" :VSFindL {pattern} [directory]
let g:vimsuggest_findprg = 'fd --type f'

" Other commands
" :VSBuffer [fuzzy_pattern]
" :VSMru [fuzzy_pattern]
" :VSKeymap [fuzzy_pattern]
" :VSMark [fuzzy_pattern]
" :VSRegister [fuzzy_pattern]
" :VSChangelist [fuzzy_pattern]
" :VSGlobal {regex_pattern}
" :VSInclSearch {regex_pattern}
" :VSExec {shell_command}

call g:VimSuggestSetOptions(s:vim_suggest)

