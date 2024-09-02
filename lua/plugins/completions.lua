-- completion specific pluggins that do
-- not require lsp-config
return {
  {
    'folke/lazydev.nvim',
    ft = 'lua', -- only load on lua files
    config = function()
      require('config.completions').set_lazydev()
    end
  },
  { 'Bilal2453/luvit-meta', lazy = true }, -- optional `vim.uv` typings
  -- NOTE: Completion for crates in toml file crates
  -- {
  --   'saecki/crates.nvim',
  --   ft = 'toml',
  --   config = function ()
  --     require('config.completions').set_crates()
  --   end
  -- },
}
