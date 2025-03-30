-- Tree sitter configs

return {
  setup = function()
    require('nvim-treesitter').define_modules({
      fold_treesiter = {
        attach = function(buf, lang)
          -- local windows = vim.fn.win_findbuf(buf)
          -- for _, winid in ipairs(windows) do
          --   -- Options set only for buffers with treesitter parser
          --   vim.wo[winid].foldmethod = 'expr'
          --   vim.wo[winid].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          -- end

          vim.opt_local.foldmethod = 'expr'
          vim.opt_local.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          -- Does not work on startup
          -- vim.opt_local.foldexpr = 'nvim_treesitter#foldexpr()'

          -- Options set in global config
          -- exec 'set fillchars=fold:\ '
          -- set foldmethod=indent
          -- set nofoldenable
          -- set foldlevel=99
        end,
        detach = function(buf)
          -- Unset changes
          -- vim.opt_local.foldmethod = 'indent'
          -- vim.opt_local.foldexpr = ''

          -- local windows = vim.fn.win_findbuf(buf)
          -- for _, winid in ipairs(windows) do
          --   vim.wo[winid].foldmethod = vim.go.foldmethod
          --   vim.wo[winid].foldexpr = vim.go.foldexpr
          -- end

            vim.opt_local.foldmethod = vim.go.foldmethod
            vim.opt_local.foldexpr = vim.go.foldexpr
        end,
        is_supported = function(lang)
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
        'json5',
        'ssh_config',
        'markdown',
        'markdown_inline',
        'html',
        -- 'latex',
        'typst',
        'yaml',
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
      -- for 'nvim-treesitter/nvim-treesitter-textobjects',
      textobjects = {
        lsp_interop = {
          enable = true,
          border = 'rounded', -- 'none',
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
            ['agb'] = { query = '@block.outer', desc = 'Select a block' },
            ['igb'] = { query = '@block.inner', desc = 'Select inner block' },
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
            ['@function.outer'] = 'v',  -- 'V' -- linewise
            ['@class.outer'] = 'v'      -- '<c-v>', -- blockwise
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
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            [']m'] = { query = '@function.outer', desc = '[TS] Next function start' },
            [']]'] = { query = '@class.outer', desc = '[TS] Next class start' },
            [']k'] = { query = '@block.*', desc = '[TS] Next block start' },
            [']C'] = { query = '@comment.outer', desc = '[TS] Next comment start' },
            [']f'] = { query = "@local.scope", query_group = "locals", desc = "[TS] Next scope" },
            --
            -- You can use regex matching (i.e. lua pattern) and/or pass a list in a 'query' key to group multiple queries.
            -- [']o'] = '@loop.*',
            -- [']o'] = { query = { '@loop.inner', '@loop.outer' } }
            --
            -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
            -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
            -- [']s'] = { query = '@local.scope', query_group = 'locals', desc = 'Next scope' },
            -- [']z'] = { query = '@fold', query_group = 'folds', desc = 'Next fold' },
          },
          goto_next_end = {
            [']M'] = { query = '@function.outer', desc = '[TS] Next function end' },
            [']['] = { query = '@class.outer', desc = '[TS] Next class end' },
            [']K'] = { query = '@block.outer', desc = '[TS] Next block end' },
          },
          goto_previous_start = {
            ['[m'] = { query = '@function.outer', desc = '[TS] Previous function start' },
            ['[['] = { query = '@class.outer', desc = '[TS] Previous class start' },
            ['[k'] = { query = '@block.*', desc = '[TS] Previous block start' },
            ['[C'] = { query = '@comment.outer', desc = '[TS] Previous comment start' },
            ['[f'] = { query = "@local.scope", query_group = "locals", desc = "[TS] Next scope" },
          },
          goto_previous_end = {
            ['[M'] = { query = '@function.outer', desc = '[TS] Previous function end' },
            ['[]'] = { query = '@class.outer', desc = '[TS] Previous class end' },
            ['[K'] = { query = '@block.outer', desc = '[TS] Previous block end' },
          },
          -- Below will go to either the start or the end, whichever is closer.
          -- Use if you want more granular movements
          -- Make it even more gradual by adding multiple queries and regex.
          -- goto_next = {
          --   [']d'] = '@conditional.outer',
          -- },
          -- goto_previous = {
          --   ['[d'] = '@conditional.outer',
          -- }
        },
      },
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
    --     url = '~/.config/nvim/tsparsers/tree-sitter-powershell', -- need to update path
    --     files = { 'src/parser.c', 'src/scanner.c' },
    --     branch = 'main',
    --     generate_requires_npm = false,
    --     requires_generate_from_grammar = false,
    --   },
    --   filetype = 'ps1',
    -- }
  end
}
