
local array_concat = require('utils.stdlib').concat
local rg_args = ' --column --line-number --no-ignore --no-heading --color=always --smart-case --hidden --glob "!plugged" --glob "!.git" --glob "!node_modules" '
---@type string[]
local fzf_base_options = { '--multi', '--ansi', '--info=inline', '--bind', 'alt-c:clear-query' }
---@type string[]
local fzf_bind_options = array_concat(fzf_base_options, {
            '--bind', 'ctrl-^:toggle-preview',
            '--bind', 'ctrl-l:change-preview-window(down|hidden|)',
            '--bind', 'ctrl-/:change-preview-window(down|hidden|)',
            '--bind', 'alt-up:preview-page-up,alt-down:preview-page-down',
            '--bind', 'shift-up:preview-up,shift-down:preview-down',
            '--bind', 'ctrl-s:toggle-sort',
            '--cycle',
            -- '--bind', '0:change-preview-window(down|hidden|)',
            -- '--bind', '1:toggle-preview',
            '--bind', 'alt-f:first',
            '--bind', 'alt-l:last',
            '--bind', 'alt-a:select-all',
            '--bind', 'alt-d:deselect-all' })

local fzf_preview_options = array_concat(fzf_bind_options, {
       '--layout=reverse',
       '--preview-window', '60%',
       '--preview', 'bat -pp --color=always --style=numbers {}' })

local fzf_original_default_opts = vim.env.FZF_DEFAULT_OPTS

-- Options with only bind commands
local fzf_options_with_binds = { options = fzf_bind_options }

-- Options with bindings + preview
local fzf_options_with_preview = { options = fzf_preview_options }

-- Lua integration with fzf.vim
-- Ref: https://github.com/ojroques/nvim-lspfuzzy/blob/6ec09a2072044c19addce7a560b50ba8c2e1beed/lua/lspfuzzy.lua#L40
-- https://github.com/creativenull/dotfiles/blob/930b79cb0d07b552b4b8e6b3a7db14f1097d049f/config/nvim/lua/user/fzf.lua#L34

-- if using expect then the first prop will be the string key
-- local key = table.remove(entries, 1)
-- local locations = vim.tbl_map(fzf_to_lsp, entries)
-- if fzf_actions[key] ~= nil then  -- user has used ctrl-t/ctrl-v/ctrl-x
--   cmd(fzf_actions[key])
-- end

---@class FzfOptions
---@field source (fun(): table) | table
---@field sink fun(options: string[]): nil
---@field fzf_opts string[]
---@field name? string
---@field fullscreen? boolean

---Wraper command for fzf#run(fzf#wrap({}))
---@param opts FzfOptions
---@return nil
local fzf = function (opts)
  if not vim.g.loaded_fzf then
    vim.notify('Fzf plugin is not laoded!', vim.log.levels.WARN)
    return
  end

  -- Default history file
  local name = opts.name or 'fzf-history-default'
  local fullscreen = opts.fullscreen and 1 or 0
  local source = opts.source
  local options = opts.fzf_opts
  local sink = opts.sink or function (tbl)
    for _, value in ipairs(tbl) do
      vim.notify(value)
    end
  end

  -- local fzf_opts = opts.fzf_options
  -- if not fzf_opts or vim.tbl_isempty(fzf_opts) then
  --   fzf_opts = {
  --     '--ansi',
  --     '--bind',
  --     'ctrl-a:select-all,ctrl-d:deselect-all',
  --     '--expect',
  --     table.concat(vim.tbl_keys(fzf_actions), ','),
  --     '--multi',
  --   }
  --   if pcall(vim.fn['fzf#vim#with_preview']) then -- enable preview with fzf.vim
  --     vim.list_extend(fzf_opts, {
  --       '--delimiter',
  --       ':',
  --       '--preview-window',
  --       '+{2}-/2',
  --     })
  --     vim.list_extend(fzf_opts, vim.fn['fzf#vim#with_preview']().options)
  --   end
  -- end

  local fzf_opts_wrap = vim.fn['fzf#wrap'](name, { source = source, options = options }, fullscreen)
  fzf_opts_wrap['sink*'] = sink -- 'sink*' needs to be assigned outside wrap()
  vim.fn['fzf#run'](fzf_opts_wrap)
end

---Get the parameter --history for fzf taking into account g:fzf_history_dir if exists
---It accepts a custom file name or a default name if no name is provided
---@param file string Name of a custom file for saving the history
---@return string History param for command
local function get_history_param (file)
  local hist_file = file or 'fzf-history-default'
  local hist_path = '--history='
  local home = string.gsub(vim.env.HOME, [[\]], [[/]]) -- force '/' in windows
  local base_path = vim.g.fzf_history_dir and vim.g.fzf_history_dir or home .. '/.cache/fzf-history'
  if string.find(base_path, '~') then
    base_path = string.gsub(base_path, '~', home)
  end
  -- local base_path = vim.env.FZF_HIST_DIR

  -- combine  --history= + /path/to/cache + /filename
  hist_path = hist_path .. base_path .. '/' .. hist_file

  return hist_path
end

---@param sink fun(options: string[]): nil
---@return nil
local select_buffer_lsp = function (sink)
  local bufnr = vim.api.nvim_get_current_buf()

  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  local client_names = {}
  for _, client in ipairs(clients) do
    table.insert(client_names, client.name)
  end

  if #client_names == 0 then
    vim.notify('No lsp clients attached in current buffer', vim.log.levels.WARN)
    return
  elseif #client_names == 1 then
    -- single client open settings directly
    sink({ '', client_names[1] })
    return
  end

  local hist_file = 'fzf-select-lsp-client'
  local hist_path = get_history_param(hist_file)
  local options = array_concat(fzf_bind_options, {
    '--prompt',
    'Buffer Clients> ',
    hist_path,
    '--no-multi',
  })

  -- return client_names
  fzf({ source = client_names, sink = sink, fzf_opts = options })
end

return {
  fzf = fzf,
  select_buffer_lsp = select_buffer_lsp,
  rg_args = rg_args,
  fzf_base_options = fzf_base_options,
  fzf_bind_options = fzf_bind_options,
  fzf_preview_options = fzf_preview_options,
  fzf_original_default_opts = fzf_original_default_opts,
  fzf_options_with_binds = fzf_options_with_binds,
  fzf_options_with_preview = fzf_options_with_preview,
}

