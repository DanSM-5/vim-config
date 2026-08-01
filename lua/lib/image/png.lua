local M = {}

local signature = '\137PNG\r\n\26\n'

---@param data string
---@return boolean
function M.is_png(data)
  return type(data) == 'string' and data:sub(1, 8) == signature
end

local function uint32(data, offset)
  local a, b, c, d = data:byte(offset, offset + 3)
  if not d then
    return nil
  end
  return ((a * 256 + b) * 256 + c) * 256 + d
end

---@param data string
---@return integer? width
---@return integer? height
function M.dimensions(data)
  if not M.is_png(data) or data:sub(13, 16) ~= 'IHDR' then
    return nil, nil
  end
  return uint32(data, 17), uint32(data, 21)
end

return M
