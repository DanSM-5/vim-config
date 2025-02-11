
---Show information about lsp client on float window
---@param opts { bang: boolean, fargs: string[] }
vim.api.nvim_create_user_command('InspectLspClient', function (opts)
  require('utils.inspect_lsp_client').inspect_lsp_client(opts)
end, { nargs = '?', bang = true, force = true })

---Create NR (npm run) command
---@param opts { bang: boolean, fargs: string[] }
vim.api.nvim_create_user_command('NR', function (opts)
  if #opts.fargs == 0 then
    local dir = opts.fargs[1]
    if dir then
      -- Clean trailing lash or backslash
      dir = dir:gsub('[\\/]$','')
    end
    require('utils.npm').runfzf(dir)
    return
  end

  -- Find directory with package.json
  local dir = opts.bang
    and vim.fn.expand('%:p:h')
    or require('utils.stdlib').find_root('package.json')

  if dir == nil then
    vim.notify('NPMRUN: Directory not found', vim.log.levels.WARN)
    return
  end

  require('utils.npm').run(dir, opts.fargs)
end, { bang = true, nargs = '*', complete = 'dir', force = true, desc = '[NR] Small wrapper for `npm run` command' })

---Create Npm command
---@param opts { bang: boolean, fargs: string[] }
vim.api.nvim_create_user_command('Npm', function (opts)
  -- Find directory with package.json
  local dir = require('utils.stdlib').find_root('package.json')
  if dir == nil then
    if opts.fargs[1] == 'run' then
      vim.notify('NPMRUN: package.json not found', vim.log.levels.WARN)
      return
    else
      dir = vim.fn.getcwd()
    end
  end

  require('utils.npm').npm(dir, args, opts.bang)
end, { force = true, bang = true, nargs = '*', desc = '[Npm] Small wrapper for the npm command' })

---Create Npx command
---@param opts { bang: boolean, fargs: string[] }
vim.api.nvim_create_user_command('Npx', function (opts)
  -- Find directory with package.json
  local dir = require('utils.stdlib').find_root('package.json')
  if dir == nil then
    dir = vim.fn.getcwd()
  end

  require('utils.npm').npx(dir, opts.fargs, opts.bang)
end, { force = true, bang = true, nargs = '*', desc = '[Npx] Small wrapper for the npx command' })

-- Override regular LF autocommand
---Create LF command to use lf binary to select files
---@param opts { fargs: string[]; bang: boolean; }
vim.api.nvim_create_user_command('LF', function (opts)
  require('utils.lf').lf(opts.fargs[1], opts.bang)
end, { force = true, bar = true, nargs = '?', complete = 'dir', bang = true })


---@param opts { bang: boolean, fargs: string[] }
vim.api.nvim_create_user_command('MPLS', function (opts)
  require('config.nvim_mpls').start({
    skip_load = opts.bang,
    file = opts.fargs[1],
  })
end, {
  desc = '[Lsp] Start mpls lsp server',
  bar = true,
  bang = true,
  nargs = 1,
  complete = 'file'
})

