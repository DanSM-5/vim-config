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
    'inkarkat/vim-ReplaceWithRegister',
    event = 'VeryLazy',
  },
  -- {
  --   'christoomey/vim-sort-motion',
  -- },
  {
    'DanSM-5/vim-system-copy',
    event = 'VeryLazy',
  },
  {
    'mg979/vim-visual-multi',
    event = 'VeryLazy',
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
    'tpope/vim-repeat',
  },
  {
    'kreskij/Repeatable.vim',
    dependencies = {
      'tpope/vim-repeat',
    },
    cmd = { 'Repeatable' },
  },
  {
    'bkad/CamelCaseMotion',
    event = 'VeryLazy',
  },
  {
    'haya14busa/vim-asterisk',
    event = 'VeryLazy',
  },
  {
    'lambdalisue/vim-suda',
    cmd = { 'SudaRead', 'SudaWrite' }
  },
  {
    'psliwka/vim-smoothie',
    event = 'VeryLazy',
  },
  -- {
  --   'airblade/vim-gitgutter'
  -- },
  {
    'xiyaowong/nvim-cursorword',
    event = 'VeryLazy',
    config = function()
      -- NOTE: consider to keep or remove the background color and just keep the underline
      vim.cmd('hi CursorWord gui=underline cterm=underline guibg=#4b5263')
    end,
  },
  {
    'mbbill/undotree',
    lazy = true,
    keys = {
      { '<leader>u', '<cmd>UndotreeToggle<cr>', desc = '[Undotree]: Toggle Undotree' }
    },
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
    config = function ()
      require('config.nvim_prelive').setup()
    end,
  },
  {
    'windwp/nvim-ts-autotag',
    ft = {
      'astro',
      'glimmer',
      'handlebars',
      'html',
      'javascript',
      'jsx',
      'markdown',
      'php',
      'rescript',
      'svelte',
      'tsx',
      'twig',
      'typescript',
      'vue',
      'xml',
    },
    config = function ()
      require('nvim-ts-autotag').setup({
        opts = {
          -- Defaults
          enable_close = true, -- Auto close tags
          enable_rename = true, -- Auto rename pairs of tags
          enable_close_on_slash = false, -- Auto close on trailing </
        },
      })
    end,
  },
  {
    'wurli/split.nvim',
    keys = { 'gs', 'gss', 'gS', 'gSS' },
    opts = {},
  },
}

