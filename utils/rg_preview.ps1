#!/usr/bin/env pwsh

$LINE = ($args -Split ':')
$FILE = $LINE[0]
$NUMBER = if ($null -eq $LINE[1]) { '0' } else { $LINE[1] }
$STYLE = if ($BAT_STYLE) { $BAT_STYLE } else { 'numbers' }
if (Get-Command -All -Name 'bat' -ErrorAction SilentlyContinue) {
  bat --style="$STYLE" --color=always --pager=never --highlight-line="$NUMBER" -- "$FILE"
} else {
  Get-Content $FILE
}

