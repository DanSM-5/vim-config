-- Configure keybindings and colors for neotree
return {
  setup = function ()
    vim.keymap.set(
      'n', '<leader>ve', ':Neotree filesystem toggle reveal_force_cwd position=right<cr>',
      { desc = 'NeoTree: Open current directory in drawer', silent = true }
    )
    vim.keymap.set(
      'n', '<leader>ne', ':Neotree filesystem show toggle reveal_force_cwd position=right<cr>',
      { desc = 'NeoTree: Open current directory in drawer but preserve focus on current buffer', silent = true }
    )
    vim.keymap.set(
      'n', '<leader>vc', ':Neotree filesystem show toggle dir=$user_conf_path position=right<cr>',
      { desc = 'NeoTree: Open user config directory', silent = true }
    )
    vim.keymap.set(
      'n', '<leader>vs', ':Neotree filesystem show toggle dir=$user_scripts_path position=right<cr>',
      { desc = 'NeoTree: Open user scripts directory', silent = true }
    )
    vim.keymap.set(
      'n', '<leader>vv', ':Neotree filesystem show toggle dir=$HOME/vim-config position=right<cr>',
      { desc = 'NeoTree: Open vim config directory', silent = true }
    )
    vim.keymap.set(
      'n', '<leader>vp', ':Neotree filesystem show toggle dir=$HOME/projects position=right<cr>',
      { desc = 'NeoTree: Open projects directory', silent = true }
    )

    -- Use same highlights for NormalNC
    vim.cmd('highlight clear NeoTreeNormalNC')
    vim.cmd('highlight link NeoTreeNormalNC NormalNC')
  end
}

