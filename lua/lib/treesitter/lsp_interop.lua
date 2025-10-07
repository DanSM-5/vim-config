---Make function dot repeatable for the peek definition module
---@generic T
---@param fn T
---@return T
local function make_dot_repeatable(fn)
  return function()
    _G._peek_definition_last_function = fn
    vim.o.opfunc = "v:lua._peek_definition_last_function"
    vim.api.nvim_feedkeys("g@l", "n", false)
  end
end

-- peeking is not interruptive so it is okay to use in visual mode.
-- in fact, visual mode peeking is very helpful because you may not want
-- to jump to the definition.
local nx_mode_functions = {
  peek_definition_code = '[TSModule] Show the definition of the query provided',
}


---@class (exact) ts.mod.fold.Config: ts.mod.module.Config
---@field data { keymap_modes: string|string[]; keymaps_per_buf: table<string, string>; dot_repeatable: boolean; floating_preview_opts?: vim.lsp.util.open_floating_preview.Opts }

---@class ts.mod.Fold: ts.mod.Module
---@field config ts.mod.fold.Config
local Module = {}

---@type ts.mod.fold.Config
Module.config = {
  enable = false,
  disable = false,
  data = {}
}

---@private
---@type table<integer, string>
Module.methods = {}

---@private
---@type table<integer, string>
Module.expressions = {}

---called from state on setup
---@param config ts.mod.fold.Config
function Module.setup(config)
  Module.config = config
end

---@return string
function Module.name()
  return 'lsp_interop'
end


---@param ctx ts.mod.Context
---@return boolean
function Module.enabled(ctx)
  local util = require('treesitter-modules.lib.util')
  return util.enabled(Module.config, ctx)
end

---@param ctx ts.mod.Context
function Module.attach(ctx)
  local keymap_modes = Module.config.data.keymap_modes or { 'n' }
  if type(keymap_modes) == "string" then
    keymap_modes = { keymap_modes }
  elseif type(keymap_modes) ~= "table" then
    keymap_modes = { "n" }
  end

  local keymaps_per_buf = Module.config.data.keymaps_per_buf or {}
  local dot_repeatable = Module.config.data.dot_repeatable or false

  for function_call, function_description in pairs(nx_mode_functions) do
    for mapping, query_metadata in pairs(keymaps_per_buf or {}) do
      local mapping_description, query, query_group

      if type(query_metadata) == "table" then
        query = query_metadata.query
        query_group = query_metadata.query_group or "textobjects"
        mapping_description = query_metadata.desc
      else
        query = query_metadata
        query_group = "textobjects"
        mapping_description = function_description .. " " .. query_metadata
      end

      local fn = function()
        require('extras.ts_lsp_interop').peek_definition_code(query, query_group)
      end
      if dot_repeatable then
        fn = make_dot_repeatable(fn)
      end

      pcall(
        vim.keymap.set,
        keymap_modes,
        mapping,
        fn,
        { buffer = ctx.buf, silent = true, noremap = true, desc = mapping_description }
      )
    end
  end
end

---@param ctx ts.mod.Context
function Module.detach(ctx)
  local buf = ctx.buf or vim.api.nvim_get_current_buf()
  local keymaps_per_buf = Module.config.data.keymaps_per_buf or {}
  local keymap_modes = Module.config.data.keymap_modes or { 'n' }
  if type(keymap_modes) == "string" then
    keymap_modes = { keymap_modes }
  elseif type(keymap_modes) ~= "table" then
    keymap_modes = { "n" }
  end

  for mapping, query_metadata in pairs(keymaps_per_buf or {}) do
     -- Even if it fails make it silent
    pcall(vim.keymap.del, keymap_modes, mapping, { buffer = buf })
  end
end


return Module
