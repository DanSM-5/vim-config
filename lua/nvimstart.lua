if vim.g.vimc_config == 1 then
  return
end

local fn, g = vim.fn, vim.g

vim.g.lazy_config = 1

-- Set custom shada file location
-- vim.cmd("set shada+='1000,n$HOME/.cache/vim-config/main.shada")
-- Make nocompatible explicit
vim.o.compatible = false
-- Default encoding
vim.o.encoding = 'UTF-8'
-- show line under the cursor
vim.o.cursorline = true
-- enable syntax highlight
-- cmd('syntax enable')
-- enable filetype base indentation
vim.cmd('filetype plugin indent on')
-- Gui colos config
-- cmd('set t_Co=256')
vim.cmd('let &t_8f = "\\<Esc>[38;2;%lu;%lu;%lum"')
vim.cmd('let &t_8b = "\\<Esc>[48;2;%lu;%lu;%lum"')
vim.opt.termguicolors = true
-- Set backspace normal behavior
vim.o.backspace = 'indent,eol,start'
-- Set hidden on
vim.o.hidden = true
-- Explicit mouse behavior
vim.o.mouse = 'a'

vim.opt.breakindent = true

--: Global variables {{{ :-------------------------------------------------

-- Most global variables defined in this file should be place here unless
-- it is needed to be defined upon confiditional logic

-- vim.g.maplocalleader = ' '
g.mapleader = '\\'
g.maplocalleader = ' '

-- Theme variables --

-- New definition, list here themes to toggle
-- [hi name], [hi bg on], [hi bg off]
--[[
Remember to use temporary values to update:
    vim.g.my_dict.field1 = 'value'  -- Does not work

    local my_dict = vim.g.my_dict   --
    my_dict.field1 = 'value'        -- Instead do
    vim.g.my_dict = my_dict         --
--]]
---@type [string, string, string][]
g.theme_toggle_hi = {}

-- Enable detection
g.host_os = fn['config#CurrentOS']()

-- " Vim Buffet icons
-- let g:buffet_powerline_separators = 1
-- let g:buffet_tab_icon = "\uf00a"
-- let g:buffet_left_trunc_icon = "\uf0a8"
-- let g:buffet_right_trunc_icon = "\uf0a9"
-- " Only hide quickfix buffers. Can be found with :ls!
-- let g:buffet_hidden_buffers = ['quickfix']

-- Camel case motion keybindings
g.camelcasemotion_key = '<leader>'
-- Vim-Asterisk keep cursor position under current letter with
g['asterisk#keeppos'] = 1
-- Disable vim-smoothie remaps
g.smoothie_no_default_mappings = 1
-- Airline configs
-- g.airline_theme = 'onehalfdark'
-- g.airline_powerline_fonts = 1
-- One dark color config
-- let g:onedark_termcolors = 256


-- Path to find scripts or executables
g.scripts_dir = vim.fn.substitute(
  vim.fn.exists('g:scripts_dir') and g.scripts_dir or vim.fn.stdpath('config') .. '/utils',
  '\\', '/', 'g'
)


-- fzf-lsp keys
g.fzf_lsp_override_opts = {
  '--bind', 'ctrl-l:change-preview-window(down|hidden|)',
  '--bind', 'ctrl-/:change-preview-window(down|hidden|)',
  '--bind', 'ctrl-^:toggle-preview',
}


-- General options
local fzf_base_options = {
  '--multi', '--ansi', '--bind', 'alt-c:clear-query', '--input-border=rounded'
}
local fzf_bind_options = {
  '--bind', 'ctrl-l:change-preview-window(down|hidden|)',
  '--bind', 'ctrl-/:change-preview-window(down|hidden|)',
  '--bind', 'alt-up:preview-page-up,alt-down:preview-page-down',
  '--bind', 'shift-up:preview-up,shift-down:preview-down',
  '--bind', 'ctrl-^:toggle-preview',
  '--bind', 'ctrl-s:toggle-sort',
  '--cycle',
  '--bind', 'alt-f:first',
  '--bind', 'alt-l:last',
  '--bind', 'alt-a:select-all',
  '--bind', 'alt-d:deselect-all'
}
local fzf_preview_options = {
  '--layout=reverse',
  '--preview-window', '60%,wrap',
  '--preview', 'bat -pp --color=always --style=numbers {}'
}

vim.list_extend(fzf_bind_options, fzf_base_options)
vim.list_extend(fzf_preview_options, fzf_bind_options)

g.fzf_base_options = fzf_base_options
g.fzf_bind_options = fzf_bind_options
g.fzf_preview_options = fzf_preview_options

---@type [string, string, string][]
g.theme_toggle_hi = {}
--: }}} :------------------------------------------------------------------

--: Global functions {{{ :-------------------------------------------------
vim.cmd([[
  func! g:ToggleBg ()
    let highlight_value = execute('hi Normal')
    " let ctermbg_value = matchstr(highlight_value, 'ctermbg=\zs\S*')
    let guibg_value = matchstr(highlight_value, 'guibg=\zs\S*')

    if guibg_value ==? ''

      for group_toggle in g:theme_toggle_hi
        silent execute(group_toggle[1])
      endfor
    else

      for group_toggle in g:theme_toggle_hi
        silent execute(group_toggle[2])
      endfor
    endif
  endfunction

  function! g:SetTab (...) abort
    let space = (exists('a:1') && !empty(a:1)) ? a:1 : '2'
    exec 'set tabstop=' . space . ' softtabstop=' . space . ' shiftwidth=' . space
    set expandtab
    set ruler
    set autoindent smartindent
  endfunction

  " Get clean highlight group
  function! g:Get_hlg(hlg) abort
    return substitute(trim(execute('hi '.a:hlg)), 'xxx', '', 'g')
  endfunction

  " Creates a standard highlight toggle entry
  function! g:Std_hlt(hlg, ...) abort
    let hidden_hlg = a:0 == 1 ? a:1 : printf('hi %s guibg=NONE ctermbg=NONE', a:hlg)
    return [a:hlg, 'hi ' . g:Get_hlg(a:hlg), hidden_hlg]
  endfunction

  " Return to last edit position when opening files
  " autocmd BufReadPost *
  "      \ if line("'\"") > 0 && line("'\"") <= line("$") |
  "      \   exe "normal! g`\"zz" |
  "      \ endif
]])

vim.fn.OnVimEnter = function ()

  vim.cmd.ToggleBg()
  vim.cmd.SetTab()
  vim.fn['config#after']()
end


-- Setting up config setup
-- Config before runs on startup
fn['config#before']()


if vim.fn.has('nvim-0.12.0') == 1 then
  vim.opt.fillchars:append({ foldinner = ' ' })
  vim.o.foldcolumn = 'auto'
end

-- Config after run on VimEnter
vim.api.nvim_create_autocmd('VimEnter', {
  pattern = { '*' },
  desc = 'Run startup config after plugins are loaded',
  callback = vim.fn.OnVimEnter
})

--- Prevent attaching lsp to known buffers
vim.lsp.start = (function()
  ---@type fun(config: vim.lsp.ClientConfig, opts?: vim.lsp.start.Opts)
  local og_lsp_start = vim.lsp.start
  -- known ignored filetypes
  local exclude_filetypes = {
    'help',
    'fzf',
    'fugitive',
    'qf',
  }

  return function(...)
    ---@type vim.lsp.start.Opts
    local opt = select(2, ...) or {}
    local bufnr = opt.bufnr

    if bufnr then
      if
        not vim.api.nvim_buf_is_valid(bufnr)
        or vim.bo[bufnr].buftype ~= '' -- non regular buffers
        or vim.b[bufnr].fugitive_type -- known fugitive buffer
        or vim.startswith(vim.api.nvim_buf_get_name(bufnr), 'fugitive://') -- fugitive buffer
        or vim.tbl_contains(exclude_filetypes, vim.bo[bufnr].filetype) -- excluded filetypes
      then
        return
      end
    end

    -- Start the client
    return og_lsp_start(...)
  end
end)()


--: }}} :------------------------------------------------------------------

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Recover previous cursor position in buffer',
  pattern = { '*' },
  callback = function()
    if (fn.line("'\"") > 0 and fn.line("'\"") <= fn.line("$")) then
      fn.execute("normal! g`\"zz")
    end
  end
})

require('shared.nvim_load')

