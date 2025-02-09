return {
  -- Only load if we have the dependency installed
  enabled = vim.fn.executable('ttyimg') == 1,
  'Skardyy/neo-img',
  opts = {},
}

