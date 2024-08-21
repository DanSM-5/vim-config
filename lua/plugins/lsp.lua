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
local mason_lspconfig_opts = require('config.nvim_mason_lspconfig').get_config({
  ensure_installed = language_servers
})

return {
  {
    'williamboman/mason.nvim',
    opts = mason_opts,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    opts = mason_lspconfig_opts,
  },
  {
    'neovim/nvim-lspconfig',
    config = function()
      require('config.nvim_lspconfig').setup({ manual_setup = manual_setup })
    end
  },
  {
    'DanSM-5/fzf-lsp.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim'
    },
    opts = {}
  }
}
