return {
  setup = function()
    -- vim.api.nvim_set_hl(0, 'RainbowUnderlineCyan', {
    --   force = true,
    --   underline = true,
    --   sp = '#56b6c2',
    -- })

    require('blink.indent').setup({
      blocked = {
        -- default: 'terminal', 'quickfix', 'nofile', 'prompt'
        buftypes = { include_defaults = true },
        -- default: 'lspinfo', 'packer', 'checkhealth', 'help', 'man', 'gitcommit', 'dashboard', ''
        filetypes = { include_defaults = true, 'fzf', 'fugitive' },
      },
      static = {
        enabled = true,
        char = '▏',
        priority = 1,
        -- specify multiple highlights here for rainbow-style indent guides
        -- highlights = { 'BlinkIndentRed', 'BlinkIndentOrange', 'BlinkIndentYellow', 'BlinkIndentGreen', 'BlinkIndentViolet', 'BlinkIndentCyan' },
        highlights = { 'BlinkIndent' },
      },
      scope = {
        enabled = false,
        char = '▏',
        priority = 1000,
        -- set this to a single highlight, such as 'BlinkIndent' to disable rainbow-style indent guides
        -- highlights = { 'BlinkIndentScope' },
        -- optionally add: 'BlinkIndentRed', 'BlinkIndentCyan', 'BlinkIndentYellow', 'BlinkIndentGreen'
        highlights = {
          -- 'BlinkIndentOrange',
          -- 'BlinkIndentViolet',
          -- 'BlinkIndentBlue',
          'RainbowCyan',
        },
        -- enable to show underlines on the line above the current scope
        underline = {
          enabled = false,
          -- optionally add: 'BlinkIndentRedUnderline', 'BlinkIndentCyanUnderline', 'BlinkIndentYellowUnderline', 'BlinkIndentGreenUnderline'
          highlights = {
            -- 'BlinkIndentOrangeUnderline',
            -- 'BlinkIndentVioletUnderline',
            -- 'BlinkIndentBlueUnderline',
            'RainbowUnderlineCyan',
          },
        },
      },
    })
  end,
}
