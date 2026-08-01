local process = require('lib.image.process')

local M = {}

local is_windows = vim.fn.has('win32') == 1

---@type table<string, LibImageResolver>
local resolvers = {}
local builtins_registered = false

local function notify_callback(callback, source, err)
  vim.schedule(function()
    callback(source, err)
  end)
end

local function scheme_of(value)
  if value:match('^%a:[/\\]') then
    return 'file'
  end
  return value:match('^([%a][%w+.-]*):')
end

local function extension(value)
  local clean = value:gsub('[?#].*$', ''):gsub('[/\\]+$', '')
  return clean:match('%.([%w]+)$') and clean:match('%.([%w]+)$'):lower() or nil
end

local function file_resolver(input, context, _, callback)
  local path = input
  if input:match('^file:') then
    local ok, decoded = pcall(vim.uri_to_fname, input)
    if not ok then
      notify_callback(callback, nil, tostring(decoded))
      return nil
    end
    path = decoded
  else
    local windows_absolute = path:match('^%a:[/\\]') or path:match('^[/\\][/\\]')
    path = vim.uri_decode(path)
    if not windows_absolute then
      if is_windows then
        path = path:gsub('\\ ', ' '):gsub('\\([()<>])', '%1')
      else
        path = path:gsub('\\(.)', '%1')
      end
    end
    path = vim.fn.expand(path)
    if vim.fn.isabsolutepath(path) == 0 then
      path = vim.fs.joinpath(context.base_dir or vim.fn.getcwd(), path)
    end
  end
  path = vim.fs.normalize(path)
  local stat = vim.uv.fs_stat(path)
  if not stat or stat.type ~= 'file' then
    notify_callback(callback, nil, 'File not found: ' .. path)
    return nil
  end
  notify_callback(callback, { path = path, name = vim.fs.basename(path), uri = input }, nil)
  return nil
end

local function http_resolver(input, _, config, callback)
  if not config.remote.enabled then
    notify_callback(callback, nil, 'Remote image previews are disabled')
    return nil
  end
  local scheme = input:match('^([%a][%w+.-]*):')
  if not scheme or not vim.tbl_contains(config.remote.schemes, scheme:lower()) then
    notify_callback(callback, nil, 'Remote image scheme is disabled: ' .. tostring(scheme))
    return nil
  end
  if vim.fn.executable(config.remote.curl) ~= 1 then
    notify_callback(callback, nil, ('`%s` was not found in PATH'):format(config.remote.curl))
    return nil
  end
  local suffix = extension(input)
  local path = process.tempname(suffix and ('.' .. suffix) or '')
  local argv = {
    config.remote.curl,
    '--fail',
    '--location',
    '--silent',
    '--show-error',
    '--max-time',
    tostring(config.remote.timeout),
    '--max-filesize',
    tostring(config.remote.max_bytes),
    '--output',
    path,
    input,
  }
  return process.run(argv, { text = false, timeout = config.remote.timeout * 1000 + 1000 }, function(result)
    if result.code ~= 0 then
      process.unlink(path)
      callback(nil, 'Download failed: ' .. vim.trim(result.stderr or ('curl exited ' .. result.code)))
      return
    end
    local stat = vim.uv.fs_stat(path)
    if not stat or stat.type ~= 'file' or stat.size == 0 then
      process.unlink(path)
      callback(nil, 'Download produced no readable data: ' .. input)
      return
    end
    if stat.size > config.remote.max_bytes then
      process.unlink(path)
      callback(nil, ('Download exceeds configured limit (%d bytes)'):format(config.remote.max_bytes))
      return
    end
    callback({
      path = path,
      name = vim.fs.basename(input:gsub('[?#].*$', '')),
      uri = input,
      cleanup = function()
        process.unlink(path)
      end,
    })
  end)
end

local function ensure_builtins()
  if builtins_registered then
    return
  end
  builtins_registered = true
  resolvers.file = file_resolver
  resolvers.http = http_resolver
  resolvers.https = http_resolver
end

---Register a source scheme resolver. This is the extension point for future
---schemes such as `ssh:` and `s3:`; neither is enabled in this iteration.
---@param scheme string
---@param resolver LibImageResolver
---@param opts? { force?: boolean }
function M.register(scheme, resolver, opts)
  vim.validate('scheme', scheme, 'string')
  vim.validate('resolver', resolver, 'function')
  ensure_builtins()
  scheme = scheme:lower():gsub(':$', '')
  if resolvers[scheme] and not (opts and opts.force) then
    error('Image resolver already registered for scheme: ' .. scheme, 2)
  end
  resolvers[scheme] = resolver
end

---@param scheme string
---@return LibImageResolver?
function M.unregister(scheme)
  ensure_builtins()
  scheme = scheme:lower():gsub(':$', '')
  local previous = resolvers[scheme]
  resolvers[scheme] = nil
  return previous
end

---@param input string|LibImageSource
---@param context table
---@param config LibImageConfig
---@param callback fun(source: LibImageSource?, err: string?)
---@return table?
function M.resolve(input, context, config, callback)
  ensure_builtins()
  if type(input) == 'table' then
    if input.path or input.data then
      notify_callback(callback, vim.deepcopy(input), nil)
    else
      notify_callback(callback, nil, 'Image source table requires `path` or `data`')
    end
    return nil
  end
  if type(input) ~= 'string' or input == '' then
    notify_callback(callback, nil, 'Image source must be a non-empty path, URI, or source table')
    return nil
  end
  local scheme = (scheme_of(input) or 'file'):lower()
  local resolver = resolvers[scheme]
  if not resolver then
    notify_callback(callback, nil, 'No image resolver registered for scheme: ' .. scheme)
    return nil
  end
  return resolver(input, context, config, function(source, err)
    -- Resolver authors may complete synchronously. Always cross a schedule
    -- boundary so session handle assignment and cancellation remain ordered.
    notify_callback(callback, source, err)
  end)
end

---@param input string|LibImageSource
---@param config LibImageConfig
---@param explicit? boolean
---@return boolean
function M.can_preview(input, config, explicit)
  if type(input) == 'table' then
    return input.path ~= nil or input.data ~= nil
  end
  if type(input) ~= 'string' or input == '' then
    return false
  end
  local scheme = (scheme_of(input) or 'file'):lower()
  ensure_builtins()
  if not resolvers[scheme] then
    return false
  end
  if explicit then
    return true
  end
  local ext = extension(input)
  return ext ~= nil and vim.tbl_contains(config.auto_preview.extensions, ext)
end

function M.schemes()
  ensure_builtins()
  local schemes = vim.tbl_keys(resolvers)
  table.sort(schemes)
  return schemes
end

function M.extension(input)
  return type(input) == 'string' and extension(input) or nil
end

return M
