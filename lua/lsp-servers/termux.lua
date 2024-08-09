-- NOTE: Termux cannot load lsp from Mason
-- or it will it will try to install incompatible
-- binaries and lsp will fail.

return {
  setup = function()
    -- local util = require('lspconfig.util')
    local servers_config = require('lsp-servers.config').get_config()
    local lspconfig = require('lspconfig')

    -- Require manual call and not being configured by mason
    if vim.fn.executable('lua-language-server') == 1 then
      lspconfig.lua_ls.setup(servers_config.lua_ls)
    end

    if vim.fn.executable('bash-language-server') == 1 then
      lspconfig.bashls.setup(servers_config.bashls)
    end

    if vim.fn.executable('vim-language-server') == 1 then
      lspconfig.vimls.setup(servers_config.vimls)
    end

    if vim.fn.executable('biome') == 1 then
      lspconfig.vimls.setup(servers_config.biome)
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
