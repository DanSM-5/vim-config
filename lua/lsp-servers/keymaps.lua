local exclude_filetypes = {
  'help',
}

return {
  setup = function()
    -- Global mappings
    -- See `:help vim.diagnostic.*` for documentation on any of the below functions
    vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, { desc = 'LSP: Open float window' })
    vim.keymap.set('n', '<space>l', vim.diagnostic.setloclist, { desc = 'LSP: Open diagnostic list' })
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'LSP: Go to previous diagnostic message' })
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'LSP: Go to next diagnostic message' })

    -- vim.keymap.set("n", "<leader>L", function()
    --   if vim.fn.search("https*://") > 0 then
    --     vim.ui.open(vim.fn.expand("<cfile>"))
    --   end
    -- end, { desc = "Open next link", silent = true })

    -- Use LspAttach autocommand to only map the following keys
    -- after the language server attaches to the current buffer
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('UserLspConfig', {}),
      callback = function(ev)

        -- Prevent adding keymaps if we are excluding specific file types such as help
        -- Other options could be trying to set negative pattern in filetype
        -- See: https://groups.google.com/g/vim_use/c/I_ssfzT8FD8
        -- e.g.
        -- ```
        -- something like below fails
        -- autocmd BufReadPost *, !.git/COMMIT_EDITMSG  <do stuff>
        --
        -- but it is possible like
        -- :autocmd BufReadPost *\(.git/COMMIT_EDITMSG\)\@<! <do stuff>
        -- ```
        if
          vim.tbl_contains(exclude_filetypes, vim.bo[ev.buf].buftype)
          or vim.tbl_contains(exclude_filetypes, vim.bo[ev.buf].filetype)
        then
          return
        end

        -- Enable completion triggered by <C-x><C-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Wrapper for setting maps with description
        local set_map = function(mode, key, func, desc)
          local opts = { buffer = ev.buf }

          if desc then
            opts.desc = desc
          end

          vim.keymap.set(mode, key, func, opts)
        end

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        set_map('n', 'gD', vim.lsp.buf.declaration, 'LSP: Go to declaration')
        set_map('n', 'gd', vim.lsp.buf.definition, 'LSP: Go to definition')
        set_map('n', 'gv', '<cmd>vsplit | lua vim.lsp.buf.definition()<CR>', 'LSP: Go to definition in vsplit')
        set_map('n', 'K', vim.lsp.buf.hover, 'LSP: Hover action')
        set_map('n', 'gi', vim.lsp.buf.implementation, 'LSP: Go to implementation')
        set_map('n', '<C-k>', vim.lsp.buf.signature_help, 'LSP: Show signature help')
        set_map('n', '<space>wa', vim.lsp.buf.add_workspace_folder, 'LSP: Add workspace')
        set_map('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, 'LSP: Remove workspace')
        set_map('n', '<space>wl', function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, 'LSP: List workspaces')
        set_map('n', '<space>D', vim.lsp.buf.type_definition, 'LSP: Go to type definition')
        set_map('n', '<space>rn', vim.lsp.buf.rename, 'LSP: Rename symbol')
        set_map('n', '<f2>', vim.lsp.buf.rename, 'LSP: Rename symbol')
        set_map({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, 'LSP: Code Actions')
        set_map('n', 'gr', vim.lsp.buf.references, 'LSP: Go to references')
        set_map('n', '<space>f', function()
          vim.lsp.buf.format({ async = true })
        end, 'LSP: Format buffer')
        set_map('n', '<space>Ic', vim.lsp.buf.incoming_calls, 'LSP: Incoming Calls')
        set_map('n', '<space>Oc', vim.lsp.buf.outgoing_calls, 'LSP: Outgoing Calls')

        vim.keymap.set('n', '<space>ne', function()
          vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR, wrap = true })
        end, { desc = 'LSP: Go to next error' })
        vim.keymap.set('n', '<space>nw', function()
          vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN, wrap = true })
        end, { desc = 'LSP: Go to next warning' })
        vim.keymap.set('n', '<space>ni', function()
          vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.HINT })
        end, { desc = 'LSP: Go to next hint' })

        vim.keymap.set('n', '<space>nE', function()
          vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR, wrap = true })
        end, { desc = 'LSP: Go to previous error' })
        vim.keymap.set('n', '<space>nW', function()
          vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN, wrap = true })
        end, { desc = 'LSP: Go to previous warning' })
        vim.keymap.set('n', '<space>nI', function()
          vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.HINT })
        end, { desc = 'LSP: Go to previous hint' })
      end,
    })
  end,
}
