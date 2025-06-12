---@module 'lazy'

-- PERF: optimized code to get package name without using lua patterns
---@param pkg string
---@return string
local get_name = function(pkg)
  local name = pkg:sub(-4) == '.git' and pkg:sub(1, -5) or pkg
  name = name:sub(-1) == '/' and name:sub(1, -2) or name
  local slash = name:reverse():find('/', 1, true) --[[@as number?]]
  return slash and name:sub(#name - slash + 2) or pkg:gsub('%W+', '_')
end

---Infer name from the spec
---[Ref](https://github.com/folke/lazy.nvim/blob/6c3bda4aca61a13a9c63f1c1d1b16b9d3be90d7a/lua/lazy/core/fragments.lua#L85)
---@param spec LazyPluginSpec
---@return string
local get_spec_name = function(spec)
  ---@type string
  local name, url

  -- short url / ref
  if spec[1] then
    local slash = spec[1]:find('/', 1, true)
    if slash then
      local prefix = spec[1]:sub(1, 4)
      if prefix == 'http' or prefix == 'git@' then
        url = spec.url or spec[1]
      else
        local config = require('lazy.core.config')
        name = spec.name or spec[1]:sub(slash + 1)
        url = spec.url or config.options.git.url_format:format(spec[1])
      end
    else
      name = spec.name or spec[1] --[[@as string]]
    end
  end

  -- name
  name = name
    or spec.name --[[@as string]]
    or (url and get_name(url))
    or (spec.dir and get_name(spec.dir))

  return name
end
---Dynamically register a plugin spec in lazy.nvim
---@param specs LazyPluginSpec[]
local lazy_add = function(specs)
  -- This is a bit involved because lazy.nvim creates
  -- its own structure on top of the LazyPluginSpec
  local config = require('lazy.core.config')
  if type(config.options.spec) == 'table' then
    -- Append new specs
    table.insert(config.options.spec --[[@as table]], vim.deepcopy(specs))
  end

  -- Parse spec into plugin
  -- Ref: https://github.com/folke/lazy.nvim/blob/6c3bda4aca61a13a9c63f1c1d1b16b9d3be90d7a/lua/lazy/core/plugin.lua#L318
  -- Makes lazy load the plugin spec with the new specs attached
  require('lazy.core.plugin').load()
end

---Dynamically load a plugin in lazy.nvim
---@param specs LazyPluginSpec[]
---@return LazyPlugin[]
local lazy_install = function(specs)
  ---@type LazyPlugin[]
  local plugins = {}
  local config = require('lazy.core.config')

  for _, spec in ipairs(specs) do
    ---@type string
    local name = get_spec_name(spec)
    ---@type LazyPlugin|nil
    local pluginSpec = config.plugins[name]
    if pluginSpec then
      -- Add handlers for plugin
      -- keys, event, cmd, ft
      -- Ref: https://github.com/folke/lazy.nvim/blob/6c3bda4aca61a13a9c63f1c1d1b16b9d3be90d7a/lua/lazy/core/handler/init.lua#L31
      require('lazy.core.handler').enable(pluginSpec)
      table.insert(plugins, pluginSpec)
    end
  end

  -- Now we can install and load the plugin :)
  -- This should not be this hard 😅
  ---@type Lazy
  local lazy = require('lazy')
  ---@type ManagerOpts
  local install_opts = {
    wait = true,
    show = false,
    clear = false,
    plugins = plugins,
  }

  lazy.install(install_opts)
  return plugins
end

---@param specs LazyPluginSpec[]|LazyPlugin[]
local lazy_load = function(specs)
  if #specs == 0 then
    return
  end

  ---@type LazyPlugin[]
  local plugins = {}

  if specs[1]._ then
    plugins = specs --[[@as LazyPlugin]]
  else
    for _, spec in
      ipairs(specs --[[@as LazyPluginSpec[] ]])
    do
      ---@type string
      local name = get_spec_name(spec)
      local config = require('lazy.core.config')
      ---@type LazyPlugin|nil
      local pluginSpec = config.plugins[name]
      if pluginSpec then
        table.insert(plugins, pluginSpec)
      end
    end
  end

  -- Load plugins
  local lazy = require('lazy')
  lazy.load({ plugins = plugins, wait = true })
end

---Add plugins dynamically to lazy.nvim
---@param specs LazyPluginSpec[]
---@param condition fun(plugins: LazyPlugin[]): boolean
local lazy_register = function(specs, condition)
  lazy_add(specs)
  local plugins = lazy_install(specs)
  if condition(plugins) then
    lazy_load(plugins)
  end
end

return {
  lazy_add = lazy_add,
  lazy_install = lazy_install,
  lazy_load = lazy_load,
  lazy_register = lazy_register,
}
