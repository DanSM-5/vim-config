#!/usr/bin/env pwsh

if (-not (git rev-parse HEAD 2> $null)) { exit }

$pager = if (Get-Command delta -ErrorAction SilentlyContinue) {
  'delta --paging=always'
} else {
  'less -R'
}

$content_file = New-Temporaryfile
$out = ''
$shas = ''
$q = ''
$k = ''

$dirsep = if ($IsWindows -or ($env:OS -eq 'Windows_NT')) { '\' } else { '/' }
$fzf_history = if ($env:FZF_HIST_DIR) { $env:FZF_HIST_DIR } else { "$HOME/.cache/fzf_history".Replace('\', '/') }

function get_fzf_down_options() {
  $options = @(
    '--query=',
    '--height', '50%',
    '--min-height', '20',
    '--input-border',
    '--cycle',
    '--layout=reverse',
    '--multi',
    '--border',
    '--bind', 'alt-f:first',
    '--bind', 'alt-l:last',
    '--bind', 'alt-c:clear-query',
    '--bind', 'ctrl-a:select-all',
    '--bind', 'ctrl-d:deselect-all',
    '--bind', 'ctrl-/:change-preview-window(down|hidden|)',
    '--bind', 'ctrl-^:toggle-preview',
    '--bind', 'alt-up:preview-page-up',
    '--bind', 'alt-down:preview-page-down',
    '--bind', 'ctrl-s:toggle-sort',
    "--history=$fzf_history/fzf-git_show",
    '--prompt', 'Commits> ',
    '--ansi',
    '--no-sort',
    '--reverse',
    '--print-query',
    '--expect=ctrl-d'
  )

  return $options
}

$down_options = get_fzf_down_options

try {
  while ($true) {
    $out = git log --graph --color=always `
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" @args |
    fzf @down_options

    if (-not $out) { break; }

    $out > $content_file.FullName
    $q = head -1 $content_file.FullName
    $k = head -2 $content_file.FullName | tail -1
    $shas = sed '1,2d;s/^[^a-z0-9]*//;/^$/d' $content_file.FullName | awk '{print $1}'

    if (-not $shas) { continue; }
    if ($q) { $down_options[0] = "--query=$q" }
    if ($k -eq 'ctrl-d') {
      $pager = if (Get-Command delta -ErrorAction SilentlyContinue) {
        git show --color=always @shas | delta --paging=always
      } else {
        git show --color=always @shas | less -R
      }
    } else {
      $pager = if (Get-Command delta -ErrorAction SilentlyContinue) {
        foreach ($sha in $shas) {
          git show --color=always @sha | delta --paging=always
        }
      } else {
        foreach ($sha in $shas) {
          git show --color=always @sha | less -R
        }
      }
    }
  }
} finally {
  if (Test-Path -Path $content_file.FullName -PathType Leaf -ErrorAction SilentlyContinue) {
    Remove-Item -Force $content_file.FullName
  }
}

