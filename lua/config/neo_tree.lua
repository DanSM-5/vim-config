---@module 'neo-tree'

local set_keymaps = function()
  vim.keymap.set(
    'n',
    '<leader>ve',
    ':Neotree filesystem toggle reveal_force_cwd position=right<cr>',
    { desc = 'NeoTree: Open current directory in drawer', silent = true }
  )
  vim.keymap.set(
    'n',
    '<leader>ne',
    ':Neotree filesystem show toggle reveal_force_cwd position=right<cr>',
    { desc = 'NeoTree: Open current directory in drawer but preserve focus on current buffer', silent = true }
  )
  vim.keymap.set(
    'n',
    '<leader>vc',
    ':Neotree filesystem show toggle dir=$user_conf_path position=right<cr>',
    { desc = 'NeoTree: Open user config directory', silent = true }
  )
  vim.keymap.set(
    'n',
    '<leader>vs',
    ':Neotree filesystem show toggle dir=$user_scripts_path position=right<cr>',
    { desc = 'NeoTree: Open user scripts directory', silent = true }
  )
  vim.keymap.set(
    'n',
    '<leader>vv',
    ':Neotree filesystem show toggle dir=$HOME/vim-config position=right<cr>',
    { desc = 'NeoTree: Open vim config directory', silent = true }
  )
  vim.keymap.set(
    'n',
    '<leader>vp',
    ':Neotree filesystem show toggle dir=$HOME/projects position=right<cr>',
    { desc = 'NeoTree: Open projects directory', silent = true }
  )
end

return {
  setup = function()
    ---@type neotree.Config?
    require('neo-tree').setup({
      sources = {
        'filesystem',
        'buffers',
        'git_status',
        'document_symbols',
      },
      -- git_status = {
      --   added     = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
      --   modified  = "", -- or "", but this is redundant info if you use git_status_colors on the name
      --   deleted   = "✖", -- this can only be used in the git_status source
      --   renamed   = "󰁕", -- this can only be used in the git_status source
      --   -- Status type
      --   untracked = "",
      --   ignored   = "",
      --   unstaged  = "󰄱",
      --   staged    = "",
      --   conflict  = "",
      -- },
      window = {
        position = 'right',
        width = 40,
        mapping_options = {
          noremap = true,
          nowait = true,
        },
        mappings = {
          ['<space>'] = {
            'toggle_node',
            nowait = true, -- disable `nowait` if you have existing combos starting with this char that you want to use
          },
        },
        --   ['<2-LeftMouse>'] = 'open',
        --   ['<cr>'] = 'open',
        --   ['<esc>'] = 'cancel', -- close preview or floating neo-tree window
        --   ['P'] = { 'toggle_preview', config = { use_float = true, use_image_nvim = false } }, -- Requires kitty img protocol
        --   -- Read `# Preview Mode` for more information
        --   ['l'] = 'focus_preview',
        --   ['S'] = 'open_split',
        --   ['s'] = 'open_vsplit',
        --   -- ["S"] = "split_with_window_picker",
        --   -- ["s"] = "vsplit_with_window_picker",
        --   ['t'] = 'open_tabnew',
        --   -- ["<cr>"] = "open_drop",
        --   -- ["t"] = "open_tab_drop",
        --   -- ['w'] = 'open_with_window_picker',
        --   --["P"] = "toggle_preview", -- enter preview mode, which shows the current node without focusing
        --   ['C'] = 'close_node',
        --   -- ['C'] = 'close_all_subnodes',
        --   ['z'] = 'close_all_nodes',
        --   --["Z"] = "expand_all_nodes",
        --   --["Z"] = "expand_all_subnodes",
        --   ['a'] = {
        --     'add',
        --     -- this command supports BASH style brace expansion ("x{a,b,c}" -> xa,xb,xc). see `:h neo-tree-file-actions` for details
        --     -- some commands may take optional config options, see `:h neo-tree-mappings` for details
        --     config = {
        --       show_path = 'none', -- "none", "relative", "absolute"
        --     },
        --   },
        --   ['A'] = 'add_directory', -- also accepts the optional config.show_path option like "add". this also supports BASH style brace expansion.
        --   ['d'] = 'delete',
        --   ['r'] = 'rename',
        --   ['b'] = 'rename_basename',
        --   ['y'] = 'copy_to_clipboard',
        --   ['x'] = 'cut_to_clipboard',
        --   ['p'] = 'paste_from_clipboard',
        --   ['c'] = 'copy', -- takes text input for destination, also accepts the optional config.show_path option like "add":
        --   -- ["c"] = {
        --   --  "copy",
        --   --  config = {
        --   --    show_path = "none" -- "none", "relative", "absolute"
        --   --  }
        --   --}
        --   ['m'] = 'move', -- takes text input for destination, also accepts the optional config.show_path option like "add".
        --   ['q'] = 'close_window',
        --   ['R'] = 'refresh',
        --   ['?'] = 'show_help',
        --   ['<'] = 'prev_source',
        --   ['>'] = 'next_source',
        --   ['i'] = 'show_file_details',
        --   -- ["i"] = {
        --   --   "show_file_details",
        --   --   -- format strings of the timestamps shown for date created and last modified (see `:h os.date()`)
        --   --   -- both options accept a string or a function that takes in the date in seconds and returns a string to display
        --   --   -- config = {
        --   --   --   created_format = "%Y-%m-%d %I:%M %p",
        --   --   --   modified_format = "relative", -- equivalent to the line below
        --   --   --   modified_format = function(seconds) return require('neo-tree.utils').relative_date(seconds) end
        --   --   -- }
        --   -- },
        -- },
      },
    })
    -- Use same highlights for NormalNC
    vim.cmd('highlight clear NeoTreeNormalNC')
    vim.cmd('highlight link NeoTreeNormalNC NormalNC')

    set_keymaps()
  end,
  set_keymaps = set_keymaps,
}
