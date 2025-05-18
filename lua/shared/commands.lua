---Show information about lsp client on float window
---@param opts { bang: boolean, fargs: string[] }
vim.api.nvim_create_user_command('InspectLspClient', function(opts)
  require('utils.inspect_lsp_client').inspect_lsp_client(opts)
end, { nargs = '?', bang = true, force = true })

---Create NR (npm run) command
---@param opts { bang: boolean, fargs: string[] }
vim.api.nvim_create_user_command('NR', function(opts)
  local terminal_fullscreen = opts.bang

  if #opts.fargs == 0 then
    -- Clean trailing lash or backslash
    local dir = require('utils.stdlib').find_root('package.json'):gsub('[\\/]$', '')

    require('utils.npm').runfzf(dir, false, terminal_fullscreen)
    return
  end

  -- Find directory with package.json
  -- local dir = opts.bang
  --     and vim.fn.expand('%:p:h')
  --     or require('utils.stdlib').find_root('package.json')
  local dir = require('utils.stdlib').find_root('package.json')

  if dir == nil then
    vim.notify('NPMRUN: Directory not found', vim.log.levels.WARN)
    return
  end

  require('utils.npm').run(dir, opts.fargs, terminal_fullscreen)
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

  local has_mindent = pcall(require, 'mini.indentscope')
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

vim.api.nvim_create_user_command('Fshow', function (opts)
  local dir = opts.fargs[1]
  if dir == nil then
    dir = vim.fn.expand('%:p:h')
  end

  if not require('utils.stdlib').is_git_dir(dir) then
    vim.notify('Not a git repository', vim.log.levels.ERROR)
    return
  end

  require('utils.fshow').fshow(dir)
end, {
  complete = 'dir',
  nargs = '?',
  bar = true,
  bang = true,
  desc = '[FShow] Show the commits in fzf',
})

vim.api.nvim_create_user_command('BSearch', function (args)
  local first = args.fargs[1]
  local engine = string.gsub(first, '@', '')
  local search = require('utils.browser_search')
  if string.sub(first, 1, 1) == '@' and search.is_valid_engine(engine) then
    search.search_browser(
      table.concat({ unpack(args.fargs, 2) }, ' '),
      engine
    )

    return
  end

  require('utils.browser_search').search_browser(
    table.concat(args.fargs, ' ')
  )
end, {
  desc = 'Search in browser',
  bang = true,
  -- bar = true,
  nargs = '+',
  complete = function (args)
    local engines = { '@google', '@bing', '@duckduckgo', '@wikipedia', '@brave', '@yandex', '@github' }
    if type(args) == 'string' and #args > 0 then
      local matched = vim.tbl_filter(function (engine)
        local _, matches = string.gsub(engine, args, '')
        return matches > 0
      end, engines)

      return #matched > 0 and matched or engines
    end

    return engines
  end
})
