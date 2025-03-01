-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
local uv = vim.uv or vim.loop
if not uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out,                            'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

-- Disable updates check if file exists
local check_for_updates = not (uv.fs_stat(vim.fn.stdpath('config') .. '/.no_updates_check'))

-- Setup lazy.nvim
require("lazy").setup({
  ---@type LazySpec
  spec = {
    -- import your plugins
    import = 'plugins',
    -- NOTE: Comment above and uncomment below to only load neo-img and oil
    -- {
    --   import = 'plugins.preview',
    -- },
    -- {
    --   import = 'plugins.explorer'
    -- }
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  -- install = { colorscheme = { "habamax" } },
  install = { colorscheme = { "onehalfdark" } },
  -- automatically check for plugin updates
  checker = { enabled = check_for_updates, notify = false },
  -- change_detection = { enabled = false }
  ui = {
    icons = {
      cmd = " ",
      config = '🛠',
      event = '📅',
      favorite = '🌟',
      ft = '📂',
      init = '⚙',
      import = ' ',
      keys = '🗝',
      plugin = '🔌',
      loaded = '🔋',
      not_loaded = '🪫',
      runtime = ' ',
      require = '󰢱 ',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
      list = {
        '●',
        '➜',
        '★',
        '‒',
      },
    },
    custom_keys = {
      -- An external dependency is the default for <leader>l... WTF!!!
      ['<localleader>l'] = {
        function (plugin)
          -- NOTE: Termux refuses to execute scripts even if
          -- they are on the path. Using simple logger.
          if vim.g.is_termux == 1 then
            require('utils.fshow').git_log(plugin.dir)
          else
            require('utils.fshow').fshow(plugin.dir)
          end
        end,
        desc = '[Lazy.nvim] Open plugin log',
      },
    },
  },
})

