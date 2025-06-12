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
    tag = 'v5.3.0',
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

  -- Add kulala
  require('utils.packages').lazy_register({ kulala_spec }, function (plugins)
    if #plugins == 0 then
      vim.notify('[Kulala] plugin not installed', vim.log.levels.DEBUG)
      return false
    end

    local buf = vim.api.nvim_get_current_buf()
    local filetype = vim.api.nvim_get_option_value('filetype', {
      buf = buf,
    })

    if not vim.tbl_contains(filetypes, filetype) then
      return false
    end

    return true
  end)
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
