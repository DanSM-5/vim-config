local language_servers = {
  'lua_ls',
  'vimls',
  'biome',
  'bashls',
  -- 'tsserver'
}

-- Load meson
require('mason').setup({})

-- Load mason-lspconfig
require('mason-lspconfig').setup({
  -- Prevent nvim load before lsp is ready
  ensure_installed = language_servers,
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({})
    end
  }
})

-- https://github.com/DanSM-5/vim-config
-- Setup the lsp config
-- See: `:help lspconfig-setup`
-- local lspconfig = require('lspconfig')
-- lspconfig.lua_ls.setup({})

-- vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})

-- Global mappings
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
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
    set_map('n', 'gd', vim.lsp.buf.declaration, 'LSP: Go to declaration')
    set_map('n', 'gD', vim.lsp.buf.definition, 'LSP: Go to definition')
    set_map('n', 'gV', '<cmd>vsplit | lua vim.lsp.buf.definition()<CR>', 'LSP: Go to definition in vsplit')
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
    set_map({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, 'LSP: Code Actions')
    set_map('n', 'gr', vim.lsp.buf.references, 'LSP: Go to references')
    set_map('n', '<space>f', function()
      vim.lsp.buf.format({ async = true })
    end, 'LSP: Format buffer')
    set_map('n', '<space>Ic', vim.lsp.buf.incoming_calls, 'LSP: Incoming Calls')
    set_map('n', '<space>Oc', vim.lsp.buf.outgoing_calls, 'LSP: Outgoing Calls')

    -- Below seem to be the default
    set_map('n', '[d', vim.diagnostic.goto_prev, 'LSP: Go to previous diagnostic message')
    set_map('n', ']d', vim.diagnostic.goto_next, 'LSP: Go to next diagnostic message')
  end
})

-- Buffer information
-- See `:help vim.lsp.buf`
