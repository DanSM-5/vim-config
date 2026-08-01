local M = {}

---@class LibImageProcessHandle
---@field kill fun(self: LibImageProcessHandle, signal?: integer|string)

---@param argv string[]
---@param opts? vim.SystemOpts
---@param callback fun(result: vim.SystemCompleted)
---@return vim.SystemObj?
function M.run(argv, opts, callback)
  local ok, handle = pcall(vim.system, argv, opts or {}, function(result)
    vim.schedule(function()
      callback(result)
    end)
  end)
  if not ok then
    vim.schedule(function()
      callback({ code = -1, signal = 0, stdout = '', stderr = tostring(handle) })
    end)
    return nil
  end
  return handle
end

---@param path string
---@param max_bytes integer
---@param callback fun(data: string?, err: string?)
function M.read_file(path, max_bytes, callback)
  vim.uv.fs_stat(path, function(stat_err, stat)
    if stat_err or not stat or stat.type ~= 'file' then
      vim.schedule(function()
        callback(nil, stat_err and tostring(stat_err) or ('Not a regular file: ' .. path))
      end)
      return
    end
    if stat.size > max_bytes then
      vim.schedule(function()
        callback(nil, ('Input exceeds configured limit (%d bytes): %s'):format(max_bytes, path))
      end)
      return
    end
    vim.uv.fs_open(path, 'r', 438, function(open_err, fd)
      if open_err or not fd then
        vim.schedule(function()
          callback(nil, tostring(open_err or ('Unable to open ' .. path)))
        end)
        return
      end
      vim.uv.fs_read(fd, stat.size, 0, function(read_err, data)
        vim.uv.fs_close(fd)
        vim.schedule(function()
          callback(data, read_err and tostring(read_err) or nil)
        end)
      end)
    end)
  end)
end

---@param path string
---@param data string
---@return boolean ok
---@return string? err
function M.write_file(path, data)
  local fd, open_err = vim.uv.fs_open(path, 'w', 384)
  if not fd then
    return false, tostring(open_err)
  end
  local written, write_err = vim.uv.fs_write(fd, data, 0)
  vim.uv.fs_close(fd)
  if not written then
    return false, tostring(write_err)
  end
  return true
end

---@param suffix? string
---@return string
function M.tempname(suffix)
  return vim.fn.tempname() .. (suffix or '')
end

---@param path string?
function M.unlink(path)
  if path and path ~= '' then
    pcall(vim.uv.fs_unlink, path)
  end
end

return M
