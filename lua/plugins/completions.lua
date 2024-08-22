-- completion specific pluggins that do
-- not require lsp-config
return {
  {
    'folke/lazydev.nvim',
    ft = 'lua', -- only load on lua files
    config = function()
      local lazydev_config = require('config.completions').get_lazydev_config()
      local lazydev = require('lazydev')

      lazydev.setup(lazydev_config)
    end
  },
  { 'Bilal2453/luvit-meta', lazy = true }, -- optional `vim.uv` typings
}
