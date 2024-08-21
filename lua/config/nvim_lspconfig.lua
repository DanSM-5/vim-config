return {
  setup = function(settings)
    settings = settings or {}
    require('lsp-servers.keymaps').setup()
    if (settings.manual_setup) then
      -- NOTE:
      -- installing lua server from mason fails in systems
      -- based on musl rather than gnu, though the server can be
      -- manually installed and hooked like this
      require('lsp-servers.lsp_manual_config').setup()
    end
  end
}
