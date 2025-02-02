require('utils.types')

-- Utility functions for neovim

---Sets window options
---@param win integer
---@param k string
---@param v any
function wo(win, k, v)
  if vim.api.nvim_set_option_value then
    vim.api.nvim_set_option_value(k, v, { scope = 'local', win = win })
  else
    vim.wo[win][k] = v
  end
end

---Echo a message using a specific highlight group
---Defaults to WarningMsg highlight group
--- Usage:
--- echo('WarningMsg', 'Some message')
---@param hlgroup string Highlight group to use. See `:h hi`.
---@param msg string Message to echo
local function echo(hlgroup, msg)
  local group = hlgroup
  if not group then
    group = 'WarningMsg'
  end
  vim.cmd('echohl ' .. group)
  vim.cmd('echo "' .. msg .. '"')
  vim.cmd('echohl None')
end

---@param msg string|string[]
---@param opts? table
local function error(msg, opts)
  opts = opts or {}
  vim.notify(
    type(msg) == 'string' and msg or table.concat(msg --[[@as table]], '\n'),
    vim.log.levels.ERROR,
    opts
  )
end

---@param opts? config.FloatOptions
---@return config.Float
local function float(opts)
  return require('utils.float')(opts)
end

-- Opens a floating terminal (interactive by default)
---@param cmd? string[]|string
---@param opts? config.TermOptions|{interactive?:boolean}
local function float_term(cmd, opts)
  cmd = cmd or {}
  if type(cmd) == 'string' then
    cmd = { cmd }
  end
  if #cmd == 0 then
    cmd = { vim.o.shell }
  end
  opts = opts or {}
  ---@type config.TermOpenOpts
  local termopen_opts = {}
  if vim.tbl_isempty(opts.term_opts or {}) then
    termopen_opts = vim.empty_dict()
  else
    termopen_opts = opts.term_opts or {}
    termopen_opts.cwd = termopen_opts.cwd or opts.cwd
    termopen_opts.env = termopen_opts.env or opts.env
  end

  local float_window = float(opts)
  vim.fn.termopen(cmd, termopen_opts)
  if opts.interactive ~= false then
    vim.cmd.startinsert()
    vim.api.nvim_create_autocmd('TermClose', {
      once = true,
      buffer = float_window.buf,
      callback = function()
        if opts.on_exit then
          local lines = vim.api.nvim_buf_get_lines(float_window.buf, 0, -1, false)
          opts.on_exit(lines)
        end
        float_window:close({ wipe = true })
        vim.cmd.checktime()
      end,
    })
  end
  return float_window
end

--- Runs the command and shows it in a floating window
---@param cmd string[]
---@param opts? config.CmdOptions|{filetype?:string}
local function float_cmd(cmd, opts)
  opts = opts or {}
  local Process = require('utils.process')
  local lines, code = Process.exec(cmd, opts.process_opts or {})
  if code ~= 0 then
    error({
      '`' .. table.concat(cmd, ' ') .. '`',
      '',
      '## Error',
      table.concat(lines, '\n'),
    }, { title = 'Command Failed (' .. code .. ')' })
    return
  end

  if opts.on_complete then
    opts.on_complete(lines)
  end
  local float_window = float(opts)
  if opts.filetype then
    vim.bo[float_window.buf].filetype = opts.filetype
  end
  vim.api.nvim_buf_set_lines(float_window.buf, 0, -1, false, lines)
  vim.bo[float_window.buf].modifiable = false
  return float_window
end

-- Opens a floating terminal (interactive by default)
-- Command stdout can be get back uning on_end callback
---@param cmd? string[]
---@param opts? config.TermOptions|{interactive?:boolean}
---@param on_end? fun(output: string[])
local function run_command(cmd, opts, on_end)
  if not on_end then
    return float_term(cmd, opts)
  end

  local is_win = jit.os:find('Windows')
  ---@type string[]
  local run
  -- package.config:sub(1,1) ~= '/'
  local scripts = vim.fn.stdpath('config') .. '/utils'
  local tempfile = vim.fn.tempname()

  if is_win then
    run = {
      -- Incantation to make sure powershell runs a script
      -- without loading a whole profile nor blocking it.
      vim.fn.executable('pwsh') and 'pwsh' or 'powershell',
      '-NoLogo', '-NonInteractive', '-NoProfile', '-ExecutionPolicy', 'Bypass',
      '-File', vim.fn.substitute(scripts, '\\', '/', 'g') .. '/run.ps1',
    }
  else
    run = { scripts .. '/run.sh' }
  end

  opts = opts or {}
  opts.env = vim.tbl_deep_extend('force', opts.env or {}, {
    CMD_OUTPUT = tempfile
  })
  opts.term_opts = opts.term_opts or {}

  local local_onexit = function ()
    ---@type boolean, string[]
    local ok, lines = pcall(vim.fn.readfile, tempfile)
    if not ok then
      lines = {}
    end
    if require('utils.stdlib').file_exists(tempfile) then
      os.remove(tempfile)
    end
    on_end(lines)
  end

  if opts.term_opts.on_exit then
    local call_onexit = opts.term_opts.on_exit
    opts.term_opts.on_exit = function (...)
      ---@diagnostic disable-next-line
      call_onexit(...)
      local_onexit()
    end
  else
    opts.term_opts.on_exit = function() local_onexit() end
  end

  local wrapped_cmd = require('utils.stdlib').concat(run, cmd or {})
  return float_term(wrapped_cmd, opts)
end

return {
  wo = wo,
  echo = echo,
  float = float,
  error = error,
  float_cmd = float_cmd,
  float_term = float_term,
  run_command = run_command,
}

