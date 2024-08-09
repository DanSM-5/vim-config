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
      vim.cmd('colorscheme onedark')
    end
  }
}

