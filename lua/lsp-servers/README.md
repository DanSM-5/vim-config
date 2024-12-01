LSP
============

Notes about lsp and configuration in neovim

# Manual lsp configuration

## Function example

```lua
function StartPython ()
  vim.lsp.start({
    -- Client name
    name = 'pyright',
    -- Lsp client command
    cmd = {'pyright-langserver', '--stdio'},
    -- Root of project (usually by specific files)
    root_dir = vim.fs.root(0, {'pyproject.toml', 'pyrightconfig.json'}),
    -- Settings for lsp server
    settings = {
      python = {
        analysis = {
          typeCheckingMode = 'basic',
          autoSeachPaths = true,
        }
      },
    },
  })
end
```

## Autocmd example

```lua
vim.api.nvim_create_autocmd('BufEnter', {
  -- Further contrains
  -- pattern = { '*.sh', '*.bash', '*.zsh' },
  callback = function()
    local util = require('lspconfig.util')
    vim.lsp.start({
      -- Client name
      name = 'bashls',
      -- Lsp client command
      cmd = { 'bash-language-server', 'start' },
      -- Settings for lsp server
      settings = {
        bashIde = {
          -- Glob pattern for finding and parsing shell script files in the workspace.
          -- Used by the background analysis features across files.

          -- Prevent recursive scanning which will cause issues when opening a file
          -- directly in the home directory (e.g. ~/foo.sh).
          --
          -- Default upstream pattern is "**/*@(.sh|.inc|.bash|.command)".
          globPattern = vim.env.GLOB_PATTERN or bashls_opts.settings.bashIde.globPattern,
        },
      },
      -- File type to attach to
      filetypes = { 'sh' },
      -- Find root by finding root of git dir
      root_dir = util.find_git_ancestor,
      -- ???
      single_file_support = true,
    })
  end
})
```

