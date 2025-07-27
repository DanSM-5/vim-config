
---Press yc to copy unamed(") register to system(*) register
-- vim.keymap.set('n', 'yd', function()
--   -- require('utils.register').regmove('+', '"')
--   vim.fn['utils#register_move']('+', '"')
-- end, { noremap = true, desc = 'Copy from anon register to system cliboard register' })
-- vim.keymap.set('n', 'yD', function()
--   -- require('utils.register').regmove('"', '+')
--   vim.fn['utils#register_move']('"', '+')
-- end, { noremap = true, desc = 'Copy from anon register to system cliboard register' })


-- -- Mapping to remove marks on the line uner the cursor
-- vim.keymap.set({ 'n' }, '<leader>`d', function()
--   local bufnr = vim.api.nvim_get_current_buf()
--   local cur_line = vim.fn.line('.')
--   --                            [bufnum, lnum, col, off]
--   ---@type { mark: string; pos: [number, number, number, number] }[]
--   local all_marks_local = vim.fn.getmarklist(bufnr)
--   for _, mark in ipairs(all_marks_local) do
--     if mark.pos[2] == cur_line and string.match(mark.mark, "'[a-z]") then
--       vim.notify('Deleting mark: ' .. string.sub(mark.mark, 2, 2))
--       vim.api.nvim_buf_del_mark(bufnr, string.sub(mark.mark, 2, 2))
--     end
--   end
--   local bufname = vim.api.nvim_buf_get_name(bufnr)
--   --                                          [bufnum, lnum, col, off]
--   ---@type { file: string; mark: string; pos: [number, number, number, number] }[]
--   local all_marks_global = vim.fn.getmarklist()
--   for _, mark in ipairs(all_marks_global) do
--     -- local expanded_file_name = vim.api.nvim_buf_get_name(mark.pos[1])
--     local expanded_file_name = vim.fn.fnamemodify(mark.file, ':p')
--     if bufname == expanded_file_name and mark.pos[2] == cur_line and string.match(mark.mark, "'[A-Z]") then
--       vim.notify('Deleting mark: ' .. string.sub(mark.mark, 2, 2))
--       vim.api.nvim_del_mark(string.sub(mark.mark, 2, 2))
--     end
--   end
-- end, { desc = 'Delete all marks for current line' })


-- ---Get the text between the marks a and b using the appropriate mode
-- ---@param a_mark string Reference mark a
-- ---@param b_mark string Reference mark b
-- ---@param mode string Mode to process text from marks
-- ---@return string[] Selected text. One entry per line from left to right.
-- local get_selected_text_marks = function (a_mark, b_mark, mode)
--   local _, line_start, column_start = unpack(vim.fn.getpos(a_mark))
--   local _, line_end, column_end = unpack(vim.fn.getpos(b_mark))

--   -- Mark could be reversed if starting selection from bottom to top or right to left
--   if (vim.fn.line2byte(line_start)+column_start) > (vim.fn.line2byte(line_end)+column_end) then
--     line_start, column_start, line_end, column_end = line_end, column_end, line_start, column_start
--   end

--   -- Should always be an array when passing two arguments
--   local lines = vim.fn.getline(line_start, line_end) --[[@as string[] ]]

--   -- No selection, return empty
--   if #lines == 0 then
--     return {}
--   end

--   -- Handle visual line selection
--   if mode == 'V' then
--     return lines -- No further process
--   end

--   -- Handle visual block selection
--   if mode == vim.keycode('<C-V>') then
--     -- Selection can be reversed if started from right to left
--     if column_start > column_end then
--       column_start, column_end = column_end, column_start
--     end

--     if vim.o.selection == 'exclusive' then
--       column_end = column_end - 1 -- Needed to remove the last character to make it match the visual selction
--     end

--     for idx = 1, #lines do
--       -- Get just the selected area from each line
--       lines[idx] = lines[idx]:sub(1, column_end)
--       lines[idx] = lines[idx]:sub(column_start)
--     end

--     return lines
--   end

--   -- Handle visual mode 'v'
--   if vim.o.selection == 'exclusive' then
--     column_end = column_end - 1 -- Needed to remove the last character to make it match the visual selction
--   end

--   -- Adjust first and last selected lines to the respective start/end position
--   lines[#lines] = lines[#lines]:sub(1, column_end)
--   lines[1] = lines[1]:sub(column_start)

--   return lines
-- end

-- ---Get text from visual selected area
-- ---@return string[] Selected text. One entry per line from left to right.
-- local get_selected_text = function ()
--   local mode = vim.fn.mode()
--   if mode == 'v' or mode == 'V' or mode == vim.keycode('<C-V>') then
--     return get_selected_text_marks('v', '.', mode)
--   else
--     return get_selected_text_marks("'<", "'>", vim.fn.visualmode())
--   end
-- end

---Unset default keymaps that could conflict with other
---user defined keymaps
local remove_default = function ()
  --  grr gra grn gri i_CTRL-S Some keymaps are created unconditionally when Nvim starts:
  -- "grn" is mapped in Normal mode to vim.lsp.buf.rename()
  -- "gra" is mapped in Normal and Visual mode to vim.lsp.buf.code_action()
  -- "grr" is mapped in Normal mode to vim.lsp.buf.references()
  -- "gri" is mapped in Normal mode to vim.lsp.buf.implementation()
  -- "gO" is mapped in Normal mode to vim.lsp.buf.document_symbol()
  -- CTRL-S is mapped in Insert mode to vim.lsp.buf.signature_help()
  -- Ref: https://neovim.io/doc/user/lsp.html
  if vim.fn.has('nvim-0.11.0') == 1 then
    -- Unset defaults and let lsp-settings/keymaps.lua handle the keys
    vim.keymap.del('n', 'grr')
    vim.keymap.del('n', 'grn')
    vim.keymap.del('n', 'gra')
    vim.keymap.del('x', 'gra')
    vim.keymap.del('n', 'gri')
    vim.keymap.del('n', 'grt')
    -- vim.keymap.del('n', 'g0')
  end
end

---Set repeatable maps that use a combination of '[' and ']'
---for directionality and ',' and ';' for repeatability.
local function set_repeat_direction_maps()
  local nxo = { 'n', 'x', 'o' }
  ---It prefers repeat module from treesitter-textobjects
  ---however it can fallback to our builtin one if treesitter not present
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
    -- TODO: update once it is possible to assign a Lua function to options #25672
    vim.go.operatorfunc = "v:lua.require'vim._buf'.space_below"
    vim.cmd[[normal g@l]]
  end
  local empty_line_prev = function()
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
  ---@param forward boolean Direction of the keymap
  local spell_direction = function (forward)
    -- `]s`/`[s` only work if `spell` is enabled
    local spell = vim.wo.spell
    vim.wo.spell = true
    local direction = (forward and ']' or '[') .. 's'
    vim.api.nvim_feedkeys(vim.v.count1..direction, 'xn', true)
    vim.wo.spell = spell
  end
  repeat_pair({
    keys = 's',
    mode = nxo,
    desc_forward = '[Spell] Move to next spelling mistake',
    desc_backward = '[Spell] Move to previous spelling mistake',
    on_forward = function ()
      spell_direction(true)
    end,
    on_backward = function ()
      spell_direction(false)
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
    prefix_backward = 'g',
    prefix_forward = 'g',
    keys = { 't', 'T' },
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
    { desc = '[Diagnostic] Go to next diagnostic message', silent = true, noremap = true }
  )
  vim.keymap.set('n', '[d', function()
      diagnostic_prev({ wrap = true })
    end,
    { desc = '[Diagnostic] Go to previous diagnostic message', silent = true, noremap = true }
  )

  -- diagnostic ERROR
  vim.keymap.set('n', ']e', function()
    diagnostic_next({ severity = vim.diagnostic.severity.ERROR, wrap = true })
  end, { desc = '[Diagnostic] Go to next error', silent = true, noremap = true })
  vim.keymap.set('n', '[e', function()
    diagnostic_prev({ severity = vim.diagnostic.severity.ERROR, wrap = true })
  end, { desc = '[Diagnostic] Go to previous error', silent = true, noremap = true })

  -- diagnostic WARN
  vim.keymap.set('n', ']w', function()
    diagnostic_next({ severity = vim.diagnostic.severity.WARN, wrap = true })
  end, { desc = '[Diagnostic] Go to next warning', silent = true, noremap = true })
  vim.keymap.set('n', '[w', function()
    diagnostic_prev({ severity = vim.diagnostic.severity.WARN, wrap = true })
  end, { desc = '[Diagnostic] Go to previous warning', silent = true, noremap = true })

  -- diagnostic INFO, using H as it is often a variation of hint
  vim.keymap.set('n', ']H', function()
    diagnostic_next({ severity = vim.diagnostic.severity.INFO })
  end, { desc = '[Diagnostic] Go to next info', silent = true, noremap = true })
  vim.keymap.set('n', '[H', function()
    diagnostic_prev({ severity = vim.diagnostic.severity.INFO })
  end, { desc = '[Diagnostic] Go to previous info', silent = true, noremap = true })

  -- diagnostic HINT
  vim.keymap.set('n', ']h', function()
    diagnostic_next({ severity = vim.diagnostic.severity.HINT })
  end, { desc = '[Diagnostic] Go to next hint', silent = true, noremap = true })
  vim.keymap.set('n', '[h', function()
    diagnostic_prev({ severity = vim.diagnostic.severity.HINT })
  end, { desc = '[Diagnostic] Go to previous hint', silent = true, noremap = true })

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
      vim.fn.search('[\\[\\]{}()<>]', 'w')
    end, function()
      vim.fn.search('[\\[\\]{}()<>]', 'wb')
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


  local move_line_end, move_line_almost_end = create_repeatable_pair(function ()
    vim.cmd.normal([[ddGp``]])
  end, function ()
    vim.cmd.normal([[ddGP``]])
    -- vim.cmd.normal([[ddggP``]])
  end)
  local move_line_start, move_line_almost_start = create_repeatable_pair(function ()
    vim.cmd.normal([[ddggP``]])
  end, function ()
    vim.cmd.normal([[ddggp``]])
  end)

  -- move current line to the end or the begin of current buffer (continuation)
  vim.keymap.set('n', ']<End>', move_line_end, { desc = 'Move line to end of the buffer', noremap = true, silent = true })
  vim.keymap.set('n', '[<End>', move_line_almost_end,
    { desc = 'Move line to the second last line in the buffer', noremap = true, silent = true })
  vim.keymap.set(
    'n',
    ']<Home>',
    move_line_almost_start,
    { desc = 'Move line to second line in the buffer', noremap = true, silent = true }
  )
  vim.keymap.set(
    'n',
    '[<Home>',
    move_line_start,
    { desc = 'Move line to start of the buffer', noremap = true, silent = true }
  )

end

return {
  load = function ()
    remove_default()
  end,
  remove_default = remove_default,
  set_repeatable_maps = set_repeat_direction_maps,
}
