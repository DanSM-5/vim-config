local M = {}

local backends = {
  sixel = require('lib.image.backends.sixel'),
}

---@param name string
---@param backend table
---@param opts? { force?: boolean }
function M.register(name, backend, opts)
  vim.validate('name', name, 'string')
  vim.validate('backend', backend, 'table')
  if backends[name] and not (opts and opts.force) then
    error('Image backend already registered: ' .. name, 2)
  end
  backends[name] = backend
end

function M.unregister(name)
  local previous = backends[name]
  backends[name] = nil
  return previous
end

---@param config LibImageConfig
---@return table? backend
---@return string? err
function M.select(config)
  if config.backend ~= 'auto' then
    local backend = backends[config.backend]
    if not backend then
      return nil, 'Unknown image backend: ' .. tostring(config.backend)
    end
    if not backend.available(config) then
      return nil, ('Image backend `%s` is unavailable'):format(config.backend)
    end
    return backend
  end
  for _, name in ipairs({ 'sixel' }) do
    local backend = backends[name]
    if backend and backend.available(config) then
      return backend
    end
  end
  return nil, 'No image backend is available (the Sixel backend requires `chafa`)'
end

function M.capabilities(config)
  local result = {}
  for name, backend in pairs(backends) do
    result[name] = backend.available(config)
  end
  return result
end

return M
