
return {
  setup = function ()
    local difftool = require('fugitive-difftool')
    -- Jump to the first quickfix entry
    vim.api.nvim_create_user_command('Gcfr', difftool.git_cfir, { desc = '[Difftool] Go to the first item in quickfix' })
    -- To the last
    vim.api.nvim_create_user_command('Gcla', difftool.git_cla, { desc = '[Difftool] Go to last item in quickfix' })
    -- To the next
    vim.api.nvim_create_user_command('Gcn', difftool.git_cn, { desc = '[Difftool] Go to next item in quickfix' })
    -- To the previous
    vim.api.nvim_create_user_command('Gcp', difftool.git_cp, { desc = '[Difftool] Go to previous item in quickfix' })
    -- To the currently selected
    vim.api.nvim_create_user_command('Gcc', difftool.git_cc, { desc = '[Difftool] Go to current item in quickfix' })
  end
}

