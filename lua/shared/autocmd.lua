-- Autocmds that can be shared between lua configs

-- vim.api.nvim_create_autocmd({ 'FileType' }, {
--   desc = 'Force commentstring to include spaces',
--   -- group = ...,
--   callback = function(event)
--     local cs = vim.bo[event.buf].commentstring
--     vim.bo[event.buf].commentstring = cs:gsub('(%S)%%s', '%1 %%s'):gsub('%%s(%S)', '%%s %1')
--   end,
-- })

-- Override regular LF autocommand
---Create LF command to use lf binary to select files
---@param opts { fargs: string[] }
vim.api.nvim_create_user_command('LF', function (opts)
  require('utils.lf').lf(opts.fargs[1])
end, { force = true, bar = true, nargs = '?', complete = 'dir' })

