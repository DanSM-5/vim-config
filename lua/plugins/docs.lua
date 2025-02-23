-- Plugins that improve documentation

return {
  {
    'maskudo/devdocs.nvim',
    -- dir = vim.fn.expand('~/projects/devdocs.nvim'),
    dev = false,
    cmd = {
      'DevDocs',
      'DevDocsOpen',
      'DevDocsRemove',
    },
    config = function ()
      require('config.nvim_devdocs').setup()
    end,
  },
}

