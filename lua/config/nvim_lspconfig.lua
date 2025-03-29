return {
  setup = function()
    -- Global diagnostic mappings
    -- See `:help vim.diagnostic.*` for documentation on any of the below functions
    vim.keymap.set(
      'n',
      '<space>e',
      vim.diagnostic.open_float,
      { desc = '[Lsp] Open float window', silent = true, noremap = true }
    )
    vim.keymap.set(
      'n',
      '<space>E',
      function ()
        local curr_config = vim.diagnostic.config()
        vim.diagnostic.config({ virtual_lines = { current_line = true }, virtual_text = false })

        local unset = function ()
          vim.diagnostic.config(curr_config)
          pcall(vim.keymap.del, 'n', '<esc>', { buffer = true })
        end

        vim.keymap.set('n', '<esc>', function ()
          unset()
        end, { silent = true, buffer = true, desc = '[Diagnostic] Hide virtual lines' })

        vim.api.nvim_create_autocmd('CursorMoved', {
          once = true,
          desc = '[Diagnostic] Hide virtual lines',
          callback = unset
        })
      end,
      { desc = '[Lsp] Open virtual lines', silent = true, noremap = true }
    )
    vim.keymap.set('n', '<space>l', vim.diagnostic.setloclist, { desc = 'LSP: Open diagnostic list', silent = true })
    vim.keymap.set('n', '<space>q', vim.diagnostic.setqflist , { desc = 'LSP: Open diagnostic list', silent = true })

    -- Signs for diagnostics
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end
    -- vim.diagnostic.config({
    --   signs = { text = {
    --     [vim.diagnostic.severity.ERROR] = signs.Error,
    --     [vim.diagnostic.severity.WARN] = signs.Warn,
    --     [vim.diagnostic.severity.HINT] = signs.Hint,
    --     [vim.diagnostic.severity.INFO] = signs.Info,
    --   } }
    -- })

    -- Start diagnostics (virtual text) enabled
    vim.diagnostic.config({
      virtual_text = true,
      -- Alternatively, customize specific options
      -- virtual_lines = {
      --   -- Only show virtual line diagnostics for the current cursor line
      --   current_line = true,
      -- },
    })

    -- Start with inlay hints enabled
    vim.lsp.inlay_hint.enable(true)

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

