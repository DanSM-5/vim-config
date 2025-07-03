---@module 'lazy'

---@type LazyPluginSpec
return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    extensions = {
      'aerial',
      'fugitive',
      'fzf',
      'lazy',
      'mason',
      'neo-tree',
      'oil',
      'quickfix',
    },
    options = {
      theme = 'onedark',
    },
  },
}
