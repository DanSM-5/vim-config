-- Tree sitter configs

local function set_keymaps()
  local nxo = { 'n', 'x', 'o' }
  local repeat_motion = require('utils.repeat_motion')
  local repeat_pair = repeat_motion.repeat_pair
  local create_repeatable_pair = repeat_motion.create_repeatable_pair
  -- NOTE: Setting repeatable keymaps ',' (left) and ';' (right)
  repeat_motion.set_motion_keys()

  --- Execute a command and print errors without a stacktrace.
  --- @param opts table Arguments to |nvim_cmd()|
  local function cmd(opts)
    local ok, err = pcall(vim.api.nvim_cmd, opts, {})
    if not ok then
      vim.api.nvim_echo({ { err:sub(#'Vim:' + 1) } }, true, { err = true })
    end
  end

  -- Quickfix mappings

  -- Move items in quickfix next/prev
  local quickfix_next = function()
    cmd({ cmd = 'cnext', count = vim.v.count1 })
  end
  local quickfix_prev =  function()
    cmd({ cmd = 'cprevious', count = vim.v.count1 })
  end
  repeat_pair({
    keys = 'q',
    desc_forward = '[Quickfix] Move to next item',
    desc_backward = '[Quickfix] Move to previous item',
    on_forward = quickfix_next,
    on_backward = quickfix_prev,
  })

  -- Move items in quickfix first/last
  -- local quickfix_last = function()
  --   cmd({ cmd = 'clast', count = vim.v.count ~= 0 and vim.v.count or nil })
  -- end
  -- local quickfix_first =  function()
  --   cmd({ cmd = 'cfirst', count = vim.v.count ~= 0 and vim.v.count or nil })
  -- end
  -- repeat_pair({
  --   keys = 'Q',
  --   desc_forward = '[Quickfix] Move to last item',
  --   desc_backward = '[Quickfix] Move to first item',
  --   on_forward = quickfix_last,
  --   on_backward = quickfix_first,
  -- })

  -- Do not repeat?
  vim.keymap.set('n', ']Q', function()
    cmd({ cmd = 'clast', count = vim.v.count ~= 0 and vim.v.count or nil })
  end, { desc = '[Quickfix] Move to last item', noremap = true })
  vim.keymap.set('n', '[Q', function()
    cmd({ cmd = 'cfirst', count = vim.v.count ~= 0 and vim.v.count or nil })
  end, { desc = '[Quickfix] Move to first item', noremap = true })

  -- Move to next/prev item in file
  local quickfix_next_file =  function()
    cmd({ cmd = 'cnfile', count = vim.v.count1 })
  end
  local quickfix_prev_file = function()
    cmd({ cmd = 'cpfile', count = vim.v.count1 })
  end
  repeat_pair({
    keys = '<C-q>',
    desc_forward = '[Quickfix] Move to next file item',
    desc_backward = '[Quickfix] Move to previous file item',
    on_forward = quickfix_next_file,
    on_backward = quickfix_prev_file,
  })


  -- Location list mappings

  -- Move items in loclist next/prev
  local locationlist_next = function()
    cmd({ cmd = 'lnext', count = vim.v.count1 })
  end
  local locationlist_prev = function()
    cmd({ cmd = 'lprevious', count = vim.v.count1 })
  end
  repeat_pair({
    keys = 'l',
    desc_forward = '[Locationlist] Move to next item',
    desc_backward = '[Locationlist] Move to previous item',
    on_forward = locationlist_next,
    on_backward = locationlist_prev,
  })

  -- Move items in locationlist first/last
  -- local locationlist_last = function()
  --   cmd({ cmd = 'lfirst', count = vim.v.count ~= 0 and vim.v.count or nil })
  -- end
  -- local locationlist_first = function()
  --   cmd({ cmd = 'llast', count = vim.v.count ~= 0 and vim.v.count or nil })
  -- end
  -- repeat_pair({
  --   keys = 'L',
  --   desc_forward = '[Locationlist] Move to last item',
  --   desc_backward = '[Locationlist] Move to first item',
  --   on_forward = locationlist_last,
  --   on_backward = locationlist_first,
  -- })

  -- Do not repeat?
  vim.keymap.set('n', ']L', function()
    cmd({ cmd = 'llast', count = vim.v.count ~= 0 and vim.v.count or nil })
  end, { desc = '[Locationlist] Move to last item', noremap = true })
  vim.keymap.set('n', '[L', function()
    cmd({ cmd = 'lfirst', count = vim.v.count ~= 0 and vim.v.count or nil })
  end, { desc = '[Locationlist] Move to first item', noremap = true })

  -- Move to next/prev item in file
  local locationlist_next_file = function()
    cmd({ cmd = 'lnfile', count = vim.v.count1 })
  end
  local locationlist_prev_file = function()
    cmd({ cmd = 'lpfile', count = vim.v.count1 })
  end
  repeat_pair({
    keys = '<C-l>',
    desc_forward = '[Locationlist] Move to next file item',
    desc_backward = '[Locationlist] Move to previous file item',
    on_forward = locationlist_next_file,
    on_backward = locationlist_prev_file,
  })


  -- Argument list

  -- Move to next/prev entry in argument list
  local arglist_next = function()
    -- count doesn't work with :next, must use range. See #30641.
    cmd({ cmd = 'next', range = { vim.v.count1 } })
  end
  local arglist_prev = function()
    cmd({ cmd = 'previous', count = vim.v.count1 })
  end
  repeat_pair({
    keys = 'a',
    desc_forward = '[Argumentlist] Move to next entry',
    desc_backward = '[Argumentlist] Move to previous entry',
    on_forward = arglist_next,
    on_backward = arglist_prev,
  })

  -- Move to first/last entry in argument list
  -- local arglist_last = function()
  --   if vim.v.count ~= 0 then
  --     cmd({ cmd = 'argument', count = vim.v.count })
  --   else
  --     cmd({ cmd = 'last' })
  --   end
  -- end
  -- local arglist_first = function()
  --   if vim.v.count ~= 0 then
  --     cmd({ cmd = 'argument', count = vim.v.count })
  --   else
  --     cmd({ cmd = 'first' })
  --   end
  -- end
  -- repeat_pair({
  --   keys = 'A',
  --   desc_forward = '[Argumentlist] Move to last entry',
  --   desc_backward = '[Argumentlist] Move to first entry',
  --   on_forward = arglist_last,
  --   on_backward = arglist_first,
  -- })

  -- Do not repeat?
  vim.keymap.set('n', ']A', function()
    if vim.v.count ~= 0 then
      cmd({ cmd = 'argument', count = vim.v.count })
    else
      cmd({ cmd = 'last' })
    end
  end, { desc = '[Argumentlist] Move to last entry', noremap = true })
  vim.keymap.set('n', '[A', function()
    if vim.v.count ~= 0 then
      cmd({ cmd = 'argument', count = vim.v.count })
    else
      cmd({ cmd = 'first' })
    end
  end, { desc = '[Argumentlist] Move to first entry', noremap = true })


  -- Tags

  -- Move to next/prev tag
  local tag_next = function()
    -- count doesn't work with :tnext, must use range. See #30641.
    cmd({ cmd = 'tnext', range = { vim.v.count1 } })
  end
  local tag_prev = function()
    -- count doesn't work with :tprevious, must use range. See #30641.
    cmd({ cmd = 'tprevious', range = { vim.v.count1 } })
  end
  repeat_pair({
    keys = 't',
    desc_forward = '[Tags] Move to next tag',
    desc_backward = '[Tags] Move to previous tag',
    on_forward = tag_next,
    on_backward = tag_prev,
  })

  -- Move to next/prev tag
  -- local tag_last = function()
  --   -- :tlast does not accept a count, so use :tfirst if count given
  --   if vim.v.count ~= 0 then
  --     cmd({ cmd = 'tfirst', range = { vim.v.count } })
  --   else
  --     cmd({ cmd = 'tlast' })
  --   end
  -- end
  -- local tag_first = function()
  --   -- count doesn't work with :trewind, must use range. See #30641.
  --   cmd({ cmd = 'tfirst', range = vim.v.count ~= 0 and { vim.v.count } or nil })
  -- end
  -- repeat_pair({
  --   keys = 'T',
  --   desc_forward = '[Tags] Move to last tag',
  --   desc_backward = '[Tags] Move to first tag',
  --   on_forward = tag_last,
  --   on_backward = tag_first,
  -- })

  -- Do not repeat?
  vim.keymap.set('n', ']T', function()
    -- :tlast does not accept a count, so use :trewind if count given
    if vim.v.count ~= 0 then
      cmd({ cmd = 'tfirst', range = { vim.v.count } })
    else
      cmd({ cmd = 'tlast' })
    end
  end, { desc = '[Tags] Move to last tag', noremap = true })
  vim.keymap.set('n', '[T', function()
    -- count doesn't work with :trewind, must use range. See #30641.
    cmd({ cmd = 'tfirst', range = vim.v.count ~= 0 and { vim.v.count } or nil })
  end, { desc = '[Tags] Move to first tag', noremap = true })

  -- Move to next/prev tag in preview window
  local tag_next_preview = function()
    -- count doesn't work with :ptnext, must use range. See #30641.
    cmd({ cmd = 'ptnext', range = { vim.v.count1 } })
  end
  local tag_prev_preview = function()
    -- count doesn't work with :ptprevious, must use range. See #30641.
    cmd({ cmd = 'ptprevious', range = { vim.v.count1 } })
  end
  repeat_pair({
    keys = '<C-t>',
    desc_forward = '[Tags] Move to next tag in preview window',
    desc_backward = '[Tags] Move to previous tag in preview window',
    on_forward = tag_next_preview,
    on_backward = tag_prev_preview,
  })


  -- Buffers

  -- Move to next/prev buffer
  local buffer_next = function()
    cmd({ cmd = 'bnext', count = vim.v.count1 })
  end
  local buffer_prev = function()
    cmd({ cmd = 'bprevious', count = vim.v.count1 })
  end
  repeat_pair({
    keys = 'b',
    desc_forward = '[Buffers] Move to next buffer',
    desc_backward = '[Buffers] Move to previous buffer',
    on_forward = buffer_next,
    on_backward = buffer_prev,
  })

  -- Move to first/last buffer
  -- local buffer_last = function()
  --   if vim.v.count ~= 0 then
  --     cmd({ cmd = 'buffer', count = vim.v.count })
  --   else
  --     cmd({ cmd = 'blast' })
  --   end
  -- end
  -- local buffer_fist = function()
  --   if vim.v.count ~= 0 then
  --     cmd({ cmd = 'buffer', count = vim.v.count })
  --   else
  --     cmd({ cmd = 'bfirst' })
  --   end
  -- end
  -- repeat_pair({
  --   keys = 'B',
  --   desc_forward = '[Buffers] Move to last buffer',
  --   desc_backward = '[Buffers] Move to first buffer',
  --   on_forward = buffer_last,
  --   on_backward = buffer_fist,
  -- })

  -- Do not repeat?
  vim.keymap.set('n', ']B', function()
    if vim.v.count ~= 0 then
      cmd({ cmd = 'buffer', count = vim.v.count })
    else
      cmd({ cmd = 'blast' })
    end
  end, { desc = '[Buffers] Move to last buffer', noremap = true })
  vim.keymap.set('n', '[B', function()
    if vim.v.count ~= 0 then
      cmd({ cmd = 'buffer', count = vim.v.count })
    else
      cmd({ cmd = 'bfirst' })
    end
  end, { desc = '[Buffers] Move to first buffer', noremap = true })


  -- Add empty lines after/before cursor
  local empty_line_next = function()
    vim.print('there')
    -- TODO: update once it is possible to assign a Lua function to options #25672
    vim.go.operatorfunc = "v:lua.require'vim._buf'.space_below"
    vim.cmd[[normal g@l]]
  end
  local empty_line_prev = function()
    vim.print('here')
    -- TODO: update once it is possible to assign a Lua function to options #25672
    vim.go.operatorfunc = "v:lua.require'vim._buf'.space_above"
    vim.cmd[[normal g@l]]
  end
  repeat_pair({
    keys = '<space>',
    desc_forward = '[EmptyLine] Add empty line after cursor',
    desc_backward = '[EmptyLine] Add empty line before cursor',
    on_forward = empty_line_next,
    on_backward = empty_line_prev,
  })


  -- Fold jump next/prev
  repeat_pair({
    keys = 'z',
    mode = nxo,
    desc_forward = '[Fold] Move to next fold',
    desc_backward = '[Fold] Move to previous fold',
    on_forward = function ()
      vim.api.nvim_feedkeys(vim.v.count1..'zj', 'xn', true)
    end,
    on_backward = function ()
      vim.api.nvim_feedkeys(vim.v.count1..'zk', 'xn', true)
    end,
  })


  -- Spelling next/prev
  repeat_pair({
    keys = 's',
    mode = nxo,
    desc_forward = '[Spell] Move to next spelling mistake',
    desc_backward = '[Spell] Move to previous spelling mistake',
    on_forward = function ()
      -- `]s`/`[s` only work if `spell` is enabled
      local spell = vim.wo.spell
      vim.wo.spell = true
      vim.api.nvim_feedkeys(vim.v.count1..'[s', 'xn', true)
      vim.wo.spell = spell
    end,
    on_backward = function ()
      -- `]s`/`[s` only work if `spell` is enabled
      local spell = vim.wo.spell
      vim.wo.spell = true
      vim.api.nvim_feedkeys(vim.v.count1..'s[', 'xn', true)
      vim.wo.spell = spell
    end,
  })


  -- Move to next/previous hunk
  local move_hunk = function (forward)
    if vim.wo.diff then -- If we're in a diff
      local direction_key = forward and ']' or '['
      vim.cmd.normal({ vim.v.count1 .. direction_key .. 'c', bang = true })
    else
      local exists, gitsigns = pcall(require, 'gitsigns')
      if not exists then
        vim.notify('GitSings not found', vim.log.levels.WARN)
        return
      end

      local direction = forward and 'next' or 'prev'
      gitsigns.nav_hunk(direction)
    end
  end

  repeat_pair({
    keys = 'c',
    mode = nxo,
    desc_forward = '[GitSings] Move to next hunk',
    desc_backward = '[GitSings] Move to previous hunk',
    on_forward = function ()
      move_hunk(true)
    end,
    on_backward = function ()
      move_hunk(false)
    end,
  })


  -- Move to next/prev Tab
  repeat_pair({
    keys = '<tab>',
    desc_forward = '[Tab] Move to next tab',
    desc_backward = '[Tab] Move to previous tab',
    on_forward = function ()
      vim.cmd(vim.v.count1..'tabnext')
    end,
    on_backward = function ()
      vim.cmd(vim.v.count1..'tabprevious')
    end,
  })


  -- Jump to next conflict
  local jumpconflict_next = function()
    -- vim.cmd([[execute "normal \<Plug>JumpconflictContextNext"]])
    vim.cmd.normal(vim.keycode('<Plug>JumpconflictContextNext'))
  end
  local jumpconflict_prev = function()
    -- vim.cmd([[execute "normal \<Plug>JumpconflictContextPrevious"]])
    vim.cmd.normal(vim.keycode('<Plug>JumpconflictContextPrevious'))
  end
  repeat_pair({
    keys = 'n',
    desc_forward = '[JumpConflict] Move to next conflict marker',
    desc_backward = '[JumpConflict] Move to previous conflict marker',
    on_forward = jumpconflict_next,
    on_backward = jumpconflict_prev,
  })


  -- Move to next todo comment
  local todo_next = function()
    local ok, todocomments = pcall(require, 'todo-comments')
    if not ok then
      vim.notify('Todo comments not found', vim.log.levels.WARN)
      return
    end
    todocomments.jump_next()
  end
  local todo_prev = function()
    local ok, todocomments = pcall(require, 'todo-comments')
    if not ok then
      vim.notify('Todo comments not found', vim.log.levels.WARN)
      return
    end
    todocomments.jump_prev()
  end

  repeat_pair({
    keys = ':',
    desc_forward = '[TodoComments] Move to next todo comment',
    desc_backward = '[TodoComments] Move to previous todo comment',
    on_forward = todo_next,
    on_backward = todo_prev,
  })


  local ctrl_w = vim.api.nvim_replace_termcodes('<C-w>', true, true, true)
  local vsplit_bigger, vsplit_smaller = create_repeatable_pair(function()
    vim.fn.feedkeys(ctrl_w .. '5>', 'n')
  end, function()
    vim.fn.feedkeys(ctrl_w .. '5<', 'n')
  end)

  repeat_pair({
    keys = '>',
    prefix_forward = '<A-.',
    prefix_backward = '<A-,',
    on_forward = vsplit_bigger,
    on_backward = vsplit_smaller,
    desc_forward = '[VSplit] Make vsplit bigger',
    desc_backward = '[VSplit] Make vsplit smaller',
  })

  local split_bigger, split_smaller = create_repeatable_pair(function()
    vim.fn.feedkeys(ctrl_w .. '+', 'n')
  end, function()
    vim.fn.feedkeys(ctrl_w .. '-', 'n')
  end)

  repeat_pair({
    keys = '>',
    prefix_forward = '<A-t',
    prefix_backward = '<A-s',
    on_forward = split_bigger,
    on_backward = split_smaller,
    desc_forward = '[Split] Make split bigger',
    desc_backward = '[Split] Make split smaller',
  })

  -- Diagnostic mappings
  local diagnostic_jump_next = nil
  local diagnostic_jump_prev = nil

  if vim.diagnostic.jump then
    diagnostic_jump_next = vim.diagnostic.jump
    diagnostic_jump_prev = vim.diagnostic.jump
  else
    -- Deprecated in favor of `vim.diagnostic.jump` in Neovim 0.11.0
    diagnostic_jump_next = vim.diagnostic.goto_next
    diagnostic_jump_prev = vim.diagnostic.goto_prev
  end

  local diagnostic_next,
  diagnostic_prev
  = create_repeatable_pair(
  ---Move to next diagnostic
  ---@param options vim.diagnostic.JumpOpts | nil
    function(options)
      local opts = options or {}
      ---@diagnostic disable-next-line
      opts.count = 1 * vim.v.count1
      diagnostic_jump_next(opts)
    end,
    ---Move to provious diagnostic
    ---@param options vim.diagnostic.JumpOpts | nil
    function(options)
      local opts = options or {}
      ---@diagnostic disable-next-line
      opts.count = -1 * vim.v.count1
      diagnostic_jump_prev(opts)
    end
  )

  -- diagnostic
  vim.keymap.set('n', ']d', function()
      diagnostic_next({ wrap = true })
    end,
    { desc = 'LSP: Go to next diagnostic message', silent = true, noremap = true }
  )
  vim.keymap.set('n', '[d', function()
      diagnostic_prev({ wrap = true })
    end,
    { desc = 'LSP: Go to previous diagnostic message', silent = true, noremap = true }
  )

  -- diagnostic ERROR
  vim.keymap.set('n', ']e', function()
    diagnostic_next({ severity = vim.diagnostic.severity.ERROR, wrap = true })
  end, { desc = 'LSP: Go to next error', silent = true, noremap = true })
  vim.keymap.set('n', '[e', function()
    diagnostic_prev({ severity = vim.diagnostic.severity.ERROR, wrap = true })
  end, { desc = 'LSP: Go to previous error', silent = true, noremap = true })

  -- diagnostic WARN
  vim.keymap.set('n', ']w', function()
    diagnostic_next({ severity = vim.diagnostic.severity.WARN, wrap = true })
  end, { desc = 'LSP: Go to next warning', silent = true, noremap = true })
  vim.keymap.set('n', '[w', function()
    diagnostic_prev({ severity = vim.diagnostic.severity.WARN, wrap = true })
  end, { desc = 'LSP: Go to previous warning', silent = true, noremap = true })

  -- diagnostic INFO, using H as it is often a variation of hint
  vim.keymap.set('n', ']H', function()
    diagnostic_next({ severity = vim.diagnostic.severity.INFO })
  end, { desc = 'LSP: Go to next info', silent = true, noremap = true })
  vim.keymap.set('n', '[H', function()
    diagnostic_prev({ severity = vim.diagnostic.severity.INFO })
  end, { desc = 'LSP: Go to previous info', silent = true, noremap = true })

  -- diagnostic HINT
  vim.keymap.set('n', ']h', function()
    diagnostic_next({ severity = vim.diagnostic.severity.HINT })
  end, { desc = 'LSP: Go to next hint', silent = true, noremap = true })
  vim.keymap.set('n', '[h', function()
    diagnostic_prev({ severity = vim.diagnostic.severity.HINT })
  end, { desc = 'LSP: Go to previous hint', silent = true, noremap = true })

  -- Override next-prev matching bracket
  -- local next_close_bracket, prev_close_bracket = create_repeatable_pair(
  --   function ()
  --     vim.fn.search('}')
  --   end, function ()
  --     vim.fn.search('}', 'b')
  --   end
  -- )
  -- local next_open_bracket, prev_open_bracket = create_repeatable_pair(
  --   function ()
  --     vim.fn.search('{')
  --   end, function ()
  --     vim.fn.search('{', 'b')
  --   end
  -- )
  -- vim.keymap.set('n', ']}', next_close_bracket, { desc = '[Bracket]: Go to next close bracket', silent = true, noremap = true })
  -- vim.keymap.set('n', '[}', prev_close_bracket, { desc = '[Bracket]: Go to previous close bracket', silent = true, noremap = true })
  -- vim.keymap.set('n', ']{', next_open_bracket, { desc = '[Bracket]: Go to next open bracket', silent = true, noremap = true })
  -- vim.keymap.set('n', '[{', prev_open_bracket, { desc = '[Bracket]: Go to previous open bracket', silent = true, noremap = true })

  local next_matching_bracket, prev_matching_bracket = create_repeatable_pair(
    function()
      ---@diagnostic disable-next-line Diagnostic have the wrong function signature for searchpair
      vim.fn.searchpair('{', '', '}')
    end, function()
      ---@diagnostic disable-next-line Diagnostic have the wrong function signature for searchpair
      vim.fn.searchpair('{', '', '}', 'b')
    end
  )
  local next_bracket_pair, prev_bracket_pair = create_repeatable_pair(
    function()
      vim.fn.search('[{}]')
    end, function()
      vim.fn.search('[{}]', 'b')
    end
  )
  vim.keymap.set('n', ']}', next_bracket_pair,
    { desc = '[Bracket]: Go to next bracket pair', silent = true, noremap = true })
  vim.keymap.set('n', '[}', prev_bracket_pair,
    { desc = '[Bracket]: Go to previous bracket pair', silent = true, noremap = true })
  vim.keymap.set('n', ']{', next_matching_bracket,
    { desc = '[Bracket]: Go to next matching bracket', silent = true, noremap = true })
  vim.keymap.set('n', '[{', prev_matching_bracket,
    { desc = '[Bracket]: Go to previous matching bracket', silent = true, noremap = true })


  ---Move to the next indent scope using direction
  ---@param direction boolean
  local move_scope = function (direction)
    local ok, mini_indent = pcall(require, 'mini.indentscope')

    if not ok then
      vim.notify('GitSings not found', vim.log.levels.WARN)
      return
    end

    local dir = direction and 'bottom' or 'top'

    mini_indent.operator(dir)
  end
  -- TODO: Consider if overriding this defaults is correct
  repeat_pair({
    keys = 'i',
    mode = nxo,
    on_forward = function ()
      move_scope(true)
    end,
    on_backward = function ()
      move_scope(false)
    end,
    desc_forward = '[MiniIndent] Go to indent scope top',
    desc_backward = '[MiniIndent] Go to indent scope bottom',
  })
end

return {
  set_keymaps = set_keymaps,
  setup = function()
    require('nvim-treesitter').define_modules({
      fold_treesiter = {
        attach = function(buf, lang)
          -- Options set only for buffers with treesitter parser
          vim.opt_local.foldmethod = 'expr'
          vim.opt_local.foldexpr = 'nvim_treesitter#foldexpr()'
          -- Options set in global config
          -- exec 'set fillchars=fold:\ '
          -- set foldmethod=indent
          -- set nofoldenable
          -- set foldlevel=99
        end,
        detach = function(buf)
          -- Unset changes
          -- vim.opt_local.foldmethod = 'indent'
          -- vim.opt_local.foldexpr = ''
          vim.opt_local.foldmethod = vim.go.foldmethod
          vim.opt_local.foldexpr = vim.go.foldexpr
        end,
        is_supported = function(lang)
          return true
        end,
      }
    })

    local config = require('nvim-treesitter.configs')
    ---@diagnostic disable-next-line: missing-fields
    config.setup({
      fold_treesiter = {
        enable = true,
      },
      ignore_install = {},
      sync_install = true,
      ensure_installed = {
        'git_config',
        'git_rebase',
        'gitattributes',
        'gitcommit',
        'gitignore',
        'json5',
        'ssh_config',
        'markdown',
        'markdown_inline',
        'html',
        -- 'latex',
        'typst',
        'yaml',
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
      -- for 'nvim-treesitter/nvim-treesitter-textobjects',
      textobjects = {
        lsp_interop = {
          enable = true,
          border = 'rounded', -- 'none',
          floating_preview_opts = {},
          peek_definition_code = {
            ['<space>df'] = '@function.outer',
            ['<space>dF'] = '@class.outer',
          },
        },
        select = {
          enable = true,

          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,

          keymaps = {
            ['agb'] = { query = '@block.outer', desc = 'Select a block' },
            ['igb'] = { query = '@block.inner', desc = 'Select inner block' },
            -- You can use the capture groups defined in textobjects.scm
            ['af'] = { query = '@function.outer', desc = 'Select a function' },
            ['if'] = { query = '@function.inner', desc = 'Select inner function' },
            ['ac'] = { query = '@class.outer', desc = 'Select a class' },
            -- You can optionally set descriptions to the mappings (used in the desc parameter of
            -- nvim_buf_set_keymap) which plugins like which-key display
            ['ic'] = { query = '@class.inner', desc = 'Select inner part of a class region' },
            -- You can also use captures from other query groups like `locals.scm`
            ['as'] = { query = '@scope', query_group = 'locals', desc = 'Select language scope' },
          },
          -- You can choose the select mode (default is charwise 'v')
          --
          -- Can also be a function which gets passed a table with the keys
          -- * query_string: eg '@function.inner'
          -- * method: eg 'v' or 'o'
          -- and should return the mode ('v', 'V', or '<c-v>') or a table
          -- mapping query_strings to modes.
          selection_modes = {
            ['@parameter.outer'] = 'v', -- charwise
            ['@function.outer'] = 'v',  -- 'V' -- linewise
            ['@class.outer'] = 'v'      -- '<c-v>', -- blockwise
          },
          -- If you set this to `true` (default is `false`) then any textobject is
          -- extended to include preceding or succeeding whitespace. Succeeding
          -- whitespace has priority in order to act similarly to eg the built-in
          -- `ap`.
          --
          -- Can also be a function which gets passed a table with the keys
          -- * query_string: eg '@function.inner'
          -- * selection_mode: eg 'v'
          -- and should return true or false
          include_surrounding_whitespace = true,
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            [']m'] = { query = '@function.outer', desc = '[TS] Next function start' },
            [']]'] = { query = '@class.outer', desc = '[TS] Next class start' },
            [']k'] = { query = '@block.*', desc = '[TS] Next block start' },
            [']C'] = { query = '@comment.outer', desc = '[TS] Next comment start' }
            --
            -- You can use regex matching (i.e. lua pattern) and/or pass a list in a 'query' key to group multiple queries.
            -- [']o'] = '@loop.*',
            -- [']o'] = { query = { '@loop.inner', '@loop.outer' } }
            --
            -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
            -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
            -- [']s'] = { query = '@local.scope', query_group = 'locals', desc = 'Next scope' },
            -- [']z'] = { query = '@fold', query_group = 'folds', desc = 'Next fold' },
          },
          goto_next_end = {
            [']M'] = { query = '@function.outer', desc = '[TS] Next function end' },
            [']['] = { query = '@class.outer', desc = '[TS] Next class end' },
            [']K'] = { query = '@block.outer', desc = '[TS] Next block end' },
          },
          goto_previous_start = {
            ['[m'] = { query = '@function.outer', desc = '[TS] Previous function start' },
            ['[['] = { query = '@class.outer', desc = '[TS] Previous class start' },
            ['[k'] = { query = '@block.*', desc = '[TS] Previous block start' },
            ['[C'] = { query = '@comment.outer', desc = '[TS] Previous comment start' }
          },
          goto_previous_end = {
            ['[M'] = { query = '@function.outer', desc = '[TS] Previous function end' },
            ['[]'] = { query = '@class.outer', desc = '[TS] Previous class end' },
            ['['] = { query = '@block.outer', desc = '[TS] Previous block end' },
          },
          -- Below will go to either the start or the end, whichever is closer.
          -- Use if you want more granular movements
          -- Make it even more gradual by adding multiple queries and regex.
          -- goto_next = {
          --   [']d'] = '@conditional.outer',
          -- },
          -- goto_previous = {
          --   ['[d'] = '@conditional.outer',
          -- }
        },
      },
    })

    -- local treesitterKeymaps = vim.api.nvim_create_augroup('TreesitterKeymaps', { clear = true })
    -- vim.api.nvim_create_autocmd('BufEnter', {
    --   group = treesitterKeymaps,
    --   pattern = '*',
    --   callback = function (event)
    --     -- NOTE: Override default fold config from config based on indentation
    --     -- This will use the treesitter parser to create folds
    --
    --     if vim.api.nvim_buf_get_option(event.buf, 'filetype') ~= '' and vim.treesitter.get_parser(event.buf) then
    --     end
    --   end,
    -- })

    -- NOTE: For custom powershell treesitter parser:
    -- local treesitter_parser_config = require('nvim-treesitter.parsers').get_parser_configs()
    -- treesitter_parser_config.powershell = {
    --   install_info = {
    --     url = '~/.config/nvim/tsparsers/tree-sitter-powershell', -- need to update path
    --     files = { 'src/parser.c', 'src/scanner.c' },
    --     branch = 'main',
    --     generate_requires_npm = false,
    --     requires_generate_from_grammar = false,
    --   },
    --   filetype = 'ps1',
    -- }
  end
}
