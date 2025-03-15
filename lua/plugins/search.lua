return {
  'MagicDuck/grug-far.nvim',
  lazy = true,
  keys = {
    '<c-s><c-s>',
    { '<c-s>w', mode = { 'n', 'v' } },
    { '<c-s>W', mode = { 'n', 'v' } },
    { '<c-s>f', mode = { 'n' } },
  },
  cmd = {
    'GrugFarFile',
    'GrugFarSearch',
  },
  config = function ()
    require('config.nvim_grugfar').setup()
  end
}

