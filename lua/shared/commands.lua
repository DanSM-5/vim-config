
---Show information about lsp client on float window
---@param opts { bang: boolean, fargs: string[] }
vim.api.nvim_create_user_command('InspectLspClient', function (opts)
  require('utils.inspect_lsp_client').inspect_lsp_client(opts)
end, { nargs = '?', bang = true })

---Create NR (npm run) command
---@param opts { bang: boolean, fargs: string[] }
vim.api.nvim_create_user_command('NR', function (opts)
  if opts.bang then
    require('utils.npm').run()
    return
  end

  -- Find directory with package.json
  local dir = vim.fn.FindProjectRoot('package.json')
  if dir == 0 then
    vim.notify('NPMRUN: package.json not found', vim.log.levels.WARN)
    return
  end

  require('utils.npm').open(dir, 'run', opts.fargs)
end, { bang = true, nargs = '*' })

---Create NR (npm run) command
---@param opts { bang: boolean, fargs: string[] }
vim.api.nvim_create_user_command('Npm', function (opts)
  -- Find directory with package.json
  local dir = vim.fn.FindProjectRoot('package.json')
  if dir == 0 then
    vim.notify('NPMRUN: package.json not found', vim.log.levels.WARN)
    return
  end

  local args = require('utils.stdlib').shallow_clone(opts.fargs)
  local cmd = table.remove(args, 1)
  require('utils.npm').open(dir, cmd, args, opts.bang)
end, { bang = true, nargs = '*' })

