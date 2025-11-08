---@module 'lazy'

---@type (string|LazyPluginSpec)[]
return {
  {
    'lukas-reineke/indent-blankline.nvim',
    event = 'VeryLazy',
    main = 'ibl',
    config = function ()
      require('config.nvim_indent-blankline').setup()
    end,
  },
  {
    'nvim-mini/mini.indentscope',
    event = 'VeryLazy',
    config = function ()
      require('config.nvim_mindent').setup()
    end,
  },

  -- NOTE: blink.indent works perfectly for indent and
  -- highlight the active indent (maybe more performant)
  -- but it will miss the `ii` (indent text object)

  -- {
  --   'saghen/blink.indent',
  --   event = 'VeryLazy',
  --   config = function ()
  --     vim.api.nvim_set_hl(0, 'RainbowUnderlineCyan', {
  --       force = true,
  --       underline = true,
  --       sp = '#56b6c2',
  --     })

  --     require('blink.indent').setup({
  --       blocked = {
  --         -- default: 'terminal', 'quickfix', 'nofile', 'prompt'
  --         buftypes = { include_defaults = true },
  --         -- default: 'lspinfo', 'packer', 'checkhealth', 'help', 'man', 'gitcommit', 'dashboard', ''
  --         filetypes = { include_defaults = true, 'fzf', 'fugitive' },
  --       },
  --       static = {
  --         enabled = true,
  --         char = '▏',
  --         priority = 1,
  --         -- specify multiple highlights here for rainbow-style indent guides
  --         -- highlights = { 'BlinkIndentRed', 'BlinkIndentOrange', 'BlinkIndentYellow', 'BlinkIndentGreen', 'BlinkIndentViolet', 'BlinkIndentCyan' },
  --         highlights = { 'BlinkIndent' },
  --       },
  --       scope = {
  --         enabled = true,
  --         char = '▏',
  --         priority = 1000,
  --         -- set this to a single highlight, such as 'BlinkIndent' to disable rainbow-style indent guides
  --         -- highlights = { 'BlinkIndentScope' },
  --         -- optionally add: 'BlinkIndentRed', 'BlinkIndentCyan', 'BlinkIndentYellow', 'BlinkIndentGreen'
  --         highlights = {
  --           -- 'BlinkIndentOrange',
  --           -- 'BlinkIndentViolet',
  --           -- 'BlinkIndentBlue',
  --           'RainbowCyan',
  --         },
  --         -- enable to show underlines on the line above the current scope
  --         underline = {
  --           enabled = true,
  --           -- optionally add: 'BlinkIndentRedUnderline', 'BlinkIndentCyanUnderline', 'BlinkIndentYellowUnderline', 'BlinkIndentGreenUnderline'
  --           highlights = {
  --             -- 'BlinkIndentOrangeUnderline',
  --             -- 'BlinkIndentVioletUnderline',
  --             -- 'BlinkIndentBlueUnderline',
  --             'RainbowUnderlineCyan',
  --           },
  --         },
  --       },
  --     })
  --   end
  -- },
}
