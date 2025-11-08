---@module 'lazy'

---@type (string|LazyPluginSpec)[]
return {
  -- {
  --   'lukas-reineke/indent-blankline.nvim',
  --   event = 'VeryLazy',
  --   main = 'ibl',
  --   config = function ()
  --     require('config.nvim_indent-blankline').setup()
  --   end,
  -- },

  {
    'nvim-mini/mini.indentscope',
    event = 'VeryLazy',
    config = function ()
      require('config.nvim_mindent').setup()
    end,
  },

  {
    'saghen/blink.indent',
    event = 'VeryLazy',
    config = function ()
      require('config.nvim_blink_indent').setup()
    end
  },
}
