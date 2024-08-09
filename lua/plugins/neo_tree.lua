return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = "v3.x",
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
    -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
  },
  config = function ()
    vim.keymap.set('n', '<leader>ve', ':Neotree filesystem toggle reveal_force_cwd position=right<cr>')
    vim.keymap.set('n', '<leader>vE', ':Neotree filesystem show toggle reveal_force_cwd position=right<cr>')
    vim.keymap.set('n', '<leader>vc', ':Neotree filesystem show toggle dir=$user_conf_path position=right<cr>')
    vim.keymap.set('n', '<leader>vs', ':Neotree filesystem show toggle dir=$user_scripts_path position=right<cr>')
    vim.keymap.set('n', '<leader>vv', ':Neotree filesystem show toggle dir=$HOME/vim-config position=right<cr>')
    vim.keymap.set('n', '<leader>vp', ':Neotree filesystem show toggle dir=$HOME/projects position=right<cr>')
  end
}
