---Resolve the paths for a package_json
---@param dir? string Path to use as base to resolve
---@return { packageJson?: string; root?: string } Resolved paths if package.json was found
local function resolve_packageJson(dir)
  local cwd = nil

  if dir ~= nil then
    if vim.fn.isdirectory(dir) then
      -- Dir that should have a package.json
      cwd = dir
    else
      -- directory of buffer
      cwd = vim.fn.fnamemodify(dir, ':p:h')
    end
  else
    -- if no provided, try to find a package.json from current buffer location
    local result = require('lib.std').find_root('package.json')
    cwd = result ~= 0 and result or nil
  end

  if (cwd == nil) or
    (not (vim.uv or vim.loop).fs_stat(cwd .. '/package.json')) then
    return vim.empty_dict()
  end

  return {
    packageJson = vim.fs.joinpath(cwd, 'package.json'),
    root = cwd,
  }
end

---Get a table with key-value pairs of scripts in package.json
---@param dir? string
---@return table<string, string> scripts
local function get_scripts(dir)
  local resolved = resolve_packageJson(dir)
  local package_json = resolved.packageJson

  if not package_json then
    return vim.empty_dict()
  end

  ---@type table<string, string>
  local scripts = vim.json.decode(vim.fn.join(vim.fn.readfile(package_json), '')).scripts
  return scripts
end

---Runs the npm command in a new terminal buffer
---@param dir string Directory to use to run the command
---@param cmd 'npm' | 'npx' | 'pnpm' Command to execute
---@param args string[] | nil Argument for the command
---@param fullscreen boolean | nil Ensure full screen view (new tab)
local open_term = function (dir, cmd, args, fullscreen)

  if fullscreen then
    -- Open new tab to ensure fullscreen
    vim.cmd.tabnew()
    -- temporaryTabId = vim.api.nvim_get_current_tabpage()
  end

  -- Apend buffer in current window

  ---@type string[]
  local term_args = { cmd }

  if args and #args > 0 then
    term_args = require('lib.std').concat(term_args, args)
  end

  require('lib.terminal').win_term({
    cmd = term_args,
    name = ('Npm Command: %s'):format(table.concat(term_args, ' ')),
    term = {
      cwd = dir,
    },
    ft = 'npm_cmd',
    fullscreen = fullscreen,
    keep = true, -- keep open to validate content of buffer
  })
end

---Runs the script command in a new terminal buffer
---@param dir string Directory in which the `npm run` command is executed
---@param cmd 'npm' | 'pnpm' Command to run
---@param args string[] | nil Argument for the `npm run` command
---@param fullscreen? boolean Whether to display in fullscreen
local run = function (dir, cmd, args, fullscreen)
  local new_args = require('lib.std').shallow_clone(args or {})
  table.insert(new_args, 1, 'run')
  open_term(dir, cmd, new_args, fullscreen)
end

---Select a npm command to run in a terminal buffer
---@param dir? string Directory or buffer from where to search a package.json
---@param cmd? string Command to run
---@param fullscreen? boolean Open on fullscreen
---@param t_fullscreen? boolean Open terminal on fullscreen
local runfzf = function(dir, cmd, fullscreen, t_fullscreen)
  local resolved = resolve_packageJson(dir)
  local cwd = resolved.root
  if not cwd then
    vim.notify('NPMRUN: Could not find package.json')
    return
  end

  local scripts = get_scripts(resolved.root)
  local source = {}

  for key, value in pairs(scripts) do
    table.insert(source, key .. '\t' .. value)
  end

  if #source == 0 then
    vim.notify('NPMRUN: No scripts in package.json')
    return
  end

  ---@type string[]
  local options = {
    '-d', '\t',
    '--no-multi',
    '--cycle',
    '--with-nth', '1',
    '--preview', 'echo {2}',
    '--bind', 'ctrl-^:toggle-preview',
    '--bind', 'ctrl-l:change-preview-window(down|hidden|)',
    '--bind', 'ctrl-/:change-preview-window(down|hidden|)',
    '--bind', 'alt-up:preview-page-up,alt-down:preview-page-down',
    '--bind', 'alt-f:first',
    '--bind', 'alt-l:last',
  }

  local sink = function (selected)
    if #selected <= 1 then
      return
    end

    local split = require('lib.std').split
    local ok, npm_line = pcall(split, selected[2], '\t')

    if not ok or #npm_line == 0 then
      return
    end

    local npm_command = npm_line[1]

    -- Command should not be empty and it should exists in the scripts
    if not npm_command or not scripts[npm_command] then
      return
    end

    run(cwd, cmd or 'npm', { npm_command }, t_fullscreen)
  end

  require('utils.fzf').fzf({
    sink = sink,
    source = source,
    fullscreen = fullscreen,
    name = 'npm_run',
    fzf_opts = options,
  })
end

---Runs the `npm` command in a new terminal buffer
---@param dir string Directory to use to run the command
---@param args string[] | nil Argument for the command
---@param fullscreen boolean | nil Ensure full screen view (new tab)
local npm = function (dir, args, fullscreen)
  open_term(dir, 'npm', args, fullscreen)
end

---Runs the `npx` command in a new terminal buffer
---@param dir string Directory to use to run the command
---@param args string[] | nil Argument for the command
---@param fullscreen boolean | nil Ensure full screen view (new tab)
local npx = function (dir, args, fullscreen)
  open_term(dir, 'npx', args, fullscreen)
end

---Runs the `npm` command in a new terminal buffer
---@param dir string Directory to use to run the command
---@param args string[] | nil Argument for the command
---@param fullscreen boolean | nil Ensure full screen view (new tab)
local pnpm = function (dir, args, fullscreen)
  open_term(dir, 'pnpm', args, fullscreen)
end

local pnpx = function (dir, args, fullscreen)
  local new_args = require('lib.std').shallow_clone(args or {})
  table.insert(new_args, 1, 'exec')
  open_term(dir, 'pnpm', args, fullscreen)
end


return {
  resolve_packageJson = resolve_packageJson,
  get_scripts = get_scripts,
  open = open_term,
  runfzf = runfzf,
  run = run,
  npm = npm,
  npx = npx,
  pnpm = pnpm,
  pnpx = pnpx,
}

