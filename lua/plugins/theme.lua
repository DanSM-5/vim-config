-- Theme config
return {
  -- {
  --   'sonph/onehalf', -- { 'rtp': 'vim' },
  --   lazy = false,
  --   name = 'onehalfdark',
  --   priority = 1000,
  --   config = function (plugin)
  --     vim.opt.rtp:append(plugin.dir .. '/vim')
  --     vim.cmd('colorscheme onehalfdark')
  --     vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1
  --   end
  -- },
  -- {
  --   'navarasu/onedark.nvim',
  --   lazy = false,
  --   priority = 1000,
  --   config = function ()
  --     local onedark = require('onedark')

  --     onedark.setup({
  --       style = 'cool'
  --     })
  --     onedark.load()
  --   end

  -- },
  {
    'olimorris/onedarkpro.nvim',
    lazy = false,
    priority = 1000,
    config = function ()
      -- For simple use cases, below line is all that's needed
      vim.cmd.colorscheme('onedark')
      vim.cmd('hi CursorLine guibg=#313640')
      require('config.treesitter_context').setup()


      -- Original
      -- vim.cmd('hi PmenuSel guibg=#2f333d')
      vim.api.nvim_set_hl(0, 'PmenuSel', { link = 'Visual', force = true })
      vim.api.nvim_set_hl(0, 'QuickFixLine', { link = 'CursorLine', force = true })
      vim.api.nvim_set_hl(0, 'Comment', { fg = '#7f848e', ctermfg = 102 , force = true })
      vim.api.nvim_set_hl(0, 'LspInlayHint', { link = 'Comment', force = true })

      require('shared.highlights').setup()

      -- Set variables for ToggleBg
      -- g.theme_hidden_cursorLine = ''
      -- g.theme_comment = ''

      ---@type [string, string, string][]
      vim.g.theme_toggle_hi = vim.tbl_deep_extend('force',
        vim.g.theme_toggle_hi, {
        vim.fn.Std_hlt('Normal'),
        vim.fn.Std_hlt('Visual', 'hi Visual guibg=#39496e'),
        vim.fn.Std_hlt('NormalNC'),
        vim.fn.Std_hlt('LineNr', 'hi LineNr guibg=NONE guifg=#919baa'),
        vim.fn.Std_hlt('CursorLine', ':'),
        vim.fn.Std_hlt('CursorLineNr', 'hi CursorLineNr guibg=#313640'),
        vim.fn.Std_hlt('SignColumn'),
      })

      -- Normal, NormalNC, LineNr
      -- CursorLineNr

      -- NOTE: below code kept as reference

      -- -- NOTE: According to theme documentation
      -- -- the folloing groups are used to set the transparency
      -- -- Normal, Folded, SignColumn, Statusline and Tabline

      -- It can be setup manually as well
      -- local onedarkpro = require('onedarkpro')
      -- onedarkpro.setup({})
      -- onedarkpro.load()

      -- -- Remove command created in config
      -- vim.api.nvim_del_user_command('ToggleBg')

      -- -- Recreate ToggleBg functionality
      -- local transparent = false
      -- vim.api.nvim_create_user_command('ToggleBg', function ()
      --   transparent = not transparent
      --   onedarkpro.setup({
      --     options = {
      --       transparency = transparent
      --     }
      --   })
      --   onedarkpro.load()

      --   -- NOTE: using transparency with this plugging
      --   -- is causing the following plugins to lose colors
      --   local todo_comments = require('todo-comments')
      --   local lualine = require('lualine')

      --   -- Colors get removed on every toggle
      --   if todo_comments ~= nil then
      --     todo_comments.setup()
      --   end
      --   -- Colors get removed on first call
      --   if lualine ~= nil then
      --     lualine.setup()
      --   end
      -- end, {})
    end
  }
}

