
vim.api.nvim_create_user_command('InspectLspClient', function (opts)
  require('utils.inspect_lsp_client').inspect_lsp_client(opts)
end, { nargs = '?', bang = true })

