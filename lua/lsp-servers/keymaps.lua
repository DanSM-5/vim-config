---@module 'shared.types'

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
    end, '[Lsp]: Toggle diagnostics')
    set_map('n', '<space>ti', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ nil }))
    end, '[Lsp]: Toggle inlay hints')
    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    set_map('n', 'gD', vim.lsp.buf.declaration, '[Lsp]: Go to declaration')
    set_map('n', 'gd', vim.lsp.buf.definition, '[Lsp]: Go to definition')
    set_map('n', '<space>vs', '<cmd>split | lua vim.lsp.buf.definition()<CR>', '[Lsp]: Go to definition in vsplit')
    set_map('n', '<space>vv', '<cmd>vsplit | lua vim.lsp.buf.definition()<CR>', '[Lsp]: Go to definition in vsplit')
    set_map('n', 'K', vim.lsp.buf.hover, '[Lsp]: Hover action')
    set_map('n', 'gi', vim.lsp.buf.implementation, '[Lsp]: Go to implementation')
    set_map('n', '<C-k>', vim.lsp.buf.signature_help, '[Lsp]: Show signature help')
    set_map('n', '<space>wa', vim.lsp.buf.add_workspace_folder, '[Lsp]: Add workspace')
    set_map('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, '[Lsp]: Remove workspace')
    set_map('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, '[Lsp]: List workspaces')
    set_map('n', '<space>D', vim.lsp.buf.type_definition, '[Lsp]: Go to type definition')
    set_map('n', '<space>rn', vim.lsp.buf.rename, '[Lsp]: Rename symbol')
    set_map('n', '<f2>', vim.lsp.buf.rename, '[Lsp]: Rename symbol')
    set_map('n', '<space>ca', vim.lsp.buf.code_action, '[Lsp]: Code Actions')
    set_map('n', 'gr', vim.lsp.buf.references, '[Lsp]: Go to references')
    set_map('n', '<space>f', function()
      vim.lsp.buf.format({ async = true })
    end, '[Lsp]: Format buffer')
    set_map('n', '<space>ci', vim.lsp.buf.incoming_calls, '[Lsp]: Incoming Calls')
    set_map('n', '<space>co', vim.lsp.buf.outgoing_calls, '[Lsp]: Outgoing Calls')

    set_map('n', '<space>sw', function ()
      vim.lsp.buf.workspace_symbol('')
    end, '[Lsp] Open workspace symbols')
    set_map('n', '<space>sd', function ()
      vim.lsp.buf.document_symbol({})
    end, '[Lsp] Open document symbols')
    set_map('v', '<space>ca', '<cmd>RangeCodeActions<cr>', '[Lsp] Range code actions')
  end,
}

