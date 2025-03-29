return {
  setup = function ()
    -- Configure to enable ibl only
    require('ibl').setup({
      indent = {
        highlight = { 'RainbowGrey' },
        char = '▎',
      },
      scope = {
        enabled = false
      },
    })
  end,
}
