
return {
  set_diagnostics = function ()
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
}

