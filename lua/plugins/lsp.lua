-- local language_servers = {
--   'lua_ls',
--   'vimls',
--   'biome',
--   'bashls',
--   -- 'tsserver'
-- }
--
-- local manual_setup = vim.g.is_termux == 1 or vim.env.IS_FROM_CONTAINER == 'true'
--
-- -- change language servers for termux
-- if (manual_setup) then
--   language_servers = {}
-- end

return {
  {
    'williamboman/mason.nvim',
    config = function ()
      require('lsp-servers.nvim_mason').setup()
    end
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-nvim-lsp',
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      require('lsp-servers.lsp_settings').setup({ enable_lazydev = true })
    end
  },
  {
    'DanSM-5/fzf-lsp.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim'
    },
    config = function ()
      require('lsp-servers.nvim_fzf_lsp').setup()
    end
  }
}
