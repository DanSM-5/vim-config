local terminal = require('lib.image.terminal')

local M = { name = 'iterm2' }

---@param config LibImageConfig
---@return boolean
function M.available(config)
  return config.backend == 'iterm2' or terminal.is_iterm2() or terminal.is_wezterm()
end

---@class LibImageIterm2Encoded
---@field transmission string
---@field drawn boolean

---@param data string PNG bytes
---@param layout table
---@param _cell_width number
---@param _cell_height number
---@param _config LibImageConfig
---@param callback fun(encoded: LibImageIterm2Encoded?, err: string?)
function M.encode(data, layout, _cell_width, _cell_height, _config, callback)
  if data == '' then
    callback(nil, 'iTerm2 backend received empty PNG data')
    return
  end
  local ok, payload = pcall(vim.base64.encode, data)
  if not ok then
    callback(nil, 'Unable to encode PNG data for iTerm2: ' .. tostring(payload))
    return
  end

  local arguments = table.concat({
    'inline=1',
    'size=' .. #data,
    'width=' .. math.max(1, math.floor(layout.width)),
    'height=' .. math.max(1, math.floor(layout.height)),
    'preserveAspectRatio=1',
    -- This is a WezTerm extension. iTerm2 ignores unknown arguments, and the
    -- surrounding save/restore sequences retain the cursor there.
    'doNotMoveCursor=1',
  }, ';')
  callback({ transmission = '\27]1337;File=' .. arguments .. ':' .. payload .. '\7', drawn = false }, nil)
end

---@param encoded LibImageIterm2Encoded
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
    encoded.transmission,
    '\27[u',
    '\27[?2026l',
  })
  local ok = pcall(vim.fn.chansend, vim.v.stderr, sequence)
  if ok then
    encoded.drawn = true
  end
  return ok
end

---@param encoded? LibImageIterm2Encoded
function M.clear(encoded)
  if not encoded or not encoded.drawn then
    return
  end
  -- OSC 1337 has no image identifier or targeted delete operation. Repainting
  -- Neovim's grid removes the cell-attached image in compatible terminals.
  pcall(vim.cmd.redraw, { bang = true })
  encoded.drawn = false
end

return M
