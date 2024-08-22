
return {
  setup = function ()
    local mason_opts = require('config.nvim_mason').get_config()
    local mason = require('mason')
    mason.setup(mason_opts)
  end
}
