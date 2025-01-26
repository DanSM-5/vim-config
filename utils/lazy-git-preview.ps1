#!/usr/bin/env pwsh

if (-not (git rev-parse HEAD 2> $null)) { exit }

if (Get-Command delta -ErrorAction SilentlyContinue) {
  $pager = 'delta --paging=always'
  $preview_pager = ' | delta'
  $has_delta = $true
} else {
  $pager = 'less -R'
  $preview_pager = ''
  $has_delta = $false
}

if (Get-Command -Name pwsh -All) {
  function git_diff () {
    if ($has_delta) {
      git diff --color=always @args | delta --paging=always
    } else {
      git diff --color=always @args | less -R
    }
  }
  function git_show () {
    if ($has_delta) {
      git show --color=always @args | delta --paging=always
    } else {
      git show --color=always @args | less -R
    }
  }
  $shell_cmd = 'pwsh.exe'
} else {
  function git_diff () {
    pwsh -NoLogo -NonInteractive -NoProfile -Command "git diff --color=always -- $args | $pager"
  }
  function git_show () {
    pwsh -NoLogo -NonInteractive -NoProfile -Command "git show --color=always -- $args | $pager"
  }
  $shell_cmd = 'powershell.exe'
}

$preview = "
  `$hash = if ({} -match `"[a-f0-9]{7,}`") {
    `$matches[0]
  } else { @() }
  git show --color=always `$hash $preview_pager |
    bat -p --color=always
"

# When calling this from pwsh (powershell 7),
# the script will inherit the PSModulePath environment variable
# which causes New-TemporaryFile to fail.
# This script is intended to run with Windows Powershell so
# the alternative is to call the windows API directly.
try {
  # Ensure that New-Temporaryfile is available
  Import-Module Microsoft.PowerShell.Utility
  $content_file = New-Temporaryfile
}
catch {
  $content_file = Get-Item ([System.IO.Path]::GetTempFilename())
}

$out = ''
$shas = @()
$q = ''
$k = ''

# $dirsep = if ($IsWindows -or ($env:OS -eq 'Windows_NT')) { '\' } else { '/' }
$fzf_history = if ($env:FZF_HIST_DIR) { $env:FZF_HIST_DIR } else { "$HOME/.cache/fzf_history".Replace('\', '/') }

function get_fzf_down_options() {
  $options = @(
    '--query=',
    '--height', '100%',
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
    '--header', 'ctrl-d: Diff',
    '--prompt', 'Commits> ',
    '--preview', $preview,
    '--with-shell', "$shell_cmd -NoLogo -NonInteractive -NoProfile -Command",
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
    # NOTE: Using windows powershell causes some issues. We will detect here if pwsh is present
    # and use it over windows powershell.
    if ($k -eq 'ctrl-d') {
      # if (Get-Command -Name pwsh -All) {
      #   pwsh -NoLogo -NonInteractive -NoProfile -Command "git diff --color=always $shas | $pager"
      # } else {
      #   powershell -NoLogo -NonInteractive -NoProfile -Command "git diff --color=always -- $shas | $pager"
      # }
      git_diff @shas
    } else {
      foreach ($sha in $shas) {
        # if (Get-Command -Name pwsh -All) {
        #   pwsh -NoLogo -NonInteractive -NoProfile -Command "git show --color=always $sha | $pager"
        # } else {
        #   powershell -NoLogo -NonInteractive -NoProfile -Command "git show --color=always -- $sha | $pager"
        # }
        git_show $sha
      }
    }
  }
} finally {
  if (Test-Path -Path $content_file.FullName -PathType Leaf -ErrorAction SilentlyContinue) {
    Remove-Item -Force $content_file.FullName
  }
}

