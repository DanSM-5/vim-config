return {
  set_lazydev = function ()
    local lazydev_config = {
      library = {
        '~/vim-config',
        '~/.config/nvim',
        '~/.vim',
        '~/vimfiles',
        -- Or relative, which means they will be resolved from the plugin dir.
        -- 'lazy.nvim',
        -- 'luvit-meta/library',
        -- It can also be a table with trigger words / mods
        -- Only load luvit types when the `vim.uv` word is found
        -- { path = 'luvit-meta/library',        words = { 'vim%.uv' } },
        -- always load the LazyVim library
        -- 'LazyVim',
        -- Only load the lazyvim library when the `LazyVim` global is found
        -- { path = 'LazyVim',                   words = { 'LazyVim' } },
        -- Load the wezterm types when the `wezterm` module is required
        -- Needs `justinsgithub/wezterm-types` to be installed
        -- { path = 'wezterm-types',             mods = { 'wezterm' } },
        -- Load the xmake types when opening file named `xmake.lua`
        -- Needs `LelouchHe/xmake-luals-addon` to be installed
        -- { path = 'xmake-luals-addon/library', files = { 'xmake.lua' } },
      },
      -- always enable unless `vim.g.lazydev_enabled = false`
      -- This is the default
      ---@diagnostic disable-next-line: unused-local
      enabled = function(root_dir)
        return vim.g.lazydev_enabled == nil and true or vim.g.lazydev_enabled
      end,
      -- disable when a .luarc.json file is found
      -- enabled = function(root_dir)
      --   return not vim.uv.fs_stat(root_dir .. '/.luarc.json')
      -- end,
    }

    local lazydev = require('lazydev')
    lazydev.setup(lazydev_config)
  end,
  -- set_crates = function ()
  --   require('crates').setup({
  --     completion = {
  --       cmp = {
  --         enabled = true
  --       }
  --     }
  --   })
  -- end
}
