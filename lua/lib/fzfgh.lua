local M = {}

local expected_keys = 'enter,ctrl-d,ctrl-o,ctrl-s'
local supported_keys = {
  enter = true,
  ['ctrl-d'] = true,
  ['ctrl-o'] = true,
  ['ctrl-s'] = true,
}

local function notify(message, level)
  vim.notify(('[Fzfgh] %s'):format(message), level or vim.log.levels.ERROR)
end

---@param name 'ghf'
---@return string[]?
local function script_command(name)
  if vim.fn.has('win32') == 1 then
    local script = vim.fn.exepath(name .. '.ps1')
    if script ~= '' then
      local powershell = vim.fn.executable('pwsh') == 1 and 'pwsh'
        or (vim.fn.executable('powershell') == 1 and 'powershell' or nil)
      if not powershell then
        notify('Cannot find pwsh or powershell on PATH')
        return nil
      end
      return {
        powershell,
        '-NoLogo',
        '-NonInteractive',
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        script,
      }
    end
  end

  local executable = vim.fn.exepath(name)
  if executable == '' then
    notify(('Cannot find %s on PATH'):format(name))
    return nil
  end

  return { executable }
end

---@param output string
---@return string[]
local function output_lines(output)
  local lines = vim.split(output:gsub('\r', ''), '\n', { plain = true })
  if lines[#lines] == '' then
    table.remove(lines)
  end
  return lines
end

---@param lines string[]
---@return string?, string?
local function parse_selection(lines)
  local key = nil
  local pr = nil

  for _, line in ipairs(lines) do
    local value = vim.trim(line:gsub('\r', ''))
    if supported_keys[value] then
      key = value
      pr = nil
    elseif key then
      pr = value:match('^(%d+)$') or value:match('^#(%d+)$')
      if pr then
        break
      end
    end
  end

  return key, pr
end

---@param lines string[]
---@param key string
---@param pr string
---@param origin_win integer
local function open_pr(lines, key, pr, origin_win)
  if #lines == 0 then
    return
  end

  local window = vim.api.nvim_win_is_valid(origin_win) and origin_win or vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(window)
  vim.cmd('botright vsplit')

  local buffer = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_win_set_buf(0, buffer)
  vim.api.nvim_buf_set_name(buffer, ('fzfgh://pr/%s/%d'):format(pr, buffer))
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = buffer })
  vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = buffer })
  vim.api.nvim_set_option_value('swapfile', false, { buf = buffer })
  vim.api.nvim_set_option_value('filetype', 'markdown', { buf = buffer })
  vim.api.nvim_set_option_value('modifiable', false, { buf = buffer })
  vim.api.nvim_set_option_value('readonly', true, { buf = buffer })
  vim.api.nvim_set_option_value('modified', false, { buf = buffer })
  vim.api.nvim_buf_set_var(buffer, 'fzfgh_expected_key', key)
end

---@param cwd string
---@param arguments string[]
---@param action 'browser'|'checkout'|'view'
---@param key string
---@param pr string
---@param origin_win integer
local function run_gh(cwd, arguments, action, key, pr, origin_win)
  local command = { 'gh' }
  vim.list_extend(command, arguments)

  local ok, error = pcall(vim.system, command, { cwd = cwd, text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        local message = vim.trim(result.stderr or '')
        if message == '' then
          message = vim.trim(result.stdout or '')
        end
        notify(message ~= '' and message or ('gh command exited with status %d'):format(result.code))
        return
      end

      if action == 'view' then
        local lines = output_lines(result.stdout or '')
        if #lines == 0 then
          notify(('No details returned for PR #%s'):format(pr), vim.log.levels.WARN)
          return
        end
        open_pr(lines, key, pr, origin_win)
      elseif action == 'checkout' then
        notify(('Checked out PR #%s'):format(pr), vim.log.levels.INFO)
      end
    end)
  end)

  if not ok then
    notify(tostring(error))
  end
end

---@param cwd string
---@param origin_win integer
---@param lines string[]
---@param status integer
local function handle_selection(cwd, origin_win, lines, status)
  local key, pr = parse_selection(lines)
  if not key or not pr then
    if status ~= 0 then
      notify(('ghf exited with status %d'):format(status), vim.log.levels.WARN)
    end
    return
  end

  if key == 'enter' or key == 'ctrl-d' then
    run_gh(cwd, { 'pr', 'view', pr }, 'view', key, pr, origin_win)
  elseif key == 'ctrl-o' then
    run_gh(cwd, { 'pr', 'view', pr, '--web' }, 'browser', key, pr, origin_win)
  elseif key == 'ctrl-s' then
    run_gh(cwd, { 'pr', 'checkout', pr }, 'checkout', key, pr, origin_win)
  end
end

---@param fullscreen boolean
function M.select_prs(fullscreen)
  local command = script_command('ghf')
  if not command then
    return
  end

  local cwd = vim.fn.getcwd()
  local origin_win = vim.api.nvim_get_current_win()
  local options = {
    cmd = command,
    fullscreen = fullscreen,
    name = 'ghf',
    ft = 'fzfgh_terminal',
    term = {
      cwd = cwd,
      env = { GHF_EXPECT = expected_keys },
    },
    on_term_exit = function(lines, status)
      handle_selection(cwd, origin_win, lines, status)
    end,
  }

  local terminal = require('lib.terminal')
  if fullscreen then
    terminal.win_term(options)
  else
    options.float = { border = 'none' }
    terminal.float_term(options)
  end
end

return M
