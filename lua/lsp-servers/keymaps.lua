require('shared.types')

local exclude_filetypes = {
  'help',
}

-- NOTE: Old way of adding keymaps through 'LspAttach' autocmd
-- vim.api.nvim_create_autocmd('LspAttach', {
--   group = vim.api.nvim_create_augroup('UserLspConfig', {}),
--   callback = function (ev) end
-- })

return {
  ---Setup keymaps for lsp
  ---@param client vim.lsp.Client
  ---@param bufnr number
  set_lsp_keys = function(client, bufnr)
    local buf = bufnr

    if not buf then
      buf = vim.api.nvim_get_current_buf()
      vim.notify(
        string.format(
          'No bufnr provided by on_attach of `%s`, fallbacking to current buffer',
          client.name
        ),
      vim.log.levels.WARN)
    end

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
      vim.tbl_contains(exclude_filetypes, vim.bo[buf].buftype)
      or vim.tbl_contains(exclude_filetypes, vim.bo[buf].filetype)
    then
      return
    end

    -- Enable completion triggered by <C-x><C-o>
    -- Should now be set by default. Set anyways.
    vim.bo[buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Wrapper for setting maps with description
    ---Set keymap
    ---@param mode VimMode|VimMode[]
    ---@param key string
    ---@param func string|fun()
    ---@param desc string
    local set_map = function(mode, key, func, desc)
      local opts = { buffer = buf, silent = true, noremap = true }

      if desc then
        opts.desc = desc
      end

      vim.keymap.set(mode, key, func, opts)
    end

    --  grr gra grn gri i_CTRL-S Some keymaps are created unconditionally when Nvim starts:
    -- "grn" is mapped in Normal mode to vim.lsp.buf.rename()
    -- "gra" is mapped in Normal and Visual mode to vim.lsp.buf.code_action()
    -- "grr" is mapped in Normal mode to vim.lsp.buf.references()
    -- "gri" is mapped in Normal mode to vim.lsp.buf.implementation()
    -- "gO" is mapped in Normal mode to vim.lsp.buf.document_symbol()
    -- CTRL-S is mapped in Insert mode to vim.lsp.buf.signature_help()
    -- Ref: https://neovim.io/doc/user/lsp.html
    -- TODO: Should we change gr mapping and use defaults? 🤔
    -- Seems not to work including gO and i_<c-s> in v0.10.4

    set_map('n', '<space>td', function()
      vim.diagnostic.enable(not vim.diagnostic.is_enabled())
    end, 'LSP: Toggle diagnostics')
    set_map('n', '<space>ti', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ nil }))
    end, 'LSP: Toggle inlay hints')
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
    set_map('n', '<space>ci', vim.lsp.buf.incoming_calls, 'LSP: Incoming Calls')
    set_map('n', '<space>co', vim.lsp.buf.outgoing_calls, 'LSP: Outgoing Calls')
  end,
}

