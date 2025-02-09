return {
  setup = function ()
    require('refjump').setup({})

    -- Create extra mapping after change
    vim.api.nvim_create_autocmd('LspAttach', {
      ---@param evt { buf: number, data: { client_id: number } }
      callback = function(evt)
        local client = vim.lsp.get_client_by_id(evt.data.client_id)
        local supports_document_highlight = client and client.supports_method(
          'textDocument/documentHighlight',
          { bufnr = evt.buf }
        )
        if not supports_document_highlight then
          return
        end

        vim.keymap.set({'o', 'x', 'n'}, '<f7>', ']r', { remap = true, desc = 'Next reference', buffer = evt.buf })
        vim.keymap.set({'o', 'x', 'n'}, '<s-f7>', '[r', { remap = true, desc = 'Previous reference', buffer = evt.buf })
      end,
      desc = 'Add keymaps for refjump',
    })
  end
}
