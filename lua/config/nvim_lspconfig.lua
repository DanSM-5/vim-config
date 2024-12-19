return {
  setup = function()
    -- Global diagnostic mappings
    -- See `:help vim.diagnostic.*` for documentation on any of the below functions
    vim.keymap.set(
      'n',
      '<space>e',
      vim.diagnostic.open_float,
      { desc = 'LSP: Open float window', silent = true, noremap = true }
    )
    vim.keymap.set('n', '<space>l', vim.diagnostic.setloclist, { desc = 'LSP: Open diagnostic list', silent = true })
    vim.keymap.set('n', '<space>q', vim.diagnostic.setqflist , { desc = 'LSP: Open diagnostic list', silent = true })

    -- vim.keymap.set("n", "<leader>L", function()
    --   if vim.fn.search("https*://") > 0 then
    --     vim.ui.open(vim.fn.expand("<cfile>"))
    --   end
    -- end, { desc = "Open next link", silent = true })
  end,
}

