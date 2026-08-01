local backend_registry = require('lib.image.backend')
local config_store = require('lib.image.config')
local converter = require('lib.image.converter')
local layout_manager = require('lib.image.layout')
local source_manager = require('lib.image.source')
local terminal = require('lib.image.terminal')

local M = {}

local generation = 0
local active

local function valid(request)
  return active == request and request.id == generation
end

local function stop(handle)
  if not handle then
    return
  end
  if type(handle.cancel) == 'function' then
    pcall(handle.cancel, handle)
  elseif type(handle.kill) == 'function' then
    pcall(handle.kill, handle, 15)
  end
end

local function notify(request, message, level)
  if request.opts.notify == false or not request.config.notify then
    return
  end
  vim.notify(message, level or vim.log.levels.ERROR, { title = 'Image preview' })
end

local function cleanup(request)
  stop(request.handle)
  request.handle = nil
  if request.resolved and request.resolved.cleanup then
    pcall(request.resolved.cleanup)
    request.resolved.cleanup = nil
  end
end

local function show_error(bufnr, message)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  local modifiable = vim.bo[bufnr].modifiable
  local readonly = vim.bo[bufnr].readonly
  vim.bo[bufnr].modifiable = true
  vim.bo[bufnr].readonly = false
  local lines = { 'Image preview failed:' }
  vim.list_extend(lines, vim.split(message, '\n', { plain = true, trimempty = true }))
  pcall(vim.api.nvim_buf_set_lines, bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = modifiable
  vim.bo[bufnr].readonly = readonly
end

local function fail(request, message)
  if not valid(request) then
    return
  end
  request.error = message
  request.phase = 'error'
  cleanup(request)
  if request.layout then
    request.backend.clear()
    if request.layout.owned_win then
      layout_manager.close(request.layout)
      request.layout = nil
    else
      show_error(request.layout.bufnr, message)
    end
  elseif request.opts.target then
    show_error(request.opts.target.bufnr, message)
  end
  notify(request, message)
end

local function map_close_keys(request)
  local layout = request.layout
  if not layout or not layout.bufnr or not vim.api.nvim_buf_is_valid(layout.bufnr) then
    return
  end
  for _, key in ipairs(request.config.layout.close_keys) do
    vim.keymap.set('n', key, M.close, {
      buffer = layout.bufnr,
      nowait = true,
      silent = true,
      desc = 'Close image preview',
    })
  end
end

local function draw(request)
  if not valid(request) or not request.encoded or not request.layout then
    return false
  end
  request.backend.clear()
  return request.backend.draw(request.encoded, request.layout)
end

---@param input string|LibImageSource
---@param opts? LibImagePreviewOpts
---@return LibImagePreviewResult
function M.preview(input, opts)
  opts = vim.deepcopy(opts or {})
  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return { handled = false, error = 'Invalid source buffer' }
  end
  local config = config_store.get(bufnr)
  local explicit = opts.explicit ~= false
  if not source_manager.can_preview(input, config, explicit) then
    return { handled = false, error = 'The source is not an enabled image preview type' }
  end
  local backend, backend_err = backend_registry.select(config)
  if not backend then
    if opts.notify ~= false and config.notify then
      vim.notify(backend_err, vim.log.levels.ERROR, { title = 'Image preview' })
    end
    return { handled = true, error = backend_err }
  end

  M.close()
  local request = {
    id = generation,
    input = input,
    opts = opts,
    config = config,
    backend = backend,
    phase = 'resolving',
  }
  active = request

  local buffer_name = vim.api.nvim_buf_get_name(bufnr)
  local base_dir = buffer_name ~= '' and vim.fs.dirname(buffer_name) or vim.fn.getcwd()
  request.handle = source_manager.resolve(input, { bufnr = bufnr, base_dir = base_dir }, config, function(source, err)
    if not valid(request) then
      if source and source.cleanup then
        source.cleanup()
      end
      return
    end
    request.handle = nil
    if err or not source then
      fail(request, err or 'Unable to resolve image source')
      return
    end
    request.resolved = source
    request.phase = 'converting'
    request.handle = converter.normalize(source, config, function(image, convert_err)
      if not valid(request) then
        return
      end
      request.handle = nil
      if convert_err or not image then
        fail(request, convert_err or 'Unable to convert source to an image')
        return
      end
      request.image = image
      request.phase = 'layout'
      terminal.cell_size(config, function(cell_width, cell_height)
        if not valid(request) then
          return
        end
        request.cell_width = cell_width
        request.cell_height = cell_height
        local target = opts.target or { kind = config.layout.default }
        local layout, layout_err = layout_manager.open(target, source, image, cell_width, cell_height, config)
        if not layout then
          fail(request, layout_err or 'Unable to open image preview layout')
          return
        end
        if not valid(request) then
          layout_manager.close(layout)
          return
        end
        request.layout = layout
        map_close_keys(request)
        request.phase = 'encoding'
        request.handle = backend.encode(
          image.data,
          layout,
          cell_width,
          cell_height,
          config,
          function(encoded, encode_err)
            vim.schedule(function()
              if not valid(request) then
                return
              end
              request.handle = nil
              if encode_err or not encoded then
                fail(request, encode_err or 'Unable to encode image for the terminal')
                return
              end
              request.encoded = encoded
              request.phase = 'ready'
              draw(request)
            end)
          end
        )
      end)
    end)
  end)

  return { handled = true, id = request.id }
end

function M.close()
  generation = generation + 1
  local request = active
  active = nil
  if not request then
    return
  end
  cleanup(request)
  request.backend.clear()
  layout_manager.close(request.layout)
end

---@param opts? { resize?: boolean }
function M.redraw(opts)
  local request = active
  if not request then
    return false
  end
  if opts and opts.resize and request.phase == 'ready' then
    local input = request.input
    local preview_opts = request.opts
    M.preview(input, preview_opts)
    return true
  end
  return draw(request)
end

---@param bufnr integer
function M.close_for_buffer(bufnr)
  if active and (active.opts.bufnr == bufnr or active.layout and active.layout.bufnr == bufnr) then
    M.close()
  end
end

function M.status()
  if not active then
    return { active = false, generation = generation }
  end
  return {
    active = true,
    id = active.id,
    phase = active.phase,
    error = active.error,
    source = active.resolved and (active.resolved.path or active.resolved.uri or active.resolved.name) or active.input,
    source_bufnr = active.opts.bufnr,
    backend = active.backend.name,
    winid = active.layout and active.layout.winid or nil,
    bufnr = active.layout and active.layout.bufnr or nil,
  }
end

return M
