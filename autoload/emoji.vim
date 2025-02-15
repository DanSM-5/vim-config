" Plugin that opens a emoji selector
" Can be used for completion using fzf

if exists('g:loaded_emoji')
  finish
endif

let g:loaded_emoji = 1

function emoji#insert(use_name, mode, list) abort
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

function emoji#open(query, use_name, mode) abort
  let emoji_file = $user_config_cache . '/emojis/emoji'

  if !filereadable(emoji_file)
    echo 'No emojis downloaded'
    return
  endif

  let options = []

  if has('win32') || has('win64')
    " Workaround to avoid fzf loading with artifacts
    let pwsh = executable('pwsh') ? 'pwsh' : 'powershell'
    let options = [ '--with-shell', pwsh . ' -NoLogo -NonInteractive -NoProfile -Command' ]
    " Requires script With-UTF8 but it $user_config_cache is available
    " scripts should be available too I guess...
    let source = 'With-UTF8 { Get-Content ' . emoji_file . '}'
  else
    let cmd = 'cat '
    let source = cmd . emoji_file
  endif

    " \   'source': source,
  let spec = {
    \   'sinklist': function('emoji#insert', [a:use_name, a:mode]),
    \   'options': g:fzf_bind_options + [
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
    \     '--bind', 'start:reload:'.source,
    \     '--bind', 'alt-c:clear-query'] + options
    \ }

  call fzf#run(fzf#wrap('emoji', spec, 0))
endfunction

