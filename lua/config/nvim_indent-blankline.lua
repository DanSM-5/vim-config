return {
  setup = function ()
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
