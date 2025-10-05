-- Autocmds that can be shared between lua configs

-- vim.api.nvim_create_autocmd({ 'FileType' }, {
--   desc = 'Force commentstring to include spaces',
--   -- group = ...,
--   callback = function(event)
--     local cs = vim.bo[event.buf].commentstring
--     vim.bo[event.buf].commentstring = cs:gsub('(%S)%%s', '%1 %%s'):gsub('%%s(%S)', '%%s %1')
--   end,
-- })

-- Change cursor color when recording a macro as a visual help
local record_group = vim.api.nvim_create_augroup('CursorColorOnRecord', { clear = true })
local recover_cursor_color = vim.api.nvim_get_hl(0, { name = 'Cursor' })
vim.api.nvim_create_autocmd('RecordingEnter', {
  desc = 'Change cursor color when recording macro starts',
  group = record_group,
  callback = function ()
    recover_cursor_color = vim.api.nvim_get_hl(0, { name = 'Cursor' })
    -- Set cursor to green to signal that recording started
    vim.api.nvim_set_hl(0, 'Cursor', { fg = '#282c34', bg = '#16e81e', ctermfg = 0, ctermbg = 040 })
  end
})
vim.api.nvim_create_autocmd('RecordingLeave', {
  desc = 'Recover cursor color when recording macro starts',
  group = record_group,
  callback = function ()
    if recover_cursor_color == nil or type(recover_cursor_color) ~= 'table' then
      return
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    vim.api.nvim_set_hl(0, 'Cursor', recover_cursor_color)
  end
})

-- Create repeatable mappings using nvim-treesitter-textobjects
vim.api.nvim_create_autocmd('VimEnter', {
  desc = 'Create repeatable bindings',
  pattern = { '*' },
  callback = function ()
    --- Not loaded until VimEnter to ensure the
    --- appropriate repeat direction module is loaded
    require('shared.maps').set_repeatable_maps()
  end
})

-- Show yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('TextYankedGroup', { clear = true }),
  callback = function ()
    vim.hl.on_yank()
  end,
  desc = 'Highlight yanked text',
})
