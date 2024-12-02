-- TODO: WIP implementing fzf-lua
-- Need to complete the following
-- - Add commands that are similar to fzf.vim. Profile fzf-vim isn't what we expect.
-- - Use ctrl-/ to toggle-preview. Currently not working.
-- - Fix other mappings that seem not to work correctly.
-- - Ensure fzf-lua and fzf.vim does not conflict.

-- Resources:
-- https://github.com/ibhagwan/fzf-lua/blob/main/plugin/fzf-lua.vim
-- https://github.com/ibhagwan/fzf-lua#customization
-- https://github.com/ibhagwan/fzf-lua/wiki/Advanced

local function setup_commands(no_override, prefix)
  local function cmd_exists(cmd)
    local ret = vim.fn.exists(':' .. cmd)
    if type(ret) == 'number' and ret ~= 0 then
      return true
    end
  end

  local utils = require('fzf-lua').utils
  local cmds = {
    -- ["Files"] = utils.create_user_command_callback("files", "cwd"),
    ['GFiles'] = utils.create_user_command_callback('git_files', 'cwd', { ['?'] = 'git_status' }),
    ['Buffers'] = utils.create_user_command_callback('buffers'),
    ['Colors'] = utils.create_user_command_callback('colorschemes'),
    ['Rg'] = utils.create_user_command_callback('grep', 'search'),
    ['RG'] = utils.create_user_command_callback('live_grep', 'search'),
    ['Lines'] = utils.create_user_command_callback('lines', 'query'),
    ['BLines'] = utils.create_user_command_callback('blines', 'query'),
    ['Tags'] = utils.create_user_command_callback('tags', 'query'),
    ['BTags'] = utils.create_user_command_callback('btags', 'query'),
    ['Changes'] = utils.create_user_command_callback('changes'),
    ['Marks'] = utils.create_user_command_callback('marks'),
    ['Jumps'] = utils.create_user_command_callback('jumps'),
    ['Commands'] = utils.create_user_command_callback('commands'),
    ['History'] = utils.create_user_command_callback('oldfiles', 'query', {
      [':'] = 'command_history',
      ['/'] = 'search_history',
    }),
    ['Commits'] = utils.create_user_command_callback('git_commits', 'query'),
    ['BCommits'] = utils.create_user_command_callback('git_bcommits', 'query'),
    ['Maps'] = utils.create_user_command_callback('keymaps', 'query'),
    ['Helptags'] = utils.create_user_command_callback('help_tags', 'query'),
    ['Filetypes'] = utils.create_user_command_callback('filetypes', 'query'),
  }

  for cmd, cb in pairs(cmds) do
    cmd = (prefix or '') .. cmd
    if not cmd_exists(cmd) or no_override ~= true then
      pcall(vim.api.nvim_del_user_command, cmd)
      vim.api.nvim_create_user_command(cmd, cb, { bang = true, nargs = '?' })
    end
  end
end

return {
  setup = function()
    local actions = require('fzf-lua').actions
    require('fzf-lua').setup({
      fn_load = setup_commands,
      keymap = {
        fzf = {
          true,
          ['ctrl-/'] = 'toggle-preview',
          ['shift-down'] = 'preview-down',
          ['shift-up'] = 'preview-up',
          ['alt-down'] = 'preview-page-down',
          ['alt-up'] = 'preview-page-up',
          ['alt-f'] = 'first',
          ['alt-l'] = 'last',
          ['alt-a'] = 'toggle-all',
        },
      },
      actions = {
        false,
        ["enter"]       = actions.file_edit_or_qf,
        ["ctrl-s"]      = actions.file_split,
        ["ctrl-v"]      = actions.file_vsplit,
        ["ctrl-t"]      = actions.file_tabedit,
        ["alt-q"]       = actions.file_sel_to_qf,
        ["alt-Q"]       = actions.file_sel_to_ll,
      }
    })

    ---Function that calls fzf-lua.files
    ---@param opts { bang: boolean; fargs: string[] }
    vim.api.nvim_create_user_command('Files', function(opts)
      local cwd = vim.fn.isdirectory(opts.fargs[1]) and opts.fargs[1] or vim.fn.GitPath()
      require('fzf-lua').files({ resume = opts.bang, cwd = cwd })
    end, { bang = true, bar = true, complete = 'dir', nargs = '?' })

    vim.keymap.set({ 'i' }, '<C-x><C-f>', function()
      require('fzf-lua').complete_file({
        cmd = 'rg --files',
        winopts = { preview = { hidden = 'nohidden' } },
      })
    end, { silent = true, desc = 'Fuzzy complete file' })
  end,
}

