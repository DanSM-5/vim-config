local png = require('lib.image.png')

local M = { name = 'kitty' }

local next_image_id = math.max(1, math.abs(vim.fn.rand()))

local function image_id()
  next_image_id = next_image_id % 2147483646 + 1
  return next_image_id
end

local function kitty_environment()
  local term = (vim.env.TERM or ''):lower()
  local term_program = (vim.env.TERM_PROGRAM or ''):lower()
  return vim.env.KITTY_WINDOW_ID ~= nil
    or vim.env.WEZTERM_PANE ~= nil
    or term == 'xterm-kitty'
    or term_program == 'wezterm'
end

---@param config LibImageConfig
---@return boolean
function M.available(config)
  return config.backend == 'kitty' or config.renderer.kitty.force or kitty_environment()
end

local function placement_size(data, layout, cell_width, cell_height)
  local pixel_width, pixel_height = png.dimensions(data)
  if not pixel_width or not pixel_height then
    return nil, nil
  end
  local natural_width = math.max(1 / cell_width, pixel_width / cell_width)
  local natural_height = math.max(1 / cell_height, pixel_height / cell_height)
  local scale = math.min(layout.width / natural_width, layout.height / natural_height)
  local width = math.max(1, math.floor(natural_width * scale + 0.5))
  local height = math.max(1, math.floor(natural_height * scale + 0.5))
  return width, height
end

local function chunk_size(config)
  local configured = math.floor(tonumber(config.renderer.kitty.chunk_size) or 4096)
  configured = math.max(4, math.min(4096, configured))
  return configured - configured % 4
end

local function command(control, payload)
  return '\27_G' .. control .. ';' .. (payload or '') .. '\27\\'
end

---@class LibImageKittyEncoded
---@field id integer
---@field transmission string
---@field drawn boolean

---@param data string PNG bytes
---@param layout table
---@param cell_width number
---@param cell_height number
---@param config LibImageConfig
---@param callback fun(encoded: LibImageKittyEncoded?, err: string?)
function M.encode(data, layout, cell_width, cell_height, config, callback)
  local width, height = placement_size(data, layout, cell_width, cell_height)
  if not width or not height then
    callback(nil, 'Kitty backend received invalid PNG data')
    return
  end
  local ok, encoded = pcall(vim.base64.encode, data)
  if not ok then
    callback(nil, 'Unable to encode PNG data for Kitty: ' .. tostring(encoded))
    return
  end

  local id = image_id()
  local size = chunk_size(config)
  local chunks = {}
  local offset = 1
  local first = true
  while offset <= #encoded do
    local payload = encoded:sub(offset, offset + size - 1)
    offset = offset + #payload
    local more = offset <= #encoded and 1 or 0
    local control
    if first then
      control = ('a=T,f=100,t=d,i=%d,c=%d,r=%d,C=1,q=2,m=%d'):format(id, width, height, more)
      first = false
    else
      control = 'm=' .. more
    end
    table.insert(chunks, command(control, payload))
  end
  callback({ id = id, transmission = table.concat(chunks), drawn = false }, nil)
end

---@param encoded LibImageKittyEncoded
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

---@param encoded? LibImageKittyEncoded
function M.clear(encoded)
  if not encoded or not encoded.drawn then
    return
  end
  pcall(vim.fn.chansend, vim.v.stderr, command(('a=d,d=I,i=%d,q=2'):format(encoded.id)))
  encoded.drawn = false
end

return M
