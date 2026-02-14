return {
  setup = function()
    require('ts_context_commentstring').setup({
      enable_autocmd = false,
    })

    vim.loader.enable(false)
    ---@diagnostic disable-next-line: missing-fields
    require('Comment').setup({
      pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      ignore = '^$',
    })
    vim.loader.enable(true)
  end,
}
