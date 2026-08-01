local config = require('lib.image.config')

local M = {}

---Update the internal runtime configuration without loading the preview stack.
---@param opts? table
---@return LibImageConfig
function M.config(opts)
  return config.configure(opts)
end

---Reset only the internal runtime configuration. Global and buffer-local
---overrides remain intact and continue to win during effective lookup.
---@return LibImageConfig
function M.restore()
  return config.restore()
end

---@return LibImageConfig
function M.defaults()
  return config.defaults()
end

---@param bufnr? integer
---@return LibImageConfig
function M.get_config(bufnr)
  return config.get(bufnr)
end

---@param input string|LibImageSource
---@param opts? LibImagePreviewOpts
---@return boolean
function M.can_preview(input, opts)
  opts = opts or {}
  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  return require('lib.image.source').can_preview(input, config.get(bufnr), opts.explicit)
end

---@param opts? { bufnr?: integer, row?: integer, column?: integer, generic?: boolean }
---@return LibImageResolvedCursor?
function M.resolve_at_cursor(opts)
  opts = opts or {}
  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  local resolved = require('lib.image.markdown').at_cursor(bufnr, opts.row, opts.column, config.get(bufnr))
  if not resolved and opts.generic then
    resolved = require('lib.image.markdown').generic_at_cursor()
  end
  return resolved
end

---@param opts? LibImagePreviewOpts
---@return LibImagePreviewResult
function M.preview_at_cursor(opts)
  opts = opts or {}
  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  local resolved = M.resolve_at_cursor({ bufnr = bufnr, row = opts.row, column = opts.column })
  if not resolved then
    return { handled = false }
  end
  local preview_opts = vim.tbl_extend('force', opts, { bufnr = bufnr, explicit = true })
  local result = require('lib.image.session').preview(resolved.target, preview_opts)
  if not result.handled then
    result.handled = true
    if result.error and preview_opts.notify ~= false and config.get(bufnr).notify then
      vim.notify(result.error, vim.log.levels.WARN, { title = 'Image preview' })
    end
  end
  return result
end

---@param input string|LibImageSource
---@param opts? LibImagePreviewOpts
---@return LibImagePreviewResult
function M.preview(input, opts)
  return require('lib.image.session').preview(input, opts)
end

local function preview_target(input, opts, target)
  opts = vim.deepcopy(opts or {})
  opts.target = vim.tbl_extend('force', opts.target or {}, target)
  return M.preview(input, opts)
end

---@param input string|LibImageSource
---@param opts? LibImagePreviewOpts
---@return LibImagePreviewResult
function M.preview_float(input, opts)
  return preview_target(input, opts, { kind = 'float' })
end

---@param input string|LibImageSource
---@param opts? LibImagePreviewOpts
---@return LibImagePreviewResult
function M.preview_tab(input, opts)
  return preview_target(input, opts, { kind = 'tab' })
end

---Preview in the standard reusable preview window used by `:PreviewImage?`.
---@param input string|LibImageSource
---@param opts? LibImagePreviewOpts
---@return LibImagePreviewResult
function M.preview_window(input, opts)
  return preview_target(input, opts, { kind = 'preview' })
end

---Preview in a caller-owned window, as used by Oil and Canola adapters.
---@param input string|LibImageSource
---@param winid integer
---@param opts? LibImagePreviewOpts
---@return LibImagePreviewResult
function M.preview_in_window(input, winid, opts)
  return preview_target(input, opts, { kind = 'window', winid = winid })
end

---Resolve a source without starting conversion or rendering. Temporary remote
---sources belong to the caller, which must invoke `source.cleanup()`.
---@param input string|LibImageSource
---@param opts? { bufnr?: integer }
---@param callback fun(source: LibImageSource?, err: string?)
---@return table? handle
function M.resolve_source(input, opts, callback)
  opts = opts or {}
  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(bufnr)
  local context = {
    bufnr = bufnr,
    base_dir = name ~= '' and vim.fs.dirname(name) or vim.fn.getcwd(),
  }
  return require('lib.image.source').resolve(input, context, config.get(bufnr), callback)
end

---Convert a resolved source to the backend-neutral PNG representation.
---@param source LibImageSource
---@param opts? { bufnr?: integer }
---@param callback fun(image: LibImageNormalizedImage?, err: string?)
---@return { cancel: fun() }
function M.normalize(source, opts, callback)
  opts = opts or {}
  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  return require('lib.image.converter').normalize(source, config.get(bufnr), callback)
end

---Close the single active preview session.
function M.close()
  return require('lib.image.session').close()
end

---@param opts? { resize?: boolean }
---@return boolean?
function M.redraw(opts)
  return require('lib.image.session').redraw(opts)
end

---@return LibImageStatus
function M.status()
  return require('lib.image.session').status()
end

---@param bufnr integer
function M.close_for_buffer(bufnr)
  return require('lib.image.session').close_for_buffer(bufnr)
end

---@param scheme string
---@param resolver LibImageResolver
---@param opts? { force?: boolean }
function M.register_resolver(scheme, resolver, opts)
  return require('lib.image.source').register(scheme, resolver, opts)
end

---@param scheme string
---@return LibImageResolver?
function M.unregister_resolver(scheme)
  return require('lib.image.source').unregister(scheme)
end

---@param name string
---@param backend LibImageBackend
---@param opts? { force?: boolean }
function M.register_backend(name, backend, opts)
  return require('lib.image.backend').register(name, backend, opts)
end

---@param name string
---@return LibImageBackend?
function M.unregister_backend(name)
  return require('lib.image.backend').unregister(name)
end

---@param bufnr? integer
---@return LibImageCapabilities
function M.capabilities(bufnr)
  local effective = config.get(bufnr)
  local function executable(command)
    return vim.fn.executable(command) == 1
  end
  local function parser(language)
    return pcall(vim.treesitter.get_string_parser, '', language)
  end
  return {
    neovim = vim.fn.has('nvim-0.12') == 1,
    backends = require('lib.image.backend').capabilities(effective),
    executables = {
      chafa = executable(effective.renderer.sixel.command),
      curl = executable(effective.remote.curl),
      ffmpeg = executable(effective.conversion.ffmpeg),
      ghostscript = executable(effective.conversion.ghostscript),
      libreoffice = executable(effective.conversion.libreoffice),
      mcat = executable(effective.conversion.mcat),
    },
    parsers = {
      html = parser('html'),
      markdown = parser('markdown'),
      markdown_inline = parser('markdown_inline'),
    },
    remote_schemes = require('lib.image.source').schemes(),
  }
end

return M
