-- This checks for the existance of a file lua/lsp-servers/servers.lua
-- Which should return an array of tables with lsp name and server command name.

return {
  ---@param config { lspconfig_handler: fun(server: string) }
  configure = function (config)
    ---@type boolean
    local success,
    ---@type { server: string; lsp: string }[]
    servers = pcall(require, 'lsp-servers.servers')

    if not success or type(servers) ~= 'table' then
      return
    end

    for _, settings in ipairs(servers) do
      local server, lsp = settings.server, settings.lsp
      if type(server) ~= 'string' or type(lsp) ~= 'string' then
        -- continue;
        -- but lua doesn't have continue :v
      elseif vim.fn.executable(server) == 1 then
        config.lspconfig_handler(lsp)
      end
    end
  end
}

