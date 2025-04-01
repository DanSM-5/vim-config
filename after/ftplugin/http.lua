if vim.fn.exists(':KulalaRun') == 0 then
  -- Attempt to load commands if kulala exists
  require('config.nvim_kulala').set_commands()
end


local has_kulala = pcall(require, 'kulala')
if has_kulala then
  local buffer = vim.api.nvim_get_current_buf()
  require('config.nvim_kulala').set_keymaps({ buf = buffer })
end

