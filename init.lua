-- enable cache loader
vim.loader.enable()

require('nvimstart')
require('config.lazy')
-- Ignored device specific config
pcall(require, 'local')

