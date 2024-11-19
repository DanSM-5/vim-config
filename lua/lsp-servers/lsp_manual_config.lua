-- NOTE: Platforms like termux cannot load lsp from Mason
-- or it will it will try to install incompatible
-- binaries and lsp will fail.
-- Setting manually here the list of servers that we may want to configure.

---@type { server: string; lsp: string }[]
local servers = {
  {
    server = 'lua-language-server',
    lsp = 'lua_ls',
  },
  {
    server = 'bash-language-server',
    lsp = 'bashls',
  },
  {
    server = 'vim-language-server',
    lsp = 'vimls',
  },
  {
    server = 'typescript-language-server',
    lsp = 'ts_ls',
  },
  {
    server = 'emmet-language-server ',
    lsp = 'emmet_language_server '
  },
  {
    server = 'biome',
    lsp = 'biome',
  },
}

return {
  ---@param config { lspconfig_handler: fun(server: string) }
  setup = function(config)
    for _, settings in ipairs(servers) do
      local server, lsp = settings.server, settings.lsp
      if vim.fn.executable(server) == 1 then
        config.lspconfig_handler(lsp)
      end
    end


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
  end   -- setup end
}
