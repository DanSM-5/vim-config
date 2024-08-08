return {
  'sonph/onehalf', -- { 'rtp': 'vim' },
  lazy = false,
  name = 'onehalfdark',
  priority = 1000,
  config = function (plugin)
    vim.opt.rtp:append(plugin.dir .. '/vim')
    vim.cmd.colorscheme('onehalfdark')
    vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1
  end
}
