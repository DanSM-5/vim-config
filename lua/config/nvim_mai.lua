return {
  setup = function ()
    require('mini.ai').setup({
      search_method = 'cover',
      n_lines = 999999,
      custom_textobjects = {
        ["'"] = false,
        ['"'] = false,
        ['`'] = false,
      },
    })
  end
}

