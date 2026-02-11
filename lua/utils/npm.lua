---Runs the npm command in a new terminal buffer
---@param dir string Directory to use to run the command
---@param cmd 'npm' | 'npx' | 'pnpm' Command to execute
---@param args string[] | nil Argument for the command
---@param fullscreen boolean | nil Ensure full screen view (new tab)
local open_term = function (dir, cmd, args, fullscreen)
  -- Store current buffer reference for navigating back
  -- local curr_buf = vim.api.nvim_get_current_buf()
  -- local temp = vim.fn.tempname()
  local buf = vim.api.nvim_create_buf(false, true)
  -- -@type nil|integer
  -- local temporaryTabId = nil

  pcall(vim.api.nvim_set_option_value, 'filetype', 'npm_cmd', { buf = buf })

  if fullscreen then
    -- Open new tab to ensure fullscreen
    vim.cmd.tabnew()
    -- temporaryTabId = vim.api.nvim_get_current_tabpage()
  end

  -- Apend buffer in current window
  vim.api.nvim_win_set_buf(0, buf)

  ---@type string[]
  local termopen_args = { cmd }

  if args and #args > 0 then
    termopen_args = require('utils.stdlib').concat(termopen_args, args)
  end

  -- Run termopen on the context of the created buffer
  vim.api.nvim_buf_call(buf, function()
    -- Name the buffer
    vim.api.nvim_buf_set_name(buf, 'Npm Command')
    vim.fn.termopen(termopen_args, {
      cwd = dir,
      on_exit = function(jobId, code, evt)
        -- Should we do anything on exit?
      end,
    })
  end)

end

---Runs the script command in a new terminal buffer
---@param dir string Directory in which the `npm run` command is executed
---@param cmd 'npm' | 'pnpm' Command to run
---@param args string[] | nil Argument for the `npm run` command
---@param fullscreen? boolean Whether to display in fullscreen
local run = function (dir, cmd, args, fullscreen)
  local new_args = require('utils.stdlib').shallow_clone(args or {})
  table.insert(new_args, 1, 'run')
  open_term(dir, cmd, new_args, fullscreen)
end

---Select a npm command to run in a terminal buffer
---@param dir? string Directory or buffer from where to search a package.json
---@param cmd? string Command to run
---@param fullscreen? boolean Open on fullscreen
---@param t_fullscreen? boolean Open terminal on fullscreen
local runfzf = function(dir, cmd, fullscreen, t_fullscreen)
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
    local result = require('utils.stdlib').find_root('package.json')
    cwd = result ~= 0 and result or nil
  end

  if (cwd == nil) or
    (not (vim.uv or vim.loop).fs_stat(cwd .. '/package.json')) then
    vim.notify('NPMRUN: package.json not found', vim.log.levels.WARN)
    return
  end

  local package_json = cwd .. '/package.json'
  local scripts = vim.json.decode(vim.fn.join(vim.fn.readfile(package_json), '')).scripts
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

    local split = require('utils.stdlib').split
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
  local new_args = require('utils.stdlib').shallow_clone(args or {})
  table.insert(new_args, 1, 'exec')
  open_term(dir, 'pnpm', args, fullscreen)
end



return {
  open = open_term,
  runfzf = runfzf,
  run = run,
  npm = npm,
  npx = npx,
  pnpm = pnpm,
  pnpx = pnpx,
}

