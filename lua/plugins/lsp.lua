local language_servers = {
  'lua_ls',
  'vimls',
  'biome',
  'bashls',
  -- 'tsserver'
}

local manual_setup = vim.g.is_termux == 1 or vim.env.IS_FROM_CONTAINER == 'true'

-- change language servers for termux
if (manual_setup) then
  language_servers = {}
end

local mason_opts = require('config.nvim_mason').get_config()

return {
  {
    'williamboman/mason.nvim',
    opts = mason_opts,
  },
  -- {
  --   'williamboman/mason-lspconfig.nvim',
  --   opts = mason_lspconfig_opts,
  -- },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-nvim-lsp',
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      require('config.nvim_lspconfig').setup({ manual_setup = manual_setup })
      local sources = {
        {
          name = "lazydev",
          group_index = 0, -- set group index to 0 to skip loading LuaLS completions
        },
        { name = 'nvim_lsp' }
      }
      local cmp = require('cmp')
      local cmp_lsp = require('cmp_nvim_lsp')
      local mason_lsp = require('mason-lspconfig')
      local capabilities = vim.tbl_deep_extend(
          'force',
          {},
          vim.lsp.protocol.make_client_capabilities(),
          cmp_lsp.default_capabilities())

      local mason_lspconfig_opts = require('config.nvim_mason_lspconfig').get_config({
        ensure_installed = language_servers,
        lsp_config = { capabilities = capabilities }
      })

      local cmp_select = { behavior = cmp.SelectBehavior.Replace }
      cmp.setup({
        sources = sources,
        mapping = cmp.mapping.preset.insert({
            ['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item(cmp_select), {'i'}),
            ['<C-n>'] = cmp.mapping(cmp.mapping.select_next_item(cmp_select), {'i'}),
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-e>'] = cmp.mapping.abort(),
        }),
      })

      mason_lsp.setup(mason_lspconfig_opts)
    end
  },
  {
    'DanSM-5/fzf-lsp.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim'
    },
    opts = {
      override_ui_select = true
    }
  }
}

-- NOTE: if needed, fzf-lsp can set the following bindings
-- for manual configuration of the lsp handlers
-- vim.lsp.handlers["textDocument/codeAction"] = require'fzf_lsp'.code_action_handler
-- vim.lsp.handlers["textDocument/definition"] = require'fzf_lsp'.definition_handler
-- vim.lsp.handlers["textDocument/declaration"] = require'fzf_lsp'.declaration_handler
-- vim.lsp.handlers["textDocument/typeDefinition"] = require'fzf_lsp'.type_definition_handler
-- vim.lsp.handlers["textDocument/implementation"] = require'fzf_lsp'.implementation_handler
-- vim.lsp.handlers["textDocument/references"] = require'fzf_lsp'.references_handler
-- vim.lsp.handlers["textDocument/documentSymbol"] = require'fzf_lsp'.document_symbol_handler
-- vim.lsp.handlers["workspace/symbol"] = require'fzf_lsp'.workspace_symbol_handler
-- vim.lsp.handlers["callHierarchy/incomingCalls"] = require'fzf_lsp'.incoming_calls_handler
-- vim.lsp.handlers["callHierarchy/outgoingCalls"] = require'fzf_lsp'.outgoing_calls_handler
