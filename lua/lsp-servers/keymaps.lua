---@module 'shared.types'
---@module 'utils.repeat_motion'
---@module 'utils.refjump'

local exclude_filetypes = {
  'help',
}

local exists = vim.fn.exists

---Get the function for on_forward and on_backward
---@param forward boolean
local ref_jump = function (forward)
  ---References cache
  ---@type RefjumpReference[]?
  local references

  -- NOTE: It is important to make only this part repeatable and not the whole keymap
  -- so that references will be a brand new reference variable but
  -- it will have the cached references if repeating the motion
  require('utils.repeat_motion').repeat_direction({
    fn = function (opts)
      require('utils.refjump').reference_jump(opts, references, function (refs)
        references = refs
      end)
    end,
  })({ forward = forward })
end

---Mapper from commands to lsp handler functions
---@type [string, string][]
local cmd_to_lsp_handlers = {
  { 'Definitions', 'definition' },
  { 'Declarations', 'declaration' },
  { 'TypeDefinitions', 'type_definition' },
  { 'Implementations', 'implementation' },
  { 'References', 'references' },
  { 'DocumentSymbols', 'document_symbol' },
  { 'WorkspaceSymbols', 'workspace_symbol' },
  { 'IncomingCalls', 'incoming_calls' },
  { 'OutgoingCalls', 'outgoing_calls' },
  { 'CodeActions', 'code_action' },
}

vim.lsp.buf.code_action()

---@class config.LspHandlers
---
--- Jumps to the definition of the symbol under the cursor.
---@field definition fun(opts?: vim.lsp.LocationOpts)
---
--- Jumps to the declaration of the symbol under the cursor.
--- @note Many servers do not implement this method. Generally, see |vim.lsp.buf.definition()| instead.
---@field declaration fun(opts?: vim.lsp.LocationOpts)
---
--- Jumps to the definition of the type of the symbol under the cursor.
---@field type_definition fun(opts?: vim.lsp.LocationOpts)
---
--- Lists all the implementations for the symbol under the cursor in the
--- quickfix window.
---@field implementation fun(opts?: vim.lsp.LocationOpts)
---
--- Lists all the references to the symbol under the cursor in the quickfix window.
---
--- See:
---   * [Documentation](https://microsoft.github.io/language-server-protocol/specifications/specification-current/#textDocument_references)
---@field references fun(context?: lsp.ReferenceContext, opts?: vim.lsp.ListOpts)
---
--- Lists all symbols in the current buffer in the |location-list|.
---@field document_symbol fun(opts?: vim.lsp.ListOpts)
---
--- Lists all symbols in the current workspace in the quickfix window.
---
--- The list is filtered against {query}; if the argument is omitted from the
--- call, the user is prompted to enter a string on the command line. An empty
--- string means no filtering is done.
---@field workspace_symbol fun(query: string?, opts?: vim.lsp.ListOpts)
---
--- Lists all the call sites of the symbol under the cursor in the
-- |quickfix| window. If the symbol can resolve to multiple
--- items, the user can pick one in the |inputlist()|.
---@field incoming_calls fun()
---
--- Lists all the items that are called by the symbol under the
--- cursor in the |quickfix| window. If the symbol can resolve to
--- multiple items, the user can pick one in the |inputlist()|.
---@field outgoing_calls fun()
---
--- Selects a code action available at the current
--- cursor position.
---
--- See:
---   * [Documentation](https://microsoft.github.io/language-server-protocol/specifications/specification-current/#textDocument_codeAction)
---   * [vim.lsp.protocol.CodeActionTriggerKind](lua://vim.lsp.protocol.CodeActionTriggerKind)
---@field code_action fun(opts?: vim.lsp.buf.code_action.Opts)

---@type config.LspHandlers
local handlers = ({}) --[[@as config.LspHandlers]]

local set_handlers = function ()
  for _, handler in ipairs(cmd_to_lsp_handlers) do
    local cmd, name = handler[1], handler[2]
    handlers[name] = function (...)
      if exists(':'..cmd) then
        vim.cmd[cmd]()
        return
      end

      return vim.lsp.buf[name](...)
    end
  end
end

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

    if #vim.tbl_keys(handlers) == 0 then
      set_handlers()
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

    set_map('n', '<space>td', function()
      vim.diagnostic.enable(not vim.diagnostic.is_enabled())
    end, '[Lsp]: Toggle diagnostics')
    set_map('n', '<space>ti', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ nil }))
    end, '[Lsp]: Toggle inlay hints')
    set_map('n', '<space>tt', function()
      local config = type(vim.diagnostic.config().virtual_text) == 'boolean' and { current_line = true } or true
      vim.diagnostic.config({ virtual_text = config })
    end, '[Lsp]: Toggle inlay hints')
    set_map('n', '<space>tl', function()
      local config = type(vim.diagnostic.config().virtual_lines) == 'boolean' and { current_line = true } or false
      vim.diagnostic.config({ virtual_lines = config })
    end, '[Lsp]: Toggle inlay hints')
    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    set_map('n', 'gD', handlers.declaration, '[Lsp]: Go to declaration')
    set_map('n', 'gd', handlers.definition, '[Lsp]: Go to definition')
    set_map('n', '<space>vs', function ()
      vim.cmd.split()
      handlers.definition()
    end, '[Lsp]: Go to definition in vsplit')
    set_map('n', '<space>vv', function ()
      vim.cmd.vsplit()
      handlers.definition()
    end, '[Lsp]: Go to definition in vsplit')
    set_map('n', 'K', function () vim.lsp.buf.hover({ border = 'rounded' }) end, '[Lsp]: Hover action')
    set_map('n', '<space>i', handlers.implementation, '[Lsp]: Go to implementation')
    set_map('n', '<C-k>', function ()
       vim.lsp.buf.signature_help({ border = 'rounded' })
    end, '[Lsp]: Show signature help')
    set_map('n', '<space>wa', vim.lsp.buf.add_workspace_folder, '[Lsp]: Add workspace')
    set_map('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, '[Lsp]: Remove workspace')
    set_map('n', '<space>wl', function()
      vim.print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, '[Lsp]: List workspaces')
    set_map('n', '<space>D', handlers.type_definition, '[Lsp]: Go to type definition')
    set_map('n', '<space>rn', vim.lsp.buf.rename, '[Lsp]: Rename symbol')
    set_map('n', '<f2>', vim.lsp.buf.rename, '[Lsp]: Rename symbol')
    set_map('n', '<space>ca', handlers.code_action, '[Lsp]: Code Actions')
    set_map('n', 'gr', handlers.references, '[Lsp]: Go to references')
    set_map('n', '<space>f', function()
      vim.lsp.buf.format({ async = false })
      vim.cmd.retab()
      vim.cmd.write()
    end, '[Lsp]: Format buffer')
    set_map('n', '<space>ci', handlers.incoming_calls, '[Lsp]: Incoming Calls')
    set_map('n', '<space>co', handlers.outgoing_calls, '[Lsp]: Outgoing Calls')

    set_map('n', '<space>sw', function ()
      handlers.workspace_symbol('')
    end, '[Lsp] Open workspace symbols')
    set_map('n', '<space>sd', function ()
      handlers.document_symbol({})
    end, '[Lsp] Open document symbols')
    set_map('v', '<space>ca', '<cmd>RangeCodeActions<cr>', '[Lsp] Range code actions')


    local nxo = { 'n', 'x', 'o' }
    if client:supports_method('textDocument/documentHighlight', buf) then
      set_map(nxo, ']r', function() ref_jump(true) end, '[Reference] Next reference')
      set_map(nxo, '[r', function() ref_jump(false) end, '[Reference] Next reference')
    end
  end,
}
