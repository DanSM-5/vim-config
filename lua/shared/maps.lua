
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

