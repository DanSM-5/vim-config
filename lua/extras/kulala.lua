local server_name = 'kulala_ls'
local group_autocmd_name = 'LoadKulala'
local loaded = false
local registered = false
local load_group = vim.api.nvim_create_augroup(group_autocmd_name, { clear = true })

---Get Spec table
---@return LazyPluginSpec
local get_spec = function ()
  return {
    'mistweaverco/kulala.nvim',
    ft = { 'http' },
    cmd = {
      'KulalaRun',
      'KulalaRunAll',
      'KulalaReplay',
      'KulalaInspect',
      'KulalaShowStats',
      'KulalaScratchpad',
      'KulalaCopy',
      'KulalaClose',
      'KulalaToggleView',
      'KulalaSearch',
      'KulalaPrev',
      'KulalaNext',
      'KulalaScriptsClearGlobal',
      'KulalaEnvGet',
      'KulalaEnvSet',
      'KulalaDownloadGQL',
      'KulalaClearCache',
    },
    config = function ()
      require('config.nvim_kulala').setup()
    end
  }
end

---@class extras.KulalaResetModule
---@field loaded? boolean
---@field registered? boolean

---Set the module state manually
---For debug only
---@param opts? extras.KulalaResetModule
local set_module_state = function (opts)
  opts = opts or {}

  if opts.registered ~= nil then
    registered = opts.registered
  end

  if opts.loaded ~= nil then
    loaded = opts.loaded
  end
end

local load_plugins = function ()
  if loaded then
    return
  end

  loaded = true

  local has_kulala = pcall(require, 'kulala')
  if has_kulala then
    vim.notify('[Kulala] Already loaded', vim.log.levels.DEBUG)
    return
  end

  -- Spec table
  ---@type LazyPluginSpec
  local kulala_spec = get_spec()

  -- Need to add the plugin.
  -- This is a bit involved because lazy.nvim creates
  -- its own structure on top of the LazySpec table
  local config = require('lazy.core.config')
  if type(config.options.spec) == 'table' then
    table.insert(config.options.spec --[[@as table]], kulala_spec)
  end

  -- Parse spec into plugin
  config.spec:parse(kulala_spec)

  -- copy state. Hope if doesn't break 🫠
  local existing = config.plugins
  config.plugins = config.spec.plugins
  for name, plugin in pairs(existing) do
    if config.plugins[name] then
      local new_state = config.plugins[name]._
      config.plugins[name]._ = plugin._
      config.plugins[name]._.dep = new_state.dep
      config.plugins[name]._.frags = new_state.frags
      config.plugins[name]._.pkg = new_state.pkg
    end
  end

  local plugin = config.plugins['kulala.nvim']

  if plugin == nil then
    vim.notify('[Kulala] plugin not installed *', vim.log.levels.DEBUG)
    return
  end

  -- if plugin.init then
  --   plugin.init(plugin)
  --   vim.notify('Init pluging ?', vim.log.levels.INFO)
  -- end

  -- Now we can install and load the plugin :)
  -- This should not be that hard 😅
  local lazy = require('lazy')

  lazy.install({
    wait = true,
    show = false,
    clear = false,
    plugins = {
      plugin,
    },
  })

  local buf = vim.api.nvim_get_current_buf()
  local filetype = vim.api.nvim_get_option_value('filetype', {
    buf = buf,
  })

  if filetype ~= 'http' then
    return
  end

  -- If something went wrong, we should not be able to get the
  -- plugin again from the config.
  plugin = config.plugins['kulala.nvim']

  if plugin == nil then
    vim.notify('[Kulala] plugin not installed', vim.log.levels.DEBUG)
    return
  end

  lazy.load({ plugins = { plugin }, wait = true })
  -- require('config.nvim_kulala').set_keymaps({ buf = buf })
end

local register_servers = function ()
  if registered or vim.fn.executable('kulala-ls') == 0 then
    return
  end

  registered = true

  ---@type vim.lsp.Client[]
  local clients = vim.lsp.get_clients({ name = server_name })
  if #clients > 0 then
    vim.notify('[Lsp] Kulala_ls is already active', vim.log.levels.INFO)
    return
  end

  local lsp_handler = require('lsp-servers.lsp_settings')
    .get_lsp_handler()
  lsp_handler('kulala_ls')

  local filetype = vim.api.nvim_get_option_value('filetype', {
    buf = vim.api.nvim_get_current_buf()
  })

  if filetype == 'http' then
    vim.notify('[Lsp] Starting kulala_ls', vim.log.levels.INFO)
    vim.cmd.LspStart('kulala_ls')
  end
end

local setup = function ()
  load_plugins()
  register_servers()
end

local set_autocmds = function ()
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'http',
    once = true,
    group = load_group,
    callback = function ()
      setup()
    end,
  })
end

local set_commands = function ()
  vim.api.nvim_create_user_command('KulalaLoad', function ()
    -- Clear autocmd
    load_group = vim.api.nvim_create_augroup(group_autocmd_name, { clear = true })
    setup()
  end, {
    bar = true,
    desc = '[Kulala] Start kulala'
  })
end

return {
  setup = setup,
  load_plugins = load_plugins,
  register_servers = register_servers,
  set_autocmds = set_autocmds,
  set_commands = set_commands,
  set_module_state = set_module_state,
  get_spec = get_spec,
}
