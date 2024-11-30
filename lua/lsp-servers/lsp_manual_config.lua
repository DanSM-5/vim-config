require('lsp-servers.types')

--Manual lsp configuration example
--
--if vim.fn.executable('bash-language-server') == 1 then
--  local bashls_opts = servers_config.bashls

--  vim.api.nvim_create_autocmd('BufEnter', {
--    callback = function()
--      vim.lsp.start({
--        cmd = { 'bash-language-server', 'start' },
--        settings = {
--          bashIde = {
--            -- Glob pattern for finding and parsing shell script files in the workspace.
--            -- Used by the background analysis features across files.

--            -- Prevent recursive scanning which will cause issues when opening a file
--            -- directly in the home directory (e.g. ~/foo.sh).
--            --
--            -- Default upstream pattern is "**/*@(.sh|.inc|.bash|.command)".
--            globPattern = vim.env.GLOB_PATTERN or bashls_opts.settings.bashIde.globPattern,
--          },
--        },
--        filetypes = { 'sh' },
--        root_dir = util.find_git_ancestor,
--        single_file_support = true,
--      })
--    end
--  })
--end -- if bash-language-server == 1 end

---@param config { lspconfig_handler: LspHandlerFunc; servers: LspServersSettings[] }
---@return nil
local setup_servers = function (config)
  for _, settings in ipairs(config.servers) do
    local server, lsp, options = settings.server, settings.lsp, settings.options
    if type(server) ~= 'string' or type(lsp) ~= 'string' then
      -- continue;
      -- but lua doesn't have continue :v
    elseif vim.fn.executable(server) == 1 then
      config.lspconfig_handler(lsp, options)
    end
  end
end

---@param config { lspconfig_handler: LspHandlerFunc; } Handler function that setups an lsp
---@param module_name string Name of the module to load with sources
---@return nil
local configure = function (config, module_name)
  ---@type boolean
  local success,
  ---@type { server: string; lsp: string }[]
  servers = pcall(require, module_name)

  if not success or type(servers) ~= 'table' then
    return
  end

  setup_servers({
    lspconfig_handler = config.lspconfig_handler,
    servers = servers,
  })
end

return {
  configure = configure,
  setup_servers = setup_servers,
  ---@type LspSpecialSetupFunc
  set_special_binaries = function(config)
    configure(config, 'lsp-sources.special_binaries')
  end,
  ---@type LspSpecialSetupFunc
  set_manual_setup = function (config)
    configure(config, 'lsp-sources.manual_setup')
  end,
  ---@type LspSpecialSetupFunc
  set_device_specific = function (config)
    configure(config, 'lsp-sources.device_specific')
  end,
}

