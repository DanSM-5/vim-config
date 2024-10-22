-- Tree sitter configs

return {
  setup = function()
    local config = require('nvim-treesitter.configs')
    ---@diagnostic disable-next-line: missing-fields
    config.setup({
      ignore_install = {},
      sync_install = true,
      ensure_installed = {
        'git_config',
        'git_rebase',
        'gitattributes',
        'gitcommit',
        'gitignore',
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
      -- for 'nvim-treesitter/nvim-treesitter-textobjects',
      textobjects = {
        lsp_interop = {
          enable = true,
          border = 'none',
          floating_preview_opts = {},
          peek_definition_code = {
            ['<space>df'] = '@function.outer',
            ['<space>dF'] = '@class.outer',
          },
        },
        select = {
          enable = true,

          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,

          keymaps = {
            ['ab'] = { query = '@block.inner', desc = 'Select a block' },
            ['ib'] = { query = '@block.outer', desc = 'Select inner block' },
            -- You can use the capture groups defined in textobjects.scm
            ['af'] = { query = '@function.outer', desc = 'Select a function' },
            ['if'] = { query = '@function.inner', desc = 'Select inner function' },
            ['ac'] = { query = '@class.outer', desc = 'Select a class' },
            -- You can optionally set descriptions to the mappings (used in the desc parameter of
            -- nvim_buf_set_keymap) which plugins like which-key display
            ['ic'] = { query = '@class.inner', desc = 'Select inner part of a class region' },
            -- You can also use captures from other query groups like `locals.scm`
            ['as'] = { query = '@scope', query_group = 'locals', desc = 'Select language scope' },
          },
          -- You can choose the select mode (default is charwise 'v')
          --
          -- Can also be a function which gets passed a table with the keys
          -- * query_string: eg '@function.inner'
          -- * method: eg 'v' or 'o'
          -- and should return the mode ('v', 'V', or '<c-v>') or a table
          -- mapping query_strings to modes.
          selection_modes = {
            ['@parameter.outer'] = 'v', -- charwise
            ['@function.outer'] = 'V',  -- linewise
            ['@class.outer'] = '<c-v>', -- blockwise
          },
          -- If you set this to `true` (default is `false`) then any textobject is
          -- extended to include preceding or succeeding whitespace. Succeeding
          -- whitespace has priority in order to act similarly to eg the built-in
          -- `ap`.
          --
          -- Can also be a function which gets passed a table with the keys
          -- * query_string: eg '@function.inner'
          -- * selection_mode: eg 'v'
          -- and should return true or false
          include_surrounding_whitespace = true,
        },
      },
    })

    -- Create repeatable mappings using nvim-treesitter-textobjects
    vim.api.nvim_create_autocmd('VimEnter', {
      desc = 'Create repeatable bindings',
      pattern = { '*' },
      callback = function()
        local repeat_pair = require('utils.repeat_motion').repeat_pair
        -- NOTE: Letting demicolon set the motion keys but otherwise motions can be repeated by calling
        -- the following function
        -- require('utils.repeat_motion').set_motion_keys()

        -- Jump to next conflict
        local jumpconflict_next = function()
          vim.cmd([[execute "normal \<Plug>JumpconflictContextNext"]])
        end
        local jumpconflict_prev = function()
          vim.cmd([[execute "normal \<Plug>JumpconflictContextPrevious"]])
        end

        repeat_pair({
          keys = 'n',
          desc_forward = '[JumpConflict] Move to next conflict marker',
          desc_backward = '[JumpConflict] Move to previous conflict marker',
          on_forward = jumpconflict_next,
          on_backward = jumpconflict_prev,
        })

        -- Move items in quickfix
        local quickfix_next = function()
          vim.cmd('silent! cnext')
        end
        local quickfix_prev = function()
          vim.cmd('silent! cprev')
        end

        repeat_pair({
          keys = 'q',
          desc_forward = '[Quickfix] Move to next error',
          desc_backward = '[Quickfix] Move to previous error',
          on_forward = quickfix_next,
          on_backward = quickfix_prev,
        })

        -- Move to next todo comment
        local todo_next = function ()
          require('todo-comments').jump_next()
        end
        local todo_prev = function ()
          require('todo-comments').jump_prev()
        end

        repeat_pair({
          keys = 'j',
          desc_forward = '[TodoComments] Move to next todo comment',
          desc_backward = '[TodoComments] Move to previous todo comment',
          on_forward = todo_next,
          on_backward = todo_prev,
        })

      end,
    })

    -- NOTE: For custom powershell treesitter parser:
    -- local treesitter_parser_config = require('nvim-treesitter.parsers').get_parser_configs()
    -- treesitter_parser_config.powershell = {
    --   install_info = {
    --     url = "~/.config/nvim/tsparsers/tree-sitter-powershell", -- need to update path
    --     files = { "src/parser.c", "src/scanner.c" },
    --     branch = "main",
    --     generate_requires_npm = false,
    --     requires_generate_from_grammar = false,
    --   },
    --   filetype = "ps1",
    -- }
  end
}
