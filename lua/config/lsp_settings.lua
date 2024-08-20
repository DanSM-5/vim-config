-- Manual lsp-config

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

    if (vim.g.is_termux == 1) then
      language_servers = {}
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
          local config = require('lsp-servers.config').get_config()[server_name] or {}
          require('lspconfig')[server_name].setup(config)
        end
      }
    })

    -- Add fzf menus for LSP functions
    -- This replace native lsp handlers so fzf handler
    -- functions are called async
    require('fzf_lsp').setup()

    -- Set defualt lsp keybindings
    require('lsp-servers.keymaps').setup()

    -- Buffer information
    -- See `:help vim.lsp.buf`
  end
}
