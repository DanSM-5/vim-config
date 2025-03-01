return {
  'Skardyy/neo-img',
  -- Only load if we have the dependency installed
  config = function ()
    require('neo-img').setup()
  end
}

