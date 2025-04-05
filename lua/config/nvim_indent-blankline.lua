return {
  setup = function ()
    local hooks = require('ibl.hooks')
    -- create the highlight groups in the highlight setup hook, so they are reset
    -- every time the colorscheme changes
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      vim.api.nvim_set_hl(0, 'RainbowRed', { fg = '#E06C75' })
      vim.api.nvim_set_hl(0, 'RainbowGrey', { fg = '#3b4048' })
    end)
    -- Configure to enable ibl only
    require('ibl').setup({
      indent = {
        highlight = { 'RainbowGrey' },
        char = '▎',
      },
      whitespace = {
        remove_blankline_trail = true,
      },
      scope = {
        enabled = false,
        highlight = { 'RainbowRed' },
      },
    })
  end,
}
