---@module 'lazy'

---@type LazyPluginSpec[]
return {
  {
    'tpope/vim-fugitive',
    event = 'VeryLazy',
    dependencies = {
      'tpope/vim-rhubarb',
    },
  },
  {
    'lewis6991/gitsigns.nvim',
    event = 'VeryLazy',
    commit = 'fcfa7a989',
    -- commit = 'c852602',
    config = function ()
      require('config.nvim_gitsigns').setup()
    end,
  },
  {
    'jecaro/fugitive-difftool.nvim',
    cmd = {
      -- To the first
      'Gcfr',
      -- To the last
      'Gcla',
      -- To the next
      'Gcn',
      -- To the previous
      'Gcp',
      -- To the currently selected
      'Gcc',
    },
    -- Usage
    -- :Git! difftool --name-status master..my-feature
    -- :Gcc
    config = function ()
      require('config.nvim_fugitive-difftool').setup()
    end,
  },
  {
    'rbong/vim-flog',
    lazy = true,
    cmd = { 'Flog', 'Flogsplit', 'Floggit' },
    dependencies = {
      'tpope/vim-fugitive',
    },
  },
  {
    'oflisback/cursor-git-ref-command.nvim',
    cmd = {
      'CursorCheckOut',
      'CursorCherryPick',
      'CursorDrop',
      'CursorResetHard',
      'CursorResetMixed',
      'CursorResetSoft',
    },
    config = function ()
      require('config.nvim_cursor_ref').setup()
    end,
  },
  -- Disabled to avoid conflicts with diffs.nvim
  -- {
  --   'santhosh-tekuri/wordiff.nvim',
  --   ft = { 'diff', 'gitcommit', 'git' },
  --   opts = {},
  -- },

  -- Disabled due to performance issues
  -- {
  --   'farhanmustar/fugitive-delta.nvim',
  --   ft = { 'git', 'gvgit', 'diff' },
  -- },
  {
    'DanSM-5/diffs.nvim',
    -- ft = { 'git', 'gvgit', 'diff' },
    init = function (self)
      vim.g.diffs = {
        fugitive = true,
        -- extra_filetypes = { 'git', 'gvgit', 'diff' },
      }
    end,
    config = function (self, opts)
      local group = vim.api.nvim_create_augroup('diffs_nvim', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        group = group,
        pattern = { 'git', 'gvgit', 'diff' },
        callback = function(event)
          require('diffs').attach(event.buf)
        end,
      })
    end
  },
}

