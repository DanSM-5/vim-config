VIM Config
==========

This repository contains a collection of script and plugins to configure `(neo)vim`.

The configuration logic counts with different entry points to adjust to needs.

## Supported plugin managers

The following plugin managers are supported with their respective entry point file

- [vim-plug](https://github.com/junegunn/vim-plug)
  - vim: `vimrc`
  - neovim: `init.vim.old`
- [lazy.nvim](https://github.com/folke/lazy.nvim)
  - neovim: `init.lua`

### Differences on nvim configs

The mayor difference between the vim-plug and lazy.nvim config resides on the color scheme plugin (both based on one[-half]-dark).

The config based on lazy.nvim is expected to work only on neovim, as such plugins that are neovim only or primarily developed for neovim will be preferred.

The config based on vim-plug may prefer a vim/neovim supported plugin. However logic to load neovim only and vim only plugins exists.

## Core config

For compativility reasons the core config is written in vimscript (no vim9script) and it is called in all configs. The config logic is located in `autoload/config.vim`

### API

Exposed methods from core config.

#### config#CurrentOS

Detects the current platform and sets global variables useful to alter behavior.

##### Environment variables

Environment variables that affect this function:

- `IS_GITBASH`: Fallback to detect gitbash. On startup (before 'VimEnter') calling `uname` may yield a different value from the expected which makes this variable important when running on bash from git for windows.
- `IS_POWERSHELL`: Used for preventing wrong detections when `uname.exe` is in the path as it will return the expected value for gitbash regardless of the shell that (n)vim was called from.
- `IS_CMD`: Used for preventing wrong detections when `uname.exe` is in the path as it will return the expected value for gitbash regardless of the shell that (n)vim was called from.
- `IS_FROM_CONTAINER`: Used for detecting if config is running within a container. This will enable container specifc configs.
- `IS_TERMUX`: Used as fallback to detect termux environment on android (return will be `linux`).

For more information about environment variables see [detection](https://github.com/DanSM-5/user-scripts/blob/master/bin/detection) script.

##### Global variables

The following variables (boolean) are set when calling `config#CurrentOS`

- `g:is_windows`: true if running from powershell, pwsh, cmd or gitbash.
- `g:is_linux`: true if running in a linux distribution, termux, containers or wsl.
- `g:is_mac`: true if running on macos.
- `g:is_gitbash`: true if running from bash or zsh in git for windows or msys/mingw.
- `g:is_wsl`: true if running from wsl.
- `g:is_container`: true if running from a container.
- `g:is_termux`: true if running from termux environment in android.

##### Additional effects

- On windows, it sets `shell=cmd` and `shellcmdflag=/c` to ensure reliable functionality of plugins that do not expect bash or unix commands in windows. This is internally handled.

##### Returns

String with the name of the platform.

- `linux`: In Linux distributions, wsl, containers and termux.
- `windows`: In windows from powershell, pwsh, cmd, bash (from gitbash or mingw).
- `mac`: In macos.

##### Example

```vim
" Either 'windows', 'linux', 'mac'
let platform = call config#CurrentOS()
```

#### config#before

Sets configurations on startup before plugins are loaded.

#### config#after

Sets configurations on startup on `VimEnter` autocmd.

## LSP and auto completion

In neovim lsp is configured using `lspconfig` and lsp servers can be added using `:Mason` or manually installing them and calling `require('lspconfig').SERVER.setup({})`.

For vim there is no lsp setup. You can add support for it using `[vim-lsp](https://github.com/prabirshrestha/vim-lsp)` and `[vim-lsp-settings](https://github.com/mattn/vim-lsp-settings)`.

Completions in neovim for instance rely mostly on lsp suggestions displayed using `cmp-nvim`.

Completions in vim rely on buildin completions. See `:h complete_info_mode` and [vim-completion](https://georgebrock.github.io/talks/vim-completion) for more information.

## Plugins

Plugins used in this configuration may vary over time. The idea is not to add a plugin for everything but add plugins that improve the experice of text editing and navigation.

Notable plugins:

- [vim-fugitive](https://github.com/tpope/vim-fugitive)
- [fzf.vim](https://github.com/junegunn/fzf.vim)
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- [ctrlsf.vim](https://github.com/dyng/ctrlsf.vim)
- [vim-visual-multi](https://github.com/mg979/vim-visual-multi)
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)

## Versioning

[Master](https://github.com/DanSM-5/vim-config/tree/master) is latest 😄

## Issues

No body else should be using this 😅 but if you happen to use it for inexplicable life situations and find a bug, feel free to open an issue.

