local process = require('lib.image.process')

local M = { name = 'sixel' }

function M.available(config)
  return vim.fn.executable(config.renderer.sixel.command) == 1
end

---@param data string PNG bytes
---@param layout table
---@param cell_width number
---@param cell_height number
---@param config LibImageConfig
---@param callback fun(encoded: string?, err: string?)
---@return vim.SystemObj?
function M.encode(data, layout, cell_width, cell_height, config, callback)
  local width = math.max(1, math.floor(layout.width * cell_width / 10 + 0.5))
  local height = math.max(1, math.floor(layout.height * cell_height / 20 + 0.5))
  return process.run({
    config.renderer.sixel.command,
    '--format=sixels',
    '--probe=off',
    '--animate=off',
    '--relative=off',
    '--scale=max',
    '--work=' .. tostring(config.renderer.sixel.work),
    '--size=' .. width .. 'x' .. height,
    '-',
  }, { text = false, stdin = data }, function(result)
    if result.code ~= 0 or not result.stdout or result.stdout == '' then
      callback(nil, 'Chafa failed to encode Sixel: ' .. vim.trim(result.stderr or ('exit code ' .. result.code)))
      return
    end
    callback(result.stdout:gsub('[\r\n]+$', ''), nil)
  end)
end

---@param encoded string
---@param layout table
---@return boolean
function M.draw(encoded, layout)
  if not layout.winid or not vim.api.nvim_win_is_valid(layout.winid) then
    return false
  end
  local info = vim.fn.getwininfo(layout.winid)[1]
  if not info then
    return false
  end
  local sequence = table.concat({
    '\27[?2026h',
    '\27[s',
    ('\27[%d;%dH'):format(info.winrow + (layout.border_top or 0), info.wincol + (layout.border_left or 0)),
    encoded,
    '\27[u',
    '\27[?2026l',
  })
  vim.fn.chansend(vim.v.stderr, sequence)
  return true
end

function M.clear()
  vim.cmd.redraw({ bang = true })
end

return M
