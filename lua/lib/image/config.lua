local M = {}

local is_windows = vim.fn.has('win32') == 1

---@type LibImageConfig
local defaults = {
  backend = 'auto',
  notify = true,
  markdown = {
    filetypes = { 'markdown', 'markdown.mdx', 'mdx' },
    html = true,
    reference_links = true,
  },
  auto_preview = {
    enabled = true,
    extensions = {
      'apng',
      'avif',
      'bmp',
      'gif',
      'heic',
      'heif',
      'ico',
      'jpeg',
      'jpg',
      'jxl',
      'pbm',
      'pgm',
      'png',
      'pnm',
      'ppm',
      'qoi',
      'svg',
      'tga',
      'tif',
      'tiff',
      'webp',
      'pdf',
      'avi',
      'm4v',
      'mkv',
      'mov',
      'mp4',
      'mpeg',
      'mpg',
      'webm',
      'wmv',
    },
  },
  layout = {
    default = 'float',
    close_keys = { 'q', '<Esc>' },
    float = {
      max_width = 0.8,
      max_height = 0.8,
      border = 'rounded',
      title = true,
      title_pos = 'center',
      zindex = 60,
    },
    preview = {
      height = 0.35,
      vertical = false,
      width = 0.4,
    },
  },
  renderer = {
    terminal_query_timeout = 250,
    fallback_cell_width = 10,
    fallback_cell_height = 20,
    sixel = {
      command = 'chafa',
      work = 5,
    },
  },
  conversion = {
    mcat = 'mcat',
    ffmpeg = 'ffmpeg',
    ghostscript = is_windows and 'gswin64c' or 'gs',
    libreoffice = 'soffice',
    max_input_bytes = 256 * 1024 * 1024,
    timeout = 30 * 1000,
    video_seek = 1,
  },
  remote = {
    enabled = true,
    curl = 'curl',
    timeout = 20,
    max_bytes = 64 * 1024 * 1024,
    schemes = { 'http', 'https' },
  },
}

---@type LibImageConfig
local configured = vim.deepcopy(defaults)

local function is_list(value)
  return type(value) == 'table' and vim.islist(value)
end

---@param base table
---@param override table
---@return table
local function merge(base, override)
  local result = vim.deepcopy(base)
  for key, value in pairs(override) do
    if type(value) == 'table' and type(result[key]) == 'table' and not is_list(value) and not is_list(result[key]) then
      result[key] = merge(result[key], value)
    else
      result[key] = vim.deepcopy(value)
    end
  end
  return result
end

---@param value unknown
---@param name string
local function validate_override(value, name)
  if value ~= nil and type(value) ~= 'table' then
    error(('%s must be a table, got %s'):format(name, type(value)), 3)
  end
end

---Merge values into the internal runtime configuration.
---Lists replace lists; map-like tables merge recursively.
---@param opts? table
---@return LibImageConfig
function M.configure(opts)
  validate_override(opts, 'image config')
  if opts then
    configured = merge(configured, opts)
  end
  return vim.deepcopy(configured)
end

---Reset only the internal runtime configuration to its immutable defaults.
---`g:lib_image_config` and `b:lib_image_config` are intentionally untouched.
---@return LibImageConfig
function M.restore()
  configured = vim.deepcopy(defaults)
  return vim.deepcopy(configured)
end

---Return a copy of the immutable defaults.
---@return LibImageConfig
function M.defaults()
  return vim.deepcopy(defaults)
end

---Resolve the effective configuration for a buffer.
---Priority is internal config, then `g:lib_image_config`, then `b:lib_image_config`.
---@param bufnr? integer
---@return LibImageConfig
function M.get(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local result = vim.deepcopy(configured)
  local global_override = vim.g.lib_image_config
  validate_override(global_override, 'g:lib_image_config')
  if global_override then
    result = merge(result, global_override)
  end
  if vim.api.nvim_buf_is_valid(bufnr) then
    local buffer_override = vim.b[bufnr].lib_image_config
    validate_override(buffer_override, 'b:lib_image_config')
    if buffer_override then
      result = merge(result, buffer_override)
    end
  end
  return result
end

return M
