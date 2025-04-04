if exists('g:loaded_fzfgh')
  finish
endif

let g:loaded_fzfgh = 1
let s:is_windows = has('win32') || has('win32unix') || has('win64')
let s:is_gitbash = 0
if s:is_windows && ($MSYSTEM =~? 'MINGW' || $MSYSTEM =~? 'MSYS') && ($OSTYPE == 'msys')
  let s:is_gitbash = 1
endif

" Get PRs using gh pr list
" @param cmd string: Command to execute (default: "gh pr list")
" @return List of PRs
function! fzfgh#get_prs(opts) abort
  let cmd = get(a:opts, 'cmd', 'gh pr list')
  let prs = systemlist(cmd)
  return filter(prs, '!empty(v:val)')
endfunction


function! fzfgh#split_selection(selection_str) abort
  let parts = split(a:selection_str, "\t")
  " did not split? attempt split by spaces
  if empty(parts) || match(parts[0], "\\s") > 0
    let parts = split(a:selection_str, "\\s\\+")
  endif
  
  return parts
endfunction

" Extract PR number from a selected line
" @param pr_str string: PR string from gh pr list
" @return string|nil: PR number or nil if not found
function! fzfgh#extract_pr_number(pr_str) abort
  let parts = fzfgh#split_selection(a:pr_str)

  let matches = matchlist(parts[0],  "^#\\?\\(\\d\\+\\)$")

  if empty(matches) || len(matches) < 2 || empty(matches[1])
    return v:null
  endif

  let pr_number = matches[1]
  return pr_number
endfunction

" Create a scratch buffer with content
" @param content table: Buffer content as a list of strings
" @param filetype string: Buffer filetype (default: "markdown")
" @return number: Buffer handle
function! fzfgh#create_scratch_buffer(content, filetype) abort
  " Create vsplit
  vsplit
  enew

  " Populate content
  let cleaned_content = map(a:content, 'substitute(v:val, "\r", "", "g")')
  let content = join(cleaned_content, "\n")
  put = content
  normal ggdd

  " Buffer options
  set fileformat=unix
  let &filetype = empty(a:filetype) ? 'markdown' : a:filetype
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal nomodifiable
  setlocal noswapfile
  setlocal nomodified
  setlocal readonly

  file '[GitHub PR View]'

  return bufnr("%")
endfunction

" Open PR details in a scratch buffer
" @param selected_pr table: Selected PR from fzf
function! fzfgh#open_pr(selected_pr) abort
  let parts = fzfgh#split_selection(a:selected_pr)
  let pr_str = parts[0] 
  let pr_number = fzfgh#extract_pr_number(pr_str)

  if empty(pr_number) || pr_number == v:null
    return
  endif

  let cmd = 'gh pr view ' . pr_number
  let content = systemlist(cmd)

  if empty(content)
    return
  endif

  call fzfgh#create_scratch_buffer(content, 'markdown')
endfunction

" Checkout PR
" @param selected_pr table: Selected PR from fzf
function! fzfgh#checkout_pr(selected_pr) abort
  let parts = fzfgh#split_selection(a:selected_pr)
  let pr_str = parts[0]
  let pr_number = fzfgh#extract_pr_number(pr_str)

  if empty(pr_number) || pr_number == v:null
    return
  endif

  echomsg 'Checking out PR #' . pr_number
  let output = system('gh pr checkout '. pr_number)
  if match(output, 'fatal') > 0
    echoerr output
  endif
endfunction

" Open PR in browser
" @param selected_pr table: Selected PR from fzf
function! fzfgh#open_pr_in_browser(selected_pr) abort
  let parts = fzfgh#split_selection(a:selected_pr)
  let pr_str = parts[0]
  let pr_number = fzfgh#extract_pr_number(pr_str)

  if empty(pr_number) || pr_number == v:null
    return
  endif

  call system('gh pr view ' . pr_number . ' --web')
endfunction


" GitHub PRs function
" Lists and allows interaction with GitHub PRs
function! fzfgh#select_prs(fullscreen) abort
  if !executable('gh')
    echomsg '[Fzfgh] The gh cli is not found'
    return
  endif


  let fullscreen = a:fullscreen
  let options = exists('g:fzf_bind_options') ? g:fzf_bind_options : [
    \     '--cycle',
    \     '--ansi',
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
    let shell_opts = []
    let preview = ''

    if s:is_windows
      let pwsh = executable('pwsh') ? 'pwsh' : 'powershell'
      let shell_opts = ['--with-shell', pwsh . ' -NoLogo -NonInteractive -NoProfile -Command']
      let preview = '$env:GH_FORCE_TTY = $env:FZF_PREVIEW_COLUMNS; gh pr view {1}'
    else
      let preview = 'GH_FORCE_TTY=$FZF_PREVIEW_COLUMNS gh pr view {1}'
    endif

  " Sample command with preview
  " GH_FORCE_TTY='50%' gh pr list | fzf --ansi --header-lines 4 \
  "   --preview 'GH_FORCE_TTY=$FZF_PREVIEW_COLUMNS gh pr view {1}' 

  " \   '--delimiter', "\t",
  " \   '--with-nth', '1,2,3',
  let prs_options = [
    \   '--expect=ctrl-f,ctrl-o,ctrl-s',
    \   '--header-lines', '2',
    \   '--prompt', 'GitHub PRs> ',
    \   '--preview', preview,
    \   '--preview-window', '50%',
    \   '--input-border=rounded',
    \   '--preview-border=rounded',
    \   '--header-border=rounded',
    \   '--header-lines-border=bottom',
    \   '--header', 'ctrl-f: Filter PRs | ctrl-o: Open in browser | ctrl-s: Checkout to PR'
    \ ] + options + ['--no-multi'] + shell_opts


  let filters = [
    \   'Assigned to me',
    \   'Created by me',
    \   'Needs my review',
    \   'Draft PRs only',
    \   'Ready PRs only',
    \   'Merged PRs',
    \   'Closed PRs',
    \   'None'
    \ ]
  let filter_cmds = [
    \   '--assigned @me',
    \   '--author @me',
    \   "--search 'review-requested:@me'",
    \   '--draft',
    \   "--search 'draft:false'",
    \   '--state merged',
    \   '--state closed',
    \   ''
    \ ]
  let filter_spec = {
    \   'source': filters,
    \   'options': options + ['--no-multi', '--header', 'esc: Without filter', '--input-border=rounded'],
    \ }

  function! s:filter_sink(filter) closure
    let cmd = ''

    if !empty(a:filter)
      let opt_idx = indexof(filters, 'v:val == "'.a:filter[0].'"')
      if opt_idx == -1
        let cmd = 'gh pr list'
      else
        let cmd = 'gh pr list ' . filter_cmds[opt_idx]
      endif
    endif


    try
      let $GH_FORCE_TTY = '50%'
      return s:select_pr(cmd)
    finally
      unlet $GH_FORCE_TTY
    endtry
  endfunction

  function! s:select_pr_sink(selection) closure
    if empty(a:selection)
      return
    endif

    let expected_key = a:selection[0]

    if !empty(expected_key)

      if expected_key ==? 'ctrl-o'
        return fzfgh#open_pr_in_browser(pr)
      elseif expected_key ==? 'ctrl-f'
        return s:filter_prs()
      elseif expected_key ==? 'ctrl-s'
        return fzfgh#checkout_pr(pr)
      endif

      " Unexpected key?
      return
    endif

    let pr = a:selection[1]

    return fzfgh#open_pr(pr)
  endfunction

  function! s:select_pr(cmd) closure
    let prs = empty(a:cmd) ? fzfgh#get_prs({}) : fzfgh#get_prs({ 'cmd': a:cmd })

    if empty(prs)
      echomsg '[Fzfgh] No prs 🎉'
      return
    endif

    let spec = {
      \   'source': prs,
      \   'options': prs_options,
      \   'sinklist': function('s:select_pr_sink')
      \ }

    call fzf#run(fzf#wrap('github_prs', spec, fullscreen))
  endfunction

  function! s:filter_prs() closure
    call fzf#run(fzf#wrap('github_filter', filter_spec, fullscreen))
  endfunction

  let filter_spec.sinklist = function('s:filter_sink')

  try
    let $GH_FORCE_TTY = '50%'
    return s:select_pr('')
  finally
    unlet $GH_FORCE_TTY
  endtry
endfunction
