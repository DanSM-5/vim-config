#!/usr/bin/env pwsh

if (!$args) {
  $name = $MyInvocation.MyCommand.name
  Write-Output "usage: $name [--tag] FILENAME[:LINENO][:IGNORED]"
  exit 1
}

# TODO: Handle tag preview?
if ($args[0] -eq '--tag') {
  exit 0
}

$segments = $args[0] -Split ':'

# Check if first item is a drive letter and offset accordingly
if (Get-PSDrive -LiteralName $segments[0] -PSProvider FileSystem -ErrorAction SilentlyContinue) {
  $FILE = ($segments[0] + ':' + $segments[1])
  $CENTER = $segments[2]
} else {
  $FILE = $segments[0]
  $CENTER = $segments[1]

  # Expand references to home directory `~`
  $FILE = if ($FILE -eq '~') { $HOME } else { $FILE }
  if ("$FILE" -like '~*') {
    $FILE = $HOME + $FILE.Substring(1)
  }
}

if (!(Test-Path -LiteralPath $FILE -PathType Leaf -ErrorAction SilentlyContinue)) {
  Write-Output "File not found ${FILE}"
  exit 1
}

if (-Not $CENTER) {
  $CENTER = '0'
}

# Sometimes bat is installed as batcat.
if (Get-Command -Name 'batcat' -All) {
  $BATNAME = 'batcat'
} elseif (Get-Command -Name 'bat' -All) {
  $BATNAME = 'cat'
}

if ($BATNAME -and !($env:FZF_PREVIEW_COMMAND)) {
  $BAT_STYLE = if ($env:BAT_STYLE) { $env:BAT_STYLE } else { 'numbers' }
  & $BATNAME --style="$BAT_STYLE" --color=always --pager=never `
      --highlight-line="$CENTER" -- "$FILE"

  exit $?
}

# TODO: Add binary detection
# https://stackoverflow.com/questions/11698525/powershell-possible-to-determine-a-files-mime-type

$DEFAULT_COMMAND = if ($env:FZF_DEFAULT_COMMAND) {
  $env:FZF_DEFAULT_COMMAND
} else {
  "highlight -O ansi -l $FILE || coderay $FILE || rougify $FILE || Get-Content $FILE"
}

$DEFAULT_COMMAND | Invoke-Expression

