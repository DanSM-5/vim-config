local function echo(hlgroup, msg)
  vim.cmd('echohl ' .. hlgroup)
  vim.cmd('echo "lspfuzzy: ' .. msg .. '"')
  vim.cmd('echohl None')
end

---Concatenates 2 arrays
---@generic T
---@param t1 T[]
---@param t2 T[]
---@return table
local function array_concat(t1, t2)
  local result = {}
  for _, v in ipairs(t1) do table.insert(result, v) end
  for _, v in ipairs(t2) do table.insert(result, v) end
  return result
end

local rg_args = ' --column --line-number --no-ignore --no-heading --color=always --smart-case --hidden --glob "!plugged" --glob "!.git" --glob "!node_modules" '
---@type string[]
local fzf_base_options = { '--multi', '--ansi', '--info=inline', '--bind', 'alt-c:clear-query' }
---@type string[]
local fzf_bind_options = array_concat(fzf_base_options, {
            '--bind',
            'ctrl-l:change-preview-window(down|hidden|),ctrl-/:change-preview-window(down|hidden|),alt-up:preview-page-up,alt-down:preview-page-down',
            '--bind', 'ctrl-s:toggle-sort',
            '--cycle',
            '--bind', '0:change-preview-window(down|hidden|)',
            '--bind', '1:toggle-preview',
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

-- if using expect then the first prop will be the string key
-- local key = table.remove(entries, 1)
-- local locations = vim.tbl_map(fzf_to_lsp, entries)
-- if fzf_actions[key] ~= nil then  -- user has used ctrl-t/ctrl-v/ctrl-x
--   cmd(fzf_actions[key])
-- end

---Wraper command for fzf#run(fzf#wrap({}))
---@param source function | table
---@param sink fun(options: string[]): nil
---@param fzf_opts string[]
---@return nil
local fzf = function (source, sink, fzf_opts)
  if not vim.g.loaded_fzf then
    echo('WarningMsg', 'FZF is not loaded.')
    return
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

  local fzf_opts_wrap = vim.fn['fzf#wrap']({ source = source, options = fzf_opts })
  fzf_opts_wrap['sink*'] = sink -- 'sink*' needs to be assigned outside wrap()
  vim.fn['fzf#run'](fzf_opts_wrap)
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
    echo('WarningMsg', 'No lsp clients attached in current buffer')
    return
  elseif #client_names == 1 then
    -- single client open settings directly
    sink(client_names)
    return
  end

  local home = string.gsub('C:\\Users\\daniel', [[\]], [[/]])
  local hist_path = '--history=' .. home .. '/.cache/fzf-history/fzf-select-lsp-client'
  local options = array_concat(fzf_bind_options, { '--prompt', 'Buffer Clients> ', hist_path })

  -- return client_names
  fzf(client_names, sink, options)
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
