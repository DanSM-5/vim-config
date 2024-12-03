return {
  setup = function ()
    require('ts_context_commentstring').setup({
      enable_autocmd = false,
    })

    if vim.loader.disable ~= nil then
      vim.loader.disable()
    else
      vim.loader.enable(false)
    end
    require('Comment').setup({
      pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      ignore = '^$',
    })
    vim.loader.enable(true)
  end
}
