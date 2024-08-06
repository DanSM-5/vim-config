local language_servers = {
  'lua_ls',
  'vimls',
  'biome',
  'bashls',
  -- 'tsserver'
}

-- Load meson
require('mason').setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})

-- Load mason-lspconfig
require('mason-lspconfig').setup({
  -- Prevent nvim load before lsp is ready
  ensure_installed = language_servers,
  handlers = {
    function(server_name)
      local config = {}

      if (server_name == 'bashls') then
        config.settings = {
          bashIde = {
            globPattern = '*@(.sh|.inc|.bash|.command|.zsh|.uconfrc|.uconfgrc|.ualiasrc|.ualiasgrc)'
          }
        }
      end

      require('lspconfig')[server_name].setup(config)
    end
  }
})

-- Add fzf menus for LSP functions
-- This replace native lsp handlers so fzf handler
-- functions are called async
require('fzf_lsp').setup()

-- Set defualt lsp keybindings
require('.lsp-servers.keymaps').setup()

-- Buffer information
-- See `:help vim.lsp.buf`
