---@module 'lazy'

---@type (string|LazyPluginSpec)[]
return {
  -- {
  --   'lukas-reineke/indent-blankline.nvim',
  --   event = 'VeryLazy',
  --   main = 'ibl',
  --   config = function ()
  --     require('config.nvim_indent-blankline').setup()
  --   end,
  -- },

  -- {
  --   'nvim-mini/mini.indentscope',
  --   event = 'VeryLazy',
  --   config = function ()
  --     require('config.nvim_mindent').setup()
  --   end,
  -- },

  {
    'saghen/blink.indent',
    event = 'VeryLazy',
    config = function()
      require('config.nvim_blink_indent').setup()
    end,
  },

  {
    -- Highlight matching words under the cursor
    'xiyaowong/nvim-cursorword',
    event = 'VeryLazy',
    config = function()
      -- NOTE: consider to keep or remove the background color and just keep the underline

      -- vim.cmd('hi CursorWord gui=underline cterm=underline guibg=#4b5263')
      vim.api.nvim_set_hl(
        0,
        'CursorWord',
        { underline = true, cterm = { underline = true }, bg = '#4b5263', force = true }
      )
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      extensions = {
        'aerial',
        'fugitive',
        'fzf',
        'lazy',
        'mason',
        'neo-tree',
        'oil',
        'quickfix',
      },
      options = {
        theme = 'onedark',
      },
    },
  },
}
