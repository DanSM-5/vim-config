-- Tree sitter configs

return {
  setup = function()
    require('nvim-treesitter').define_modules({
      fold_treesiter = {
        attach = function (buf, lang)
          -- Options set only for buffers with treesitter parser
          vim.opt_local.foldmethod = 'expr'
          vim.opt_local.foldexpr = 'nvim_treesitter#foldexpr()'
          -- Options set in global config
          -- exec 'set fillchars=fold:\ '
          -- set foldmethod=indent
          -- set nofoldenable
          -- set foldlevel=99
        end,
        detach = function (buf)
          -- Unset changes
          vim.opt_local.foldmethod = 'indent'
          vim.opt_local.foldexpr = ''
        end,
        is_supported = function (lang)
          return true
        end,
      }
    })

    local config = require('nvim-treesitter.configs')
    ---@diagnostic disable-next-line: missing-fields
    config.setup({
      fold_treesiter = {
        enable = true,
      },
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
            ['@function.outer'] = 'v', -- 'V' -- linewise
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
        local repeat_motion = require('utils.repeat_motion')
        local repeat_pair = repeat_motion.repeat_pair
        -- NOTE: Letting demicolon set the motion keys but otherwise motions can be repeated by calling
        -- the following function
        -- require('utils.repeat_motion').set_motion_keys()

        -- Jump to next conflict
        local jumpconflict_next = function()
          -- vim.cmd([[execute "normal \<Plug>JumpconflictContextNext"]])
          vim.cmd.normal(vim.keycode('<Plug>JumpconflictContextNext'))
        end
        local jumpconflict_prev = function()
          -- vim.cmd([[execute "normal \<Plug>JumpconflictContextPrevious"]])
          vim.cmd.normal(vim.keycode('<Plug>JumpconflictContextPrevious'))
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

        -- Move items in quickfix
        local locationlist_next = function()
          vim.cmd('silent! lnext')
        end
        local locationlist_prev = function()
          vim.cmd('silent! lprev')
        end

        repeat_pair({
          keys = 'l',
          -- prefix_forward = '<leader>]',
          -- prefix_backward = '<leader>[',
          desc_forward = '[Locationlist] Move to next item',
          desc_backward = '[Locationlist] Move to previous item',
          on_forward = locationlist_next,
          on_backward = locationlist_prev,
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

        local create_repeatable_pair = repeat_motion.create_repeatable_pair

        local ctrl_w = vim.api.nvim_replace_termcodes('<C-w>', true, true, true)
        local vsplit_bigger, vsplit_smaller  = create_repeatable_pair(function ()
          vim.fn.feedkeys(ctrl_w .. '5>', 'n')
        end, function ()
          vim.fn.feedkeys(ctrl_w .. '5<', 'n')
        end)

        vim.keymap.set('n', '<A-.>', vsplit_bigger, {
          desc = '[VSplit] Make vsplit bigger',
          noremap = true
        })
        vim.keymap.set('n', '<A-,>', vsplit_smaller, {
          desc = '[VSplit] Make vsplit smaller',
          noremap = true
        })

        local split_bigger, split_smaller = create_repeatable_pair(function ()
          vim.fn.feedkeys(ctrl_w .. '+', 'n')
        end, function ()
          vim.fn.feedkeys(ctrl_w .. '-', 'n')
        end)

        vim.keymap.set('n', '<A-t>', split_bigger, {
          desc = '[Split] Make split bigger',
          noremap = true
        })
        vim.keymap.set('n', '<A-s>', split_smaller, {
          desc = '[Split] Make split smaller',
          noremap = true
        })
      end,
    })

    -- local treesitterKeymaps = vim.api.nvim_create_augroup('TreesitterKeymaps', { clear = true })
    -- vim.api.nvim_create_autocmd('BufEnter', {
    --   group = treesitterKeymaps,
    --   pattern = '*',
    --   callback = function (event)
    --     -- NOTE: Override default fold config from config based on indentation
    --     -- This will use the treesitter parser to create folds
    --
    --     if vim.api.nvim_buf_get_option(event.buf, 'filetype') ~= '' and vim.treesitter.get_parser(event.buf) then
    --     end
    --   end,
    -- })

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
