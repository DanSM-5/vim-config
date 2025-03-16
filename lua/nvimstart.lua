local fn, g = vim.fn, vim.g

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

-- fzf-lsp keys
g.fzf_lsp_preview_window = { 'right', 'ctrl-/', 'ctrl-^' }
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

  function! g:SetTab (space) abort
    let space = empty(a:space) ? '2' : a:space
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

  -- To add highlight declarations
  -- vim.g.theme_toggle_hi = vim.tbl_deep_extend('force',
  --   vim.g.theme_toggle_hi, {
  --   -- vim.fn.Std_hlt('Normal'),
  -- })

  vim.cmd.ToggleBg()
  vim.cmd.SetTab()
  vim.fn['config#after']()
end


-- Setting up config setup
-- Config before runs on startup
fn['config#before']()

-- Config after run on VimEnter
vim.api.nvim_create_autocmd('VimEnter', {
  pattern = { '*' },
  desc = 'Run startup config after plugins are loaded',
  callback = vim.fn.OnVimEnter
})

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

