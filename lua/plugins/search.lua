return {
  'MagicDuck/grug-far.nvim',
  lazy = true,
  keys = {
    '<c-t>t',
    { '<c-t>w', mode = { 'n', 'v' } },
    { '<c-t>W', mode = { 'n', 'v' } },
    { '<c-t>f', mode = { 'n' } },
  },
  cmd = {
    'GrugFarFile',
    'GrugFarSearch',
  },
  config = function ()
    require('config.nvim_grugfar').setup()
  end
}

