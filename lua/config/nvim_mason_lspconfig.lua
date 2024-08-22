-- Mason-lspconfig options
return {
  ---@param settings { ensure_installed: string[], lsp_config: nil | {} }
  get_config = function(settings)
    settings = settings or { ensure_installed = {} }
    return {
      ensure_installed = settings.ensure_installed,
      handlers = {
        function(server_name)
          local base_config = require('lsp-servers.config').get_config()[server_name] or {}
          local config = settings.lsp_config
              and vim.tbl_deep_extend('force', {}, base_config, settings.lsp_config)
              or base_config
          require('lspconfig')[server_name].setup(config)
        end
      }
    }
  end
}
