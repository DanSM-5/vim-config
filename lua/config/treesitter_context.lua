return {
  setup = function ()
    -- TSContext highlight groups
    vim.cmd([[
      hi link TreesitterContext Normal
      hi TreesitterContextBottom gui=underline guisp=Grey
      hi TreesitterContextLineNumberBottom gui=underline guisp=Grey
    ]])


    vim.keymap.set("n", "<leader>cu", function()
      require("treesitter-context").go_to_context(vim.v.count1)
    end, { silent = true, desc = '[Treesitter Context] Context Up' })
  end
}
