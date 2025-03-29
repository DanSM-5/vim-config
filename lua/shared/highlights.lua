local set_diagnostics = function ()
  -- Lsp Diagnostics override
  -- Comment all or uncomment fg prop to restore original
  vim.api.nvim_set_hl(0, 'DiagnosticUnderlineError', {
    cterm = { undercurl = true }, sp = '#e06c75', undercurl = true,
    force = true,
    -- fg = '#e06c75',
  })
  vim.api.nvim_set_hl(0, 'DiagnosticUnderlineWarn', {
    cterm = { undercurl = true }, sp = '#e5c07b', undercurl = true,
    force = true,
    -- fg = '#e5c07b',
  })
  vim.api.nvim_set_hl(0, 'DiagnosticUnderlineOk', {
    cterm = { undercurl = true }, sp = 'NvimLightGreen', undercurl = true,
    force = true,
    -- fg = 'NvimLightGreen',
  })
  vim.api.nvim_set_hl(0, 'DiagnosticUnderlineInfo', {
    cterm = { undercurl = true }, sp = '#61afef', undercurl = true,
    force = true,
    -- fg = '#61afef'
  })
  vim.api.nvim_set_hl(0, 'DiagnosticUnderlineHint', {
    cterm = { undercurl = true }, sp = '#56b6c2', undercurl = true,
    force = true,
    -- fg = '#56b6c2'
  })
end
local create_rainbow_hlg = function ()
  vim.api.nvim_set_hl(0, 'RainbowRed', { fg = '#E06C75' })
  vim.api.nvim_set_hl(0, 'RainbowGrey', { fg = '#3b4048' })
  vim.api.nvim_set_hl(0, 'RainbowYellow', { fg = '#E5C07B' })
  vim.api.nvim_set_hl(0, 'RainbowBlue', { fg = '#61AFEF' })
  vim.api.nvim_set_hl(0, 'RainbowOrange', { fg = '#D19A66' })
  vim.api.nvim_set_hl(0, 'RainbowGreen', { fg = '#98C379' })
  vim.api.nvim_set_hl(0, 'RainbowViolet', { fg = '#C678DD' })
  vim.api.nvim_set_hl(0, 'RainbowCyan', { fg = '#56B6C2' })
end

return {
  set_diagnostics = set_diagnostics,
  create_rainbow_hlg = create_rainbow_hlg,
  setup = function ()
    set_diagnostics()
    create_rainbow_hlg()
  end
}
