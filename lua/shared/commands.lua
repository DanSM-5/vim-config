---Show information about lsp client on float window
---@param opts { bang: boolean, fargs: string[] }
vim.api.nvim_create_user_command('InspectLspClient', function(opts)
  require('utils.inspect_lsp_client').inspect_lsp_client(opts)
end, { nargs = '?', bang = true, force = true })

---Create NR (npm run) command
---@param opts { bang: boolean, fargs: string[] }
vim.api.nvim_create_user_command('NR', function(opts)
  if #opts.fargs == 0 then
    -- Clean trailing lash or backslash
    local dir = require('utils.stdlib').find_root('package.json'):gsub('[\\/]$', '')

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
vim.api.nvim_create_user_command('Npm', function(opts)
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

  require('utils.npm').npm(dir, opts.fargs, opts.bang)
end, { force = true, bang = true, nargs = '*', desc = '[Npm] Small wrapper for the npm command' })

---Create Npx command
---@param opts { bang: boolean, fargs: string[] }
vim.api.nvim_create_user_command('Npx', function(opts)
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
vim.api.nvim_create_user_command('LF', function(opts)
  require('utils.lf').lf(opts.fargs[1], opts.bang)
end, { force = true, bar = true, nargs = '?', complete = 'dir', bang = true })


---@param opts { bang: boolean, fargs: string[] }
vim.api.nvim_create_user_command('MPLS', function(opts)
  require('config.nvim_mpls').start({
    skip_load = opts.bang,
    file = opts.fargs[1],
  })
end, {
  desc = '[MPLS] Start mpls lsp server',
  bar = true,
  bang = true,
  nargs = '?',
  complete = 'file'
})

---@type boolean It should control mini_indentscope
vim.g.miniindentscope_disable = false

vim.api.nvim_create_user_command('IndentGuides', function (opts)
  ---@type string|boolean|nil
  local option = opts.fargs[1]

  if option ~= nil then
    option = option == 'on'
  end

  local has_ibl, ibl = pcall(require, 'ibl')
  if vim.fn.exists(':IBLToggle') then
    -- local ibl_option = option ~= nil and option or (not ibl_state)
    -- ibl_state = ibl_option -- state update
    -- ibl.update({ enabled = ibl_state })

    if option == nil then
      vim.cmd.IBLToggle()
    elseif option then
      vim.cmd.IBLEnable()
    else
      vim.cmd.IBLDisable()
    end
  end

  local has_mindent, mindent = pcall(require, 'mini.indentscope')
  if has_mindent then
    local mindent_option = option ~= nil and option or vim.g.miniindentscope_disable
    -- Notice, this is a negated variable
    vim.g.miniindentscope_disable = not mindent_option
  end
end, {
  desc = '[Indent] Change indent guides visibility',
  nargs = '?',
  bang = true,
  bar = true,
  complete = function () return { 'on', 'off' }  end,
})
