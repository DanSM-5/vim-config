return {
  setup = function ()
    require('oil').setup()
    -- Imitate vinegar '-' map
    vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
  end
}

