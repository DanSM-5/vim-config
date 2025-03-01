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
      vim.cmd('colorscheme onedark')
      vim.cmd('hi CursorLine guibg=#313640')
      require('config.treesitter_context').setup()


      -- Original
      -- vim.cmd('hi PmenuSel guibg=#2f333d')
      vim.api.nvim_set_hl(0, 'PmenuSel', { link = 'Visual', force = true })
      vim.api.nvim_set_hl(0, 'QuickFixLine', { link = 'CursorLine', force = true })

      require('shared.highlights').set_diagnostics()

      -- Set variables for ToggleBg
      local g = vim.g
      g.theme_hidden_normal = 'hi Normal guibg=NONE ctermbg=NONE'
      g.theme_hidden_visual = 'hi Visual guibg=#39496e'
      g.theme_hidden_normalNC = 'hi NormalNC guibg=NONE ctermbg=NONE'
      -- g.theme_hidden_lineNr = 'hi LineNr guibg=NONE guifg=#7f848e'
      g.theme_hidden_lineNr = 'hi LineNr guibg=NONE guifg=#919baa'
      g.theme_hidden_signColumn = 'hi SignColumn guibg=NONE'
      g.theme_hidden_cursorLineNr = 'hi CursorLineNr guibg=#313640'
      -- g.theme_hidden_cursorLine = ''
      -- g.theme_comment = ''

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

