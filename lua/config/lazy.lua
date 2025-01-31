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
  spec = {
    -- import your plugins
    { import = "plugins" },
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
          -- require('lazy.util').float_term({ 'git', 'log', '--oneline', '--decorate', '--graph' }, { cwd = plugin.dir })
          -- TODO: Consider make the fshow script a standalone script in path "user-scripts"
          -- rather than a utility script.
          local script_preview = vim.fn.stdpath('config') .. '/utils/lazy-git-preview'
          ---@type string[]
          local script_cmd = {}

          if vim.fn.has('win32') == 1 then
            script_cmd = { '-NoLogo', '-NonInteractive', '-NoProfile', '-File', script_preview .. '.ps1' }
            if vim.fn.executable('pwsh') then
              table.insert(script_cmd, 1, 'pwsh.exe')
            else
              table.insert(script_cmd, 1, 'powershell.exe')
            end
          else
            script_cmd = { script_preview .. '.sh' }
          end

          require('utils.nvim').float_term(script_cmd, {
            cwd = plugin.dir,
          })
        end,
        desc = '[Lazy.nvim] Open plugin log',
      },
    },
  },
})

