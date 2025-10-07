---@class (exact) ts.mod.fold_ui.Config: ts.mod.module.Config

---@class ts.mod.fold_ui: ts.mod.Module
---@field private config ts.mod.fold_ui.Config
local Module = {}

---@type ts.mod.fold_ui.Config
Module.config = {
  enable = false,
  disable = false,
}

---@private
---@type table<integer, string>
Module.methods = {}

---@private
---@type table<integer, string>
Module.expressions = {}

---Called from state on setup
---@param config ts.mod.fold_ui.Config
function Module.setup(config)
  Module.config = config
end

---@return string
function Module.name()
  return 'fold_ui'
end

---@param ctx ts.mod.Context
---@return boolean
function Module.enabled(ctx)
  local util = require('treesitter-modules.lib.util')
  return util.enabled(Module.config, ctx)
end

---@param ctx ts.mod.Context
function Module.attach(ctx)
  require('extras.ts_custom_folding')
  vim.opt_local.foldtext = 'v:lua.custom_foldtext()'
end

---@param ctx ts.mod.Context
function Module.detach(ctx)
  vim.opt_local.foldtext = vim.go.foldtext
end

return Module
