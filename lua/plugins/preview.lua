return {
  'Skardyy/neo-img',
  -- Only load if we have the dependency installed
  enabled = vim.fn.executable('ttyimg') == 1,
  -- event = 'VeryLazy',
  ft = { 'oil' },
  cmd = { 'NeoImg' },
  config = function ()
    require('neo-img').setup({ ttyimg = 'global' })
  end
}

