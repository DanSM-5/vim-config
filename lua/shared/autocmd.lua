-- Autocmds that can be shared between lua configs

-- vim.api.nvim_create_autocmd({ 'FileType' }, {
--   desc = 'Force commentstring to include spaces',
--   -- group = ...,
--   callback = function(event)
--     local cs = vim.bo[event.buf].commentstring
--     vim.bo[event.buf].commentstring = cs:gsub('(%S)%%s', '%1 %%s'):gsub('%%s(%S)', '%%s %1')
--   end,
-- })

