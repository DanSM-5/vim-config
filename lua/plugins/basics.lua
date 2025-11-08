---@module 'lazy'

---@type LazyPluginSpec[]
return {
  {
    -- Raplace text using motions and prevent saving replaced text
    -- Mapped to `cr` for motions
    'inkarkat/vim-ReplaceWithRegister',
    event = 'VeryLazy',
  },
  {
    -- Functions to copy to clipboard using motions
    'DanSM-5/vim-system-copy',
  },
  {
    -- Multi cursor plugin
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
    -- Helper function to make functions/keymaps dot repeatable
    'tpope/vim-repeat',
  },
  {
    -- Add `Repeatable` command to improve vim-repeat ergonomics
    'kreskij/Repeatable.vim',
    dependencies = {
      'tpope/vim-repeat',
    },
    cmd = { 'Repeatable' },
  },
  {
    -- Allow move in camel case, snake case and kebab case
    'bkad/CamelCaseMotion',
    event = 'VeryLazy',
  },
  {
    -- Improve '*' and '#' functionality
    'haya14busa/vim-asterisk',
    event = 'VeryLazy',
  },
  {
    -- Request save file as sudo
    'lambdalisue/vim-suda',
    cmd = { 'SudaRead', 'SudaWrite' }
  },
  {
    -- Smooth scroll functions
    'psliwka/vim-smoothie',
    event = 'VeryLazy',
  },
  {
    -- Undotree UI
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
    -- Serve files similar to live-server in vscode
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
    -- Auto closing html/jsx tags
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
    -- split lines with different modes
    'wurli/split.nvim',
    keys = {
      'gs',
      'gss',
      'gS',
      'gSS'
     },
    opts = {},
  },
  {
    -- Add option to Diff changes with swap file
    'chrisbra/Recover.vim',
  }
}

