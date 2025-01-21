
if exists('g:loaded_fzftxt')
  finish
endif

let g:loaded_fzftxt = 1
let s:is_windows = has('win32') || has('win32unix')
let s:is_gitbash = 0
if s:is_windows && ($MSYSTEM =~? 'MINGW' || $MSYSTEM =~? 'MSYS')
  let s:is_gitbash = 1
endif

if g:is_windows
  let s:fzf_preview =<< trim END
    $LINE = (({}) -Split ':')
    $FILE = $LINE[0]
    $NUMBER = if ($LINE[1] -eq $null) { '0' } else { $LINE[1] }
    $STYLE = if ($BAT_STYLE) { $BAT_STYLE } else { 'numbers' }
    if (Get-Command -All -Name 'bat' -ErrorAction SilentlyContinue) {
      bat --style="$STYLE" --color=always --pager=never --highlight-line="$NUMBER" -- "$FILE"
    } else {
      Get-Content `$FILE
    }
  END
else
  let s:fzf_preview =<< trim END
    FILE={1}
    NUMBER={2}

    if [ -z "$NUMBER" ]; then
      NUMBER=0
    fi

    if command -v bat &> /dev/null; then
      bat --style="${BAT_STYLE:-numbers}" --color=always --pager=never \
        --highlight-line="$NUMBER" -- "$FILE"
    else
      cat -- "$FILE"
    fi
  END
endif

let s:fzf_preview = join(s:fzf_preview, "\n")

function! fzftxt#open(query, fullscreen) abort
  let curr_path = getcwd()
  let txt_dir = exists('g:txt_dir') ? g:txt_dir : '~/prj/txt'
  let txt_dir = substitute(expand(txt_dir), '\\', '/', 'g')
  let files_command = 'fd --color=always --type file . '
  let grep_command='rg --with-filename --line-number --color=always {q}'

  silent call mkdir(txt_dir, 'p')

  if s:is_windows
    if !s:is_gitbash
      let files_command = files_command . ' --path-separator "/" '
    endif
  endif

  try
    exec 'cd ' . txt_dir

    let spec = {
      \   'source': files_command,
      \   'sinklist': function('s:FzfSelectedList'),
      \   'options': s:fzf_bind_options + [
      \     '--prompt', 'Open Txt> ',
      \     '--multi', '--ansi',
      \     '--info=inline', '--cycle',
      \     '--header', 'ctrl-f: File selection (reload alt-r) | ctrl-r: Search mode',
      \     '--bind', 'alt-c:clear-query',
      \     '--bind', 'alt-f:first',
      \     '--bind', 'alt-l:last',
      \     '--bind', 'alt-a:select-all',
      \     '--bind', 'alt-d:deselect-all',
      \     '--bind', 'ctrl-l:change-preview-window(down|hidden|)',
      \     '--bind', 'ctrl-/:change-preview-window(down|hidden|)',
      \     '--bind', 'alt-up:preview-page-up,alt-down:preview-page-down',
      \     '--bind', 'shift-up:preview-up,shift-down:preview-down',
      \     '--bind', 'ctrl-^:toggle-preview',
      \     '--bind', 'ctrl-s:toggle-sort',
      \     '--bind', 'alt-r:reload:' . files_command,
      \     '--bind', 'ctrl-f:unbind(change,ctrl-f)+change-prompt(Files> )+enable-search+clear-query+rebind(ctrl-r,alt-r)',
      \     '--bind', 'ctrl-r:unbind(ctrl-r,alt-r)+change-prompt(Search> )+disable-search+reload(' . grep_command . ')+rebind(change,ctrl-f)',
      \     '--bind', 'change:reload:' . grep_command,
      \     '--bind', 'start:unbind(change)',
      \     '--layout=reverse',
      \     '--preview-window', '60%',
      \     '--query', a:query,
      \     '--preview', s:fzf_preview]
      \ }


    if s:is_windows
      let spec.options = spec.options + ['--with-shell', 'powershell.exe -NoLogo -NonInteractive -NoProfile -Command']
    endif

    " Hope for the best
    call fzf#run(fzf#wrap('ftxt', spec, a:fullscreen))
  finally
    " Recover cwd on end
    exec 'cd '. curr_path
  endtry
endfunction

