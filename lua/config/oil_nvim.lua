local search_dir = function()
  -- get the current directory
  local prefills = { paths = require('oil').get_current_dir() }
  require('config.nvim_grugfar').open_from_explorer(prefills)
end

local set_commands = function ()

  -- If we want to restore netrw commands (do I?)
  -- Ref: https://github.com/saccarosium/netrw.vim/blob/fd09e094525c796f6220666246a11e9be258be69/plugin/netrwPlugin.vim
  vim.cmd([[
    command! -nargs=* -bar -bang -count=0 -complete=dir Explore call netrw#Explore(<count>, 0, 0+<bang>0, <q-args>)
    command! -nargs=* -bar -bang -count=0 -complete=dir Sexplore call netrw#Explore(<count>, 1, 0+<bang>0, <q-args>)
    command! -nargs=* -bar -bang -count=0 -complete=dir Hexplore call netrw#Explore(<count>, 1, 2+<bang>0, <q-args>)
    command! -nargs=* -bar -bang -count=0 -complete=dir Vexplore call netrw#Explore(<count>, 1, 4+<bang>0, <q-args>)
    command! -nargs=* -bar -count=0 -complete=dir Texplore call netrw#Explore(<count>, 0, 6, <q-args>)
    command! -nargs=* -bar -bang -count=0 -complete=dir Lexplore call netrw#Lexplore(<count>, <bang>0, <q-args>)
    command! -nargs=* -bar -bang Nexplore call netrw#Explore(-1, 0, 0, <q-args>)
    command! -nargs=* -bar -bang Pexplore call netrw#Explore(-2, 0, 0, <q-args>)
  ]])
end

return {
  setup = function()
    require('oil').setup({
      -- Set to empty table to hide icons
      keymaps = {
        ge = {
          callback = search_dir,
          desc = '[Oil] Search in directory'
        }
      }
    })
    -- Imitate vinegar '-' map
    vim.keymap.set('n', '<leader>-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
  end,
  search_dir = search_dir,
  set_commands = set_commands,
}

