---@module 'lazy'

local server_name = 'kulala_ls'
local group_autocmd_name = 'LoadKulala'
local loaded = false
local registered = false
local load_group = vim.api.nvim_create_augroup(group_autocmd_name, { clear = true })
local filetypes = {
  'http',
  'rest',
}

---Get Spec table
---@return LazyPluginSpec
local get_spec = function ()
  ---@type LazyPluginSpec
  return {
    'mistweaverco/kulala.nvim',
    tag = 'v5.2.1',
    ft = filetypes,
    cmd = {
      'Kulala',
      'KulalaFormat',
      'KulalaFormatAll',
      -- 'KulalaRun',
      -- 'KulalaRunAll',
      -- 'KulalaReplay',
      -- 'KulalaInspect',
      -- 'KulalaShowStats',
      -- 'KulalaScratchpad',
      -- 'KulalaCopy',
      -- 'KulalaFromCurl',
      -- 'KulalaClose',
      -- 'KulalaOpen',
      -- 'KulalaVersion',
      -- 'KulalaToggleView',
      -- 'KulalaSearch',
      -- 'KulalaPrev',
      -- 'KulalaNext',
      -- 'KulalaScriptsClearGlobal',
      -- 'KulalaEnvGet',
      -- 'KulalaEnvSet',
      -- 'KulalaDownloadGQL',
      -- 'KulalaClearCache',
    },
    config = function ()
      require('config.nvim_kulala').setup()
    end,
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

---Loads kulala.nvim on demand. This plays with the internals
---of lazy.nvim which may have issues on future versions.
---
---Ref: [Flow from Lazy](https://github.com/folke/lazy.nvim/blob/6c3bda4aca61a13a9c63f1c1d1b16b9d3be90d7a/lua/lazy/core/loader.lua#L37)
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
  -- Ref: https://github.com/folke/lazy.nvim/blob/6c3bda4aca61a13a9c63f1c1d1b16b9d3be90d7a/lua/lazy/core/plugin.lua#L318
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

  -- If god is on our side, the plugin should be now available here
  local kulala_nvim = config.plugins['kulala.nvim']

  if kulala_nvim == nil then
    vim.notify('[Kulala] plugin not installed', vim.log.levels.DEBUG)
    return
  end

  -- Implement handlers for lazy load
  -- keys, event, cmd, ft
  -- Ref: https://github.com/folke/lazy.nvim/blob/6c3bda4aca61a13a9c63f1c1d1b16b9d3be90d7a/lua/lazy/core/handler/init.lua#L31
  require('lazy.core.handler').enable(kulala_nvim)

  -- Now we can install and load the plugin :)
  -- This should not be that hard 😅
  local lazy = require('lazy')

  lazy.install({
    wait = true,
    show = false,
    clear = false,
    plugins = { kulala_nvim },
  })

  local buf = vim.api.nvim_get_current_buf()
  local filetype = vim.api.nvim_get_option_value('filetype', {
    buf = buf,
  })

  if not vim.tbl_contains(filetypes, filetype) then
    return
  end

  -- If something went wrong, we should not be able to get the
  -- plugin again from the config. 🙃
  kulala_nvim = config.plugins['kulala.nvim']

  if kulala_nvim == nil then
    vim.notify('[Kulala] plugin not installed', vim.log.levels.DEBUG)
    return
  end

  -- Finally, you did it 🙈
  lazy.load({ plugins = { kulala_nvim }, wait = true })
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

  if vim.tbl_contains(filetypes, filetype) then
    vim.notify('[Lsp] Starting kulala_ls', vim.log.levels.INFO)
    vim.cmd.LspStart('kulala_ls')
  end
end

local setup = function ()
  vim.notify('Loading Kulala plugin')

  -- Delete default command
  pcall(vim.api.nvim_del_user_command, 'Kulala')
  -- Clear autocmd
  load_group = vim.api.nvim_create_augroup(group_autocmd_name, { clear = true })

  load_plugins()
  -- register_servers()
end

local set_autocmds = function ()
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'http,rest',
    once = true,
    group = load_group,
    callback = function ()
      setup()
    end,
  })
end

local set_commands = function ()
  vim.api.nvim_create_user_command('Kulala', function (opts)
    if opts.fargs[1] == 'load' or opts.bang then
      setup()
      return
    end

    if opts.fargs[1] == nil then
      require('utils.fzf').fzf({
        source = { 'yes', 'no' },
        fzf_opts = {
          '--header',
          'Load kulala.nvim?',
        },
        sink = function (options)
          if #options < 2 or options[2] == 'no' then
            return
          end

          setup()
        end
      })

      return
    end
  end, {
    bar = true,
    bang = true,
    complete = function () return { 'load' } end,
    nargs = '*',
    desc = '[Kulala] Start kulala',
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
