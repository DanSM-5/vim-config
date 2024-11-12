return {
  -- built-in in neovim 0.10
  -- {
  --   'tpope/vim-commentary'
  -- },
  -- Using lua version
  -- {
  --   'tpope/vim-surround'
  -- },
  {
    'tpope/vim-fugitive',
    dependencies = {
      'tpope/vim-rhubarb'
    }
  },
  {
    'tpope/vim-repeat',
  },
  {
    'inkarkat/vim-ReplaceWithRegister',
  },
  {
    'christoomey/vim-sort-motion',
  },
  {
    'DanSM-5/vim-system-copy',
  },
  {
    'junegunn/fzf',
  },
  {
    'junegunn/fzf.vim',
  },
  {
    'mg979/vim-visual-multi',
    config = function ()
      -- Create highlight groups for VM
      vim.api.nvim_set_hl(0, 'VM_Custom_Cursor', { ctermfg = 0, ctermbg = 239, bg = '#39496e' })
      vim.api.nvim_set_hl(0, 'VM_Custom_Extend', { ctermfg = 188, ctermbg = 75, fg = '#dcdfe4', bg = '#61afef', blend = 0 })
      -- Cursro color: guifg=#282c34 guibg=#c678dd
      -- vim.api.nvim_set_hl(0, 'VM_Custom_Extend', { ctermfg = 188, ctermbg = 75, fg = '#282c34', bg = '#c678dd', blend = 0 })
      -- vim.api.nvim_set_hl(0, 'VM_Custom_Extend', { ctermfg = 188, ctermbg = 75, fg = '#282c34', bg = '#39496e', blend = 0 })
      vim.api.nvim_set_hl(0, 'VM_Custom_Insert', { ctermfg = 180, fg = '#e5c07b' })
      vim.api.nvim_set_hl(0, 'VM_Custom_Mono', { ctermfg = 236, ctermbg = 180, fg = '#282c34', bg = '#e5c07b' })
      -- NOTE: Global variables seems to have no effect?
      -- vim.g.VM_Cursor_hl = 'VM_Custom_Cursor'
      -- vim.g.VM_Extend_hl = 'VM_Custom_Extend'
      -- vim.g.VM_Insert_hl = 'VM_Custom_Insert'
      -- vim.g.VM_Mono_hl = 'VM_Custom_Mono'
      vim.api.nvim_set_hl(0, 'VM_Cursor', { link = 'VM_Custom_Cursor', force = true })
      vim.api.nvim_set_hl(0, 'VM_Extend', { link = 'VM_Custom_Extend', force = true })
      vim.api.nvim_set_hl(0, 'VM_Insert', { link = 'VM_Custom_Insert', force = true })
      vim.api.nvim_set_hl(0, 'VM_Mono', { link = 'VM_Custom_Mono', force = true })
    end
  },
  {
    'dyng/ctrlsf.vim',
  },
  {
    'kreskij/Repeatable.vim',
    cmd = { 'Repeatable' },
  },
  {
    'bkad/CamelCaseMotion',
  },
  {
    'haya14busa/vim-asterisk',
  },
  {
    'lambdalisue/vim-suda',
    cmd = { 'SudaRead', 'SudaWrite' }
  },
  {
    'psliwka/vim-smoothie',
  },
  -- {
  --   'airblade/vim-gitgutter'
  -- },
  {
    'xiyaowong/nvim-cursorword',
    config = function()
      -- NOTE: consider to keep or remove the background color and just keep the underline
      vim.cmd('hi CursorWord gui=underline cterm=underline guibg=#4b5263')
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
    'stevearc/oil.nvim',
    config = require('config.oil_nvim').setup,
  },
  {
    'OXY2DEV/helpview.nvim',
    lazy = false, -- Recommended

    -- In case you still want to lazy load
    -- ft = "help",

    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
  },
  {
    'mbbill/undotree',
    lazy = true,
    keys = { '<leader>u' },
    cmd = { 'UndotreeToggle', 'UndotreeShow' },
    -- config = function ()
    --   vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = '[UndoTree] Toggle undo tree' })
    -- end
  },
  {
    'hat0uma/prelive.nvim',
    cmd = {
      'PreLiveGo',
      'PreLiveStatus',
      'PreLiveClose',
      'PreLiveCloseAll',
      'PreLiveLog',
    },
    config = require('config.nvim_prelive').setup
  },
  {
    'windwp/nvim-ts-autotag',
    config = function ()
      require('nvim-ts-autotag').setup({
        opts = {
          -- Defaults
          enable_close = true, -- Auto close tags
          enable_rename = true, -- Auto rename pairs of tags
          enable_close_on_slash = false, -- Auto close on trailing </
        },
      })
    end
  },
  {
    "OXY2DEV/markview.nvim",
    lazy = false,      -- Recommended
    -- ft = "markdown" -- If you decide to lazy-load anyway
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons"
    },
    config = require('config.nvim_markview').setup,
  }
}

