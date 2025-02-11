local function repeatable_jump_map(opts)
  local repeatably_do = require('demicolon.jump').repeatably_do
  return function()
    local references
    repeatably_do(function(o)
      require('refjump').reference_jump(o, references, function(refs)
        references = refs
      end)
    end, opts)
  end
end

---@param evt { buf: number, data?: { client_id?: number } }
local function set_keymaps(evt)
  ---@type vim.lsp.Client[]
  local clients

  -- if we get id, use it
  if evt.data and evt.data.client_id then
    clients = vim.lsp.get_clients({
      id = evt.data.client_id,
      method = 'textDocument/documentHighlight',
    })
  else
    -- if not, fallback to buffer
    clients = vim.lsp.get_clients({
      bufnr = evt.buf,
      method = 'textDocument/documentHighlight',
    })
  end

  local supports_document_highlight = #clients > 0
  if not supports_document_highlight then
    return
  end

  local nxo = { 'n', 'x', 'o' }
  local jump = repeatable_jump_map

  vim.keymap.set(nxo, ']r', jump({ forward = true }), {
    desc = 'Next reference',
    buffer = evt.buf,
  })

  vim.keymap.set(nxo, '[r', jump({ forward = false }), {
    desc = 'Previous reference',
    buffer = evt.buf,
  })

  vim.keymap.set(nxo, '<f7>', jump({ forward = true }), {
    desc = 'Next reference',
    buffer = evt.buf,
  })

  vim.keymap.set(nxo, '<s-f7>', jump({ forward = false }), {
    desc = 'Previous reference',
    buffer = evt.buf,
  })
end

return {
  setup = function ()
    require('refjump').setup({
      keymaps = {
        enable = false,
      },
    })

    -- Create extra mapping after change
    vim.api.nvim_create_autocmd('LspAttach', {
      callback = set_keymaps,
      desc = 'Add keymaps for refjump',
    })
  end,
  set_keymaps = set_keymaps,
}

