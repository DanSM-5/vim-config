local M = {}

local cached
local pending = {}
local query_started = false

local function finish(width, height)
  if cached then
    return
  end
  cached = { width = width, height = height }
  query_started = false
  local callbacks = pending
  pending = {}
  for _, callback in ipairs(callbacks) do
    callback(cached.width, cached.height)
  end
end

---Get the terminal cell dimensions without blocking Neovim's main loop.
---@param config LibImageConfig
---@param callback fun(width: number, height: number)
function M.cell_size(config, callback)
  if cached then
    callback(cached.width, cached.height)
    return
  end
  if #vim.api.nvim_list_uis() == 0 then
    cached = {
      width = config.renderer.fallback_cell_width,
      height = config.renderer.fallback_cell_height,
    }
    callback(cached.width, cached.height)
    return
  end
  table.insert(pending, callback)
  if query_started then
    return
  end
  query_started = true

  local cell_width, cell_height
  local screen_width, screen_height
  local autocmd
  local timer = vim.uv.new_timer()

  local function complete()
    if autocmd then
      pcall(vim.api.nvim_del_autocmd, autocmd)
      autocmd = nil
    end
    if timer then
      timer:stop()
      timer:close()
      timer = nil
    end
    if not cell_width and screen_width and vim.o.columns > 0 and vim.o.lines > 0 then
      cell_width = screen_width / vim.o.columns
      cell_height = screen_height / vim.o.lines
    end
    finish(cell_width or config.renderer.fallback_cell_width, cell_height or config.renderer.fallback_cell_height)
  end

  autocmd = vim.api.nvim_create_autocmd('TermResponse', {
    callback = function()
      local response = vim.v.termresponse or ''
      local height, width = response:match('\27%[6;(%d+);(%d+)t')
      if width and height and tonumber(width) > 0 and tonumber(height) > 0 then
        cell_width, cell_height = tonumber(width), tonumber(height)
        complete()
        return
      end
      height, width = response:match('\27%[4;(%d+);(%d+)t')
      if width and height and tonumber(width) > 0 and tonumber(height) > 0 then
        screen_width, screen_height = tonumber(width), tonumber(height)
      end
    end,
  })

  timer:start(config.renderer.terminal_query_timeout, 0, vim.schedule_wrap(complete))
  vim.fn.chansend(vim.v.stderr, '\27[16t\27[14t')
end

function M.reset()
  cached = nil
end

return M
