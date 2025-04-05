#!/usr/bin/env pwsh

$location = $PSScriptRoot

if (!(Test-Path -LiteralPath "$location/autoload/plug.vim")) {
  # Install VimPlug
  curl -fLo "$location/autoload/plug.vim" --create-dirs

  Invoke-WebRequest -OutFile "$location/autoload/plug.vim" `
    -Uri 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
}

$symlink_locations = @(
  "$HOME/.vim"
  "$HOME/.config/nvim"
)

$windows = ($IsWindows -or $env:OS -eq 'Windows_NT')

foreach ($loc in $symlink_locations) {
  if (!(Test-Path -LiteralPath $loc -ErrorAction SilentlyContinue)) {
    New-Item -ItemType SymbolicLink -Tartget $location -Path $loc
    continue
  }

  $item = Get-Item -LiteralPath $loc -Force -ErrorAction SilentlyContinue

  if (
    ($item.LinkType -eq 'SymbolicLink') -or
    ($windows -and ([bool]($item.Attributes -band [IO.FileAttributes]::ReparsePoint)))
  ) {
    continue
  }

  # replace directory if exist
  if (Test-Path -PathType Container -LiteralPath $loc -ErrorAction SilentlyContinue) {
    Move-Item $loc "$loc.bac"
  } elseif (Test-Path -LiteralPath $loc -PathType Leaf -ErrorAction SilentlyContinue) {
    Remove-Item -LiteralPath $loc
  }

  New-Item -ItemType SymbolicLink -Tartget $location -Path $loc
}

# Nvim from scoop reads from APPDATA
if ($windows) {
  $appdata = $env:LOCALAPPDATA
  $nvim = "$appdata/nvim"

  if (!(Test-Path -LiteralPath $nvim -ErrorAction SilentlyContinue)) {
    New-Item -ItemType SymbolicLink -Tartget $location -Path $nvim
    exit
  }

  $item = Get-Item $nvim -Force -ErrorAction SilentlyContinue

  if ([bool]($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
    exit
  }

  # replace directory if exist
  if (Test-Path -LiteralPath $nvim -PathType Container -ErrorAction SilentlyContinue) {
    Move-Item -LiteralPath $nvim -Destination "$nvim.bac"
  } elseif (Test-Path -LiteralPath $nvim -PathType Leaf -ErrorAction SilentlyContinue) {
    Remove-Item -LiteralPath $nvim
  }

  New-Item -ItemType SymbolicLink -Tartget $location -Path $nvim
}
