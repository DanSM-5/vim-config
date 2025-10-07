---@class (exact) ts.mod.diagnostics.Config: ts.mod.module.Config

---@class ts.mod.diagnostics: ts.mod.Module
---@field private config ts.mod.diagnostics.Config
local Module = {}

---@type ts.mod.diagnostics.Config
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
---@param config ts.mod.diagnostics.Config
function Module.setup(config)
  Module.config = config
end

---@return string
function Module.name()
  return 'diagnostics'
end

---@param ctx ts.mod.Context
---@return boolean
function Module.enabled(ctx)
  local util = require('treesitter-modules.lib.util')
  return util.enabled(Module.config, ctx)
end

---@param ctx ts.mod.Context
function Module.attach(ctx)
  require('extras.ts_diagnostics').start(ctx.buf)
end

---@param ctx ts.mod.Context
function Module.detach(ctx)
  require('extras.ts_diagnostics').stop(ctx.buf)
end

return Module
