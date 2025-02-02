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
  local lines, code = Process.exec(cmd, { cwd = opts.cwd })
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

return {
  wo = wo,
  echo = echo,
  float = float,
  error = error,
  float_cmd = float_cmd,
  float_term = float_term,
}

