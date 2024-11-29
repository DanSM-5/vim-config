#!/usr/bin/env pwsh

Get-Content @args | ForEach-Object { ($_ -Split "\s+")[0] } | Set-Clipboard

