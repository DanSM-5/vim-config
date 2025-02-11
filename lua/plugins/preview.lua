return {
  'Skardyy/neo-img',
  -- Only load if we have the dependency installed
  enabled = vim.fn.executable('ttyimg') == 1,
  event = 'VeryLazy',
  opts = {},
}

