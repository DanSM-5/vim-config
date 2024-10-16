return {
  setup = function ()
    require('oil').setup({
      -- Set to empty table to hide icons
    })
    -- Imitate vinegar '-' map
    vim.keymap.set("n", "<leader>-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
  end
}

