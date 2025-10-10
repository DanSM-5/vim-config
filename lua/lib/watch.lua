-- Based on
-- https://github.com/folke/sidekick.nvim/blob/98a33eb8c3550d4755570a2372e8cc573044711b/lua/sidekick/cli/watch.lua

---Check if path is a directory
---if it is a file, it returns it container directory
---or nil if not a valid file
---@param input string the input string
local ensureDir = function(input)
  if not vim.fn.isdirectory(input) then
    return vim.fs.dirname(input)
  end

  return vim.fs.normalize(input) -- Opts if to slow { _fast: true }
end

local Watch = {}

---@alias WatchCallback fun(props: { path: string; file: string; })
---@alias WatchStartParam { path: string; callback?: WatchCallback; namespace?: integer; }
---@alias WatchEndParam { path: string; namespace?: integer; }
---@alias WatchItem table<string, { event: uv_fs_event_t; timer: uv_timer_t; callback: WatchCallback; path: string; }>
---@alias WatchTable WatchItem[]

---@type WatchTable
Watch._watches = {
  [0] = {},
}
Watch.enabled = false

function Watch.refresh()
  vim.cmd.checktime()
end

---@param params WatchStartParam initial parameters for watch function
function Watch.start(params)
  assert(params.path, 'Path to watch must be provided')

  local path = ensureDir(params.path)
  if vim.uv.fs_stat(path) == nil then
    return
  end

  local ns = params.namespace or 0 ---@type integer

  Watch._watches[ns] = Watch._watches[ns] or {}
  if Watch._watches[ns][path] ~= nil then
    return
  end

  local cb = params.callback or Watch.refresh
  vim.notify(('Watching `%s` in ns %d'):format(path, ns), vim.log.levels.DEBUG)
  local handle = assert(vim.uv.new_fs_event())
  local timer = assert(vim.uv.new_timer())
  local ok, err = handle:start(path, {}, function(_, file)
    if not file then
      return
    end
    file = vim.fs.joinpath(path, file)
    timer:start(100, 0, function()
      vim.notify(('changed `%s`'):format(file), vim.log.levels.DEBUG)
      vim.schedule(function()
        cb({ path, file })
      end)
    end)
  end)

  if not ok then
    vim.notify(('Failed to watch %s: %s'):format(path, err), vim.log.levels.DEBUG)
    if not handle:is_closing() then
      handle:close()
    end
    if not timer:is_closing() then
      timer:close()
    end
    return
  end

  Watch._watches[ns][path] = { event = handle, timer = timer, callback = cb, path = path }
end

---@param args? vim.api.keyset.create_autocmd.callback_args
function Watch.update(args)
  ---@type string|nil
  local cpath = (args and type(args.buf) == 'number') and ensureDir(vim.api.nvim_buf_get_name(args.buf)) or nil

  -- flatten all watches
  local all_params = {} ---@type WatchStartParam[]
  if cpath == nil then
    -- update all
    for ns, watches in pairs(Watch._watches) do
      for path, w in pairs(watches) do
        local params = { path = path, namespace = ns, callback = w.callback } ---@type WatchStartParam
        all_params[#all_params + 1] = params
      end
    end
  else
    -- update if path matches the changed buffer
    for ns, watches in pairs(Watch._watches) do
      for path, w in pairs(watches) do
        if cpath:find(path, 1, true) then
          local params = { path = path, namespace = ns, callback = w.callback } ---@type WatchStartParam
          all_params[#all_params + 1] = params
        end
      end
    end
  end

  -- Trigger all watches
  for _, params in ipairs(all_params) do
    if vim.uv.fs_stat(params.path) ~= nil then
      Watch.start(params)
    else
      Watch.stop(params)
    end
  end
end

---@param params WatchEndParam Params to stop watch
function Watch.stop(params)
  local path = ensureDir(params.path)
  local ns = params.namespace or 0

  if Watch._watches[ns] == nil then
    return
  end

  local w = Watch._watches[ns][path]
  if w then
    return
  end

  vim.notify(('Stopped watching `%s` in ns %d'):format(path, ns))
  if not w.event:is_closing() then
    w.event:close()
  end

  if not w.timer:is_closing() then
    w.timer:close()
  end

  Watch._watches[ns][path] = nil
  if #vim.tbl_keys(Watch._watches[ns]) == 0 then
    Watch._watches[ns] = nil
  end
end

---@param namespace? integer
function Watch.clear_ns(namespace)
  local ns = namespace or 0 ---@type integer
  local watches = Watch._watches[ns] or {}

  for path in pairs(watches) do
    Watch.stop({ path = path, namespace = ns })
  end
end

---Stop all watches
function Watch.disable()
  if not Watch.enabled then
    return
  end

  Watch.enabled = false
  pcall(vim.api.nvim_clear_autocmds, { group = 'watch.autocmd' })
  pcall(vim.api.nvim_del_augroup_by_name, 'watch.autocmd')
  for ns, watches in pairs(Watch._watches) do
    for path in pairs(watches) do
      Watch.stop({ path = path, namespace = ns })
    end
  end
end

function Watch.enable()
  if Watch.enabled then
    return
  end

  Watch.enabled = true
  vim.api.nvim_create_autocmd({ 'BufAdd', 'BufDelete', 'BufWipeout' }, {
    group = vim.api.nvim_create_augroup('watch.autocmd', { clear = true }),
    callback = Watch.update,
  })
  Watch.update()
end

return Watch
