-- Manual lsp-config
-- This runs when loading lsp from VimPlug

-- https://github.com/DanSM-5/vim-config
-- Setup the lsp config
-- See: `:help lspconfig-setup`
-- local lspconfig = require('lspconfig')
-- lspconfig.lua_ls.setup({})

return {
  setup = function()
    local language_servers = {
      'lua_ls',
      'vimls',
      'biome',
      'bashls',
      -- 'tsserver'
    }
    local manual_setup = vim.g.is_termux == 1 or vim.env.IS_FROM_CONTAINER == 'true'
    local mason_opts = require('config.nvim_mason').get_config()
    local mason_lspconfig_opts = require('config.nvim_mason_lspconfig').get_config({
      ensure_installed = language_servers
    })

    -- Load meson
    require('mason').setup(mason_opts)

    -- Load mason-lspconfig
    require('mason-lspconfig').setup(mason_lspconfig_opts)

    -- Add fzf menus for LSP functions
    -- This replace native lsp handlers so fzf handler
    -- functions are called async
    require('fzf_lsp').setup()

    -- Setup lsp servers
    require('config.nvim_lspconfig').setup({ manual_setup = manual_setup })

    -- Buffer information
    -- See `:help vim.lsp.buf`
  end
}
