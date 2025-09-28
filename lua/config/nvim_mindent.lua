local mindent_config = {
  -- Draw options
  draw = {
    -- Delay (in ms) between event and start of drawing scope indicator
    delay = 100,

    -- Animation rule for scope's first drawing. A function which, given
    -- next and total step numbers, returns wait time (in ms). See
    -- |MiniIndentscope.gen_animation| for builtin options. To disable
    -- animation, use `require('mini.indentscope').gen_animation.none()`.
    -- animation = --<function: implements constant 20ms between steps>,

    -- Whether to auto draw scope: return `true` to draw, `false` otherwise.
    -- Default draws only fully computed scope (see `options.n_lines`).
    -- predicate = function(scope) return not scope.body.is_incomplete end,
    -- predicate = function () return true end,

    -- animation = mini_indent.gen_animation.none(),
    -- Symbol priority. Increase to display on top of more symbols.
    priority = 2,
  },

  -- Module mappings. Use `''` (empty string) to disable one.
  mappings = {
    -- Textobjects
    object_scope = 'ii',
    object_scope_with_border = 'ai',


    -- Motions (jump to respective border line; if not present - body line)
    -- goto_top = '[i',
    -- goto_bottom = ']i',

    goto_top = '',
    goto_bottom = '',
  },

  -- Options which control scope computation
  options = {
    -- Type of scope's border: which line(s) with smaller indent to
    -- categorize as border. Can be one of: 'both', 'top', 'bottom', 'none'.
    border = 'both',

    -- Whether to use cursor column when computing reference indent.
    -- Useful to see incremental scopes with horizontal cursor movements.
    indent_at_cursor = true,

    -- Maximum number of lines above or below within which scope is computed
    n_lines = 100000,

    -- Whether to first check input line to be a border of adjacent scope.
    -- Use it if you want to place cursor on function header to get scope of
    -- its body.
    try_as_border = true,
  },

  -- Which character to use for drawing scope indicator
  -- symbol = '▎',
  symbol = '▏',
}

local set_commands = function ()
  vim.api.nvim_create_user_command('IndentWithBoder', function (opts)
    ---@type string|boolean|nil
    local option = opts.fargs[1]
    -- local mini_indent = require('mini.indentscope')

    if option == nil then
      option = not MiniIndentscope.config.options.try_as_border
    else
      option = option == 'on'
    end

    -- mindent_config.options.try_as_border = option
    -- mini_indent.setup(mindent_config)
    MiniIndentscope.config.options.try_as_border = option
  end, {
    nargs = '?',
    bang = true,
    bar = true,
    complete = function () return { 'on', 'off' }  end,
    desc = '[Indent] Change the scope of the indent to include borders or not'
  })
end

return {
  setup = function ()
    vim.api.nvim_set_hl(0, 'MiniIndentscopeSymbol',    { force = true, link = 'RainbowCyan' })
    vim.api.nvim_set_hl(0, 'MiniIndentscopeSymbolOff', { force = true, link = 'RainbowViolet' })

    local mini_indent = require('mini.indentscope')
    mindent_config.draw.animation = mini_indent.gen_animation.none()
    mini_indent.setup(mindent_config)
    set_commands()
  end,
  set_commands = set_commands,
}
