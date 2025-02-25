local search_dir = function()
  -- get the current directory
  local prefills = { paths = require('oil').get_current_dir() }
  require('config.nvim_grugfar').open_from_explorer(prefills)
end

return {
  setup = function()
    require('oil').setup({
      -- Set to empty table to hide icons
      keymaps {
        ge = {
          callback = search_dir,
          desc = '[Oil] Search in directory'
        }
      }
    })
    -- Imitate vinegar '-' map
    vim.keymap.set('n', '<leader>-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
  end,
  search_dir = search_dir,
}

