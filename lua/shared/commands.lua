---Get the matching value from the a list
---@param options string[]
---@param value string
---@return string[]
local function get_matched(options, value)
  local matched = vim.tbl_filter(function (option)
    local _, matches = string.gsub(option, value, '')
    return matches > 0
  end, options)

  return #matched > 0 and matched or options
end

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
  complete = function (current, cmd)
    -- Only complete first arg
    if #vim.split(cmd, ' ') > 2 then
      return
    end

    local engines = { '@google', '@bing', '@duckduckgo', '@wikipedia', '@brave', '@yandex', '@github' }
    if type(current) == 'string' and #current > 0 then
      return get_matched(engines, current)
    end

    return engines
  end
})


---Callback function for TSModule commands
---@param module string
---@param state 'enable'|'disable'|''|nil
---@param switch boolean|nil
local ts_modules_callback = function (module, state, switch)
  -- local module = args[1]
  -- local state = args[2]

  local buf = vim.api.nvim_get_current_buf()
  local filetype = vim.api.nvim_get_option_value('filetype', { buf = buf })
  local lang = vim.treesitter.language.get_lang(filetype)

  -- Cannot proceed without language
  if not lang then
    return
  end

  local manager = require('treesitter-modules.core.manager')
  local modules = manager.modules
  local target_mod = require('utils.stdlib').find(function (mod)
    return mod.name() == module
  end, modules)

  if not target_mod then
    vim.notify(string.format('Module "%s" is not registered', module), vim.log.levels.WARN)
    return
  end

  -- Enable / disable logic
  local ctx = { buf = buf, language = lang }
  local set = manager.cache:get(buf)

  local disable_module = function ()
    if set:has(module) then
      set:remove(module)
      target_mod.detach(ctx)
    end
    if switch then
      target_mod.disable = true
    end
  end
  local enable_module = function ()
    if not set:has(module) then
      set:add(module)
      target_mod.attach(ctx)
    end
    if switch then
      target_mod.disable = false
    end
  end

  if state == 'enable' then
    enable_module()
  elseif state == 'disable' then
    disable_module()
  elseif state == '' or state == nil then
    if set:has(module) then
      disable_module()
    else
      enable_module()
    end
  end
end

---Get module names
---@return string[]
local ts_modules_get_names = function ()
  local names = {}
  local ts_modules = require('treesitter-modules.core.manager').modules

  for _, mod in ipairs(ts_modules) do
    table.insert(names, mod.name())
  end

  return names
end

---Complete function for module names
---@param current string
---@return string[]
local ts_modules_complete_name = function (current)
  local names = ts_modules_get_names()
  if #current > 0 then
    return get_matched(names, current)
  end

  return names
end

---Change status of module 'on' / 'off'
---@param module string
---@param state 'on'|'off'
local ts_modules_switch = function (module, state)
  local manager = require('treesitter-modules.core.manager')
  local modules = manager.modules
  local target_mod = require('utils.stdlib').find(function (mod)
    return mod.name() == module
  end, modules)

  if not target_mod then
    vim.notify(string.format('Module "%s" is not registered', module), vim.log.levels.WARN)
    return
  end

  if state == 'on' then
    target_mod.disable = false
  elseif state == 'off' then
    target_mod.disable = true
  end
end

---Complete function for TS modules
---@param current string Leading command argument
---@param cmd string Current command line including command
---@param cur_pos integer Cursor position in cmd
---@return string[]
local ts_modules_complete_fn = function (current, cmd, cur_pos)
  if #vim.split(cmd, ' ') > 2 then
    return {}
  end

  return ts_modules_complete_name(current)
end

vim.api.nvim_create_user_command('TSModuleToggle', function (args)
  local module = args.fargs[1]
  local state = args.fargs[2]
  ts_modules_callback(module, state, args.bang)
end, { desc = '[TSModules] Toggle module', bang = true, bar = true, complete = function (current, cmd, cur_pos)
  vim.print({ current, cmd, cur_pos })

  local cmd_parts = vim.split(cmd, ' ')

  if #cmd_parts >= 4 then
    return
  end

  if #cmd_parts == 3 then
    return get_matched({ 'enable', 'disable' }, current)
  end

  return ts_modules_complete_name(current)
end, nargs = '+' })

vim.api.nvim_create_user_command('TSModuleEnable', function (args)
  local module = args.fargs[1]
  if module ~= nil then
    return ts_modules_callback(module, 'enable', args.bang)
  end

  local names = ts_modules_get_names()
  require('utils.fzf').fzf({
    name = 'ts_modules',
    source = names,
    fullscreen = args.bang,
    fzf_opts = { '--no-multi', '--prompt', 'TSModule enable> ' },
    sink = function (options)
      if #options < 2 then
        return
      end
      local selected = options[2]
      return ts_modules_callback(selected, 'enable')
    end
  })
end, {
  desc = '[TSModules] Enable module',
  bang = true,
  bar = true,
  complete = ts_modules_complete_fn,
  nargs = '?',
})

vim.api.nvim_create_user_command('TSModuleDisable', function (args)
  local module = args.fargs[1]
  if module ~= nil then
    return ts_modules_callback(module, 'disable', args.bang)
  end

  local names = ts_modules_get_names()
  require('utils.fzf').fzf({
    name = 'ts_modules',
    source = names,
    fullscreen = args.bang,
    fzf_opts = { '--no-multi', '--prompt', 'TSModule disable> ' },
    sink = function (options)
      if #options < 2 then
        return
      end
      local selected = options[2]
      return ts_modules_callback(selected, 'disable')
    end
  })
end, {
  desc = '[TSModules] Disable module',
  bang = true,
  bar = true,
  complete = ts_modules_complete_fn,
  nargs = '?'
})

vim.api.nvim_create_user_command('TSModuleOn', function (args)
  local module = args.fargs[1]
  ts_modules_switch(module, 'on')
end, {
  desc = '[TSModules] Activate module',
  bang = true,
  bar = true,
  complete = ts_modules_complete_fn,
  nargs = 1,
})

vim.api.nvim_create_user_command('TSModuleOff', function (args)
  local module = args.fargs[1]
  ts_modules_switch(module, 'off')
end, {
  desc = '[TSModules] Activate module',
  bang = true,
  bar = true,
  complete = ts_modules_complete_fn,
  nargs = 1,
})
