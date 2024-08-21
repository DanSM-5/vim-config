-- Mason-lspconfig options
return {
  get_config = function(settings)
    settings = settings or { ensure_installed = {} }
    return {
      ensure_installed = settings.ensure_installed,
      handlers = {
        function(server_name)
          local config = require('lsp-servers.config').get_config()[server_name] or {}
          require('lspconfig')[server_name].setup(config)
        end
      }
    }
  end
}

