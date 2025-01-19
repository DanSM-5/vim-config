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

    -- Configure mpls server
    require('config.nvim_mpls').config()

    -- vim.keymap.set("n", "<leader>L", function()
    --   if vim.fn.search("https*://") > 0 then
    --     vim.ui.open(vim.fn.expand("<cfile>"))
    --   end
    -- end, { desc = "Open next link", silent = true })

    -- Scroll lsp window without needing to enter it
    -- TODO: Find a way to only enable keymap when preview window is visible
    --
    -- local function scrollLspWin(lines)
    --   local winid = vim.b.lsp_floating_preview --> stores id of last `vim.lsp`-generated win
    --   if not winid or not vim.api.nvim_win_is_valid(winid) then return end
    --   vim.api.nvim_win_call(winid, function()
    --     local topline = vim.fn.winsaveview().topline
    --     vim.fn.winrestview({ topline = topline + lines })
    --   end)
    -- end
    -- vim.keymap.set('n', '<PageDown>', function() scrollLspWin(5) end, { desc = '↓ Scroll LSP window' })
    -- vim.keymap.set('n', '<PageUp>', function() scrollLspWin(-5) end, { desc = '↑ Scroll LSP window' })
  end,
}

