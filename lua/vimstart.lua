local fn, g, cmd = vim.fn, vim.g, vim.cmd

-- Set custom shada file location
cmd("set shada+='1000,n$HOME/.cache/vim-config/main.shada")
-- Make nocompatible explisit
cmd('set nocompatible')
-- Default encoding
cmd('set encoding=UTF-8')
-- show line under the cursor
cmd('set cursorline')
-- enable syntax highlight
-- cmd('syntax enable')
-- enable filetype base indentation
cmd('filetype plugin indent on')
-- Gui colos config
-- cmd('set t_Co=256')
cmd('let &t_8f = "\\<Esc>[38;2;%lu;%lu;%lum"')
cmd('let &t_8b = "\\<Esc>[48;2;%lu;%lu;%lum"')
vim.opt.termguicolors = true

--: Global variables {{{ :-------------------------------------------------

-- Most global variables defined in this file should be place here unless
-- it is needed to be defined upon confiditional logic

-- vim.g.maplocalleader = ' '
g.mapleader = '\\'
-- Store the value of the background in Normal mode
g.bg_value = ''
-- Store the value of the Visual mode
g.bg_visual_selection = ''
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

--: }}} :------------------------------------------------------------------

-- Setting up config setup
-- Config before runs on startup
-- Config after run on VimEnter
fn['config#before']()

--: Global functions {{{ :-------------------------------------------------
vim.cmd [[
  func! g:ToggleBg ()
    let highlight_value = execute('hi Normal')
    let ctermbg_value = matchstr(highlight_value, 'ctermbg=\zs\S*')
    let guibg_value = matchstr(highlight_value, 'guibg=\zs\S*')

    if ctermbg_value == '' && guibg_value ==? ''
      silent execute('hi ' . g:bg_value)
      silent execute('hi ' . g:bg_visual_selection)
    else
      silent execute('hi Normal guibg=NONE ctermbg=NONE')
      silent execute('hi Visual guibg=#5d677a')
    endif
  endfunction

  function g:SetTab ()
    set tabstop=2 softtabstop=2 shiftwidth=2
    set expandtab
    set ruler
    set autoindent smartindent
    filetype plugin indent on
  endfunction

  function! g:OnVimEnter()
    " Get background settings of normal mode
    let g:bg_value = substitute(trim(execute("hi Normal")), 'xxx', '', 'g')
    let g:bg_visual_selection = substitute(trim(execute("hi Visual")), 'xxx', '', 'g')
    " Make background transparen
    ToggleBg
    " Set tab to 2 paces
    SetTab

    " Call config after on vim enter
    call config#after()
  endfunction

  autocmd VimEnter * call g:OnVimEnter()

	" Return to last edit position when opening files
	autocmd BufReadPost *
	     \ if line("'\"") > 0 && line("'\"") <= line("$") |
	     \   exe "normal! g`\"zz" |
	     \ endif

]]
--: }}} :------------------------------------------------------------------

-- TODO: Verify if below autocmd is equivalent to vimscript one
-- vim.api.nvim_create_autocmd('BufReadPost', {
--   pattern = { '*' },
--   callback = function ()
--     if (fn.line("'\"") > 0 and fn.line("'\"") <= fn.line("$")) then
--       fn.execute("normal! g`\"zz")
--     end
--   end
-- })
