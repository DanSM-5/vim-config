return {
  setup = function ()
    local ai = require('mini.ai')
    ai.setup({
      search_method = 'cover',
      n_lines = 999999,
      custom_textobjects = {
        ["'"] = false,
        ['"'] = false,
        ['`'] = false,
        -- Set function call to F
        ['f'] = false,
        ['F'] = ai.gen_spec.function_call(),
      },
    })
  end
}

