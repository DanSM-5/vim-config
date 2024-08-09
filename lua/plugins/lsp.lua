local language_servers = {
  'lua_ls',
  'vimls',
  'biome',
  'bashls',
  -- 'tsserver'
}

-- change language servers for termux
if (vim.g.is_termux == 1) then
  language_servers = {}
end

return {
  {
    'williamboman/mason.nvim',
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
        }
      }
    }
  },
  {
    'williamboman/mason-lspconfig.nvim',
    opts = {
      -- Prevent nvim load before lsp is ready
      ensure_installed = language_servers,
      handlers = {
        function(server_name)
          local config = require('lsp-servers.config').get_config()[server_name] or {}
          require('lspconfig')[server_name].setup(config)
        end
      }
    }
  },
  {
    'neovim/nvim-lspconfig',
    config = function()
      require('lsp-servers.keymaps').setup()
      if (vim.g.is_termux == 1) then
        require('lsp-servers.termux').setup()
      elseif vim.env.IS_FROM_CONTAINER == 'true' then
        -- NOTE:
        -- installing lua server from mason fails in container due to nix
        -- being based on musl rather than gnu, though the server can be
        -- manually installed and hooked like this
        if vim.fn.executable('lua-language-server') == 1 then
          require('lspconfig').lua_ls.setup({})
        end
      end
      require('lsp-servers.termux').setup()
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

