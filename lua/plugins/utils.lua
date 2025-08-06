---@module 'lazy'

---@type LazyPluginSpec[]
return {
  -- lua only http client
  -- {
  --   'sfenzke/http-client.nvim',
  --   opts = {},
  --   lazy = true,
  -- },
  {
    'LionyxML/nvim-0x0',
    -- lazy = true,
    keys = {
      '<leader>0f',
      { '<leader>0s', mode = 'v' },
      '<leader>0y',
      { '<leader>0o', ft = 'oil' },
    },
    opts = {
      -- base_url = 'https://custom_instance'
      use_default_keymaps = true,
    },
    -- config = function()
    --   vim.keymap.set('n', '<leader>0f', require('nvim-0x0').upload_current_file, { desc = 'Upload current file' })
    --   vim.keymap.set('v', '<leader>0s', require('nvim-0x0').upload_selection, { desc = 'Upload selection' })
    --   vim.keymap.set('n', '<leader>0y', require('nvim-0x0').upload_yank, { desc = 'Upload yank' })
    --   vim.keymap.set('n', '<leader>0o', require('nvim-0x0').upload_oil_file, { desc = 'Upload oil.nvim file' })
    -- end
  },
  {
    'amadeus/vim-convert-color-to',
    cmd = { 'ConvertColorTo' },
    -- Also consider: NTBBloodbath/color-converter.nvim
  },
  {
    'brianhuster/unnest.nvim'
  },
}

