return {
  setup = function()
    require('aerial').setup({
      --NOTE: Commented in favor of repeatable bindings in demicolon
      -- on_attach = function(bufnr)
      --   vim.keymap.set('n', '[a', '<cmd>AerialPrev<CR>', { buffer = bufnr })
      --   vim.keymap.set('n', ']a', '<cmd>AerialNext<CR>', { buffer = bufnr })
      -- end,
    })

    vim.keymap.set('n', '<leader>ta', '<cmd>AerialToggle!<cr>', { desc = '[Aerial] Toggle window', noremap = true })
    vim.keymap.set('n', '<leader>fa', '<cmd>call aerial#fzf()<cr>', { desc = '[Aerial] Aerial fzf selector', noremap = true })
  end,
}
