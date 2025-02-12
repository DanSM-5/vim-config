-- Tree sitter configs

local function set_keymaps()
  local repeat_motion = require('utils.repeat_motion')
  local repeat_pair = repeat_motion.repeat_pair
  local create_repeatable_pair = repeat_motion.create_repeatable_pair
  -- NOTE: Setting repeatable keymaps ',' (left) and ';' (right)
  repeat_motion.set_motion_keys()

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
  local todo_next = function()
    require('todo-comments').jump_next()
  end
  local todo_prev = function()
    require('todo-comments').jump_prev()
  end

  repeat_pair({
    keys = 't',
    desc_forward = '[TodoComments] Move to next todo comment',
    desc_backward = '[TodoComments] Move to previous todo comment',
    on_forward = todo_next,
    on_backward = todo_prev,
  })


  local ctrl_w = vim.api.nvim_replace_termcodes('<C-w>', true, true, true)
  local vsplit_bigger, vsplit_smaller = create_repeatable_pair(function()
    vim.fn.feedkeys(ctrl_w .. '5>', 'n')
  end, function()
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

  local split_bigger, split_smaller = create_repeatable_pair(function()
    vim.fn.feedkeys(ctrl_w .. '+', 'n')
  end, function()
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

  -- Diagnostic mappings
  local diagnostic_jump_next = nil
  local diagnostic_jump_prev = nil

  if vim.diagnostic.jump then
    diagnostic_jump_next = vim.diagnostic.jump
    diagnostic_jump_prev = vim.diagnostic.jump
  else
    -- Deprecated in favor of `vim.diagnostic.jump` in Neovim 0.11.0
    diagnostic_jump_next = vim.diagnostic.goto_next
    diagnostic_jump_prev = vim.diagnostic.goto_prev
  end

  local diagnostic_next,
  diagnostic_prev
  = create_repeatable_pair(
  ---Move to next diagnostic
  ---@param options vim.diagnostic.GotoOpts | nil
    function(options)
      local opts = options or {}
      ---@diagnostic disable-next-line
      opts.count = 1 * vim.v.count1
      diagnostic_jump_next(opts)
    end,
    ---Move to provious diagnostic
    ---@param options vim.diagnostic.GotoOpts | nil
    function(options)
      local opts = options or {}
      ---@diagnostic disable-next-line
      opts.count = -1 * vim.v.count1
      diagnostic_jump_prev(opts)
    end
  )

  -- diagnostic
  vim.keymap.set('n', ']d', function()
      diagnostic_next({ wrap = true })
    end,
    { desc = 'LSP: Go to next diagnostic message', silent = true, noremap = true }
  )
  vim.keymap.set('n', '[d', function()
      diagnostic_prev({ wrap = true })
    end,
    { desc = 'LSP: Go to previous diagnostic message', silent = true, noremap = true }
  )

  -- diagnostic ERROR
  vim.keymap.set('n', ']e', function()
    diagnostic_next({ severity = vim.diagnostic.severity.ERROR, wrap = true })
  end, { desc = 'LSP: Go to next error', silent = true, noremap = true })
  vim.keymap.set('n', '[e', function()
    diagnostic_prev({ severity = vim.diagnostic.severity.ERROR, wrap = true })
  end, { desc = 'LSP: Go to previous error', silent = true, noremap = true })

  -- diagnostic WARN
  vim.keymap.set('n', ']w', function()
    diagnostic_next({ severity = vim.diagnostic.severity.WARN, wrap = true })
  end, { desc = 'LSP: Go to next warning', silent = true, noremap = true })
  vim.keymap.set('n', '[w', function()
    diagnostic_prev({ severity = vim.diagnostic.severity.WARN, wrap = true })
  end, { desc = 'LSP: Go to previous warning', silent = true, noremap = true })

  -- diagnostic INFO
  vim.keymap.set('n', ']i', function()
    diagnostic_next({ severity = vim.diagnostic.severity.INFO })
  end, { desc = 'LSP: Go to next hint', silent = true, noremap = true })
  vim.keymap.set('n', '[i', function()
    diagnostic_prev({ severity = vim.diagnostic.severity.INFO })
  end, { desc = 'LSP: Go to previous hint', silent = true, noremap = true })

  -- diagnostic HINT
  vim.keymap.set('n', ']h', function()
    diagnostic_next({ severity = vim.diagnostic.severity.HINT })
  end, { desc = 'LSP: Go to next hint', silent = true, noremap = true })
  vim.keymap.set('n', '[h', function()
    diagnostic_prev({ severity = vim.diagnostic.severity.HINT })
  end, { desc = 'LSP: Go to previous hint', silent = true, noremap = true })

  -- Override next-prev matching bracket
  -- local next_close_bracket, prev_close_bracket = create_repeatable_pair(
  --   function ()
  --     vim.fn.search('}')
  --   end, function ()
  --     vim.fn.search('}', 'b')
  --   end
  -- )
  -- local next_open_bracket, prev_open_bracket = create_repeatable_pair(
  --   function ()
  --     vim.fn.search('{')
  --   end, function ()
  --     vim.fn.search('{', 'b')
  --   end
  -- )
  -- vim.keymap.set('n', ']}', next_close_bracket, { desc = '[Bracket]: Go to next close bracket', silent = true, noremap = true })
  -- vim.keymap.set('n', '[}', prev_close_bracket, { desc = '[Bracket]: Go to previous close bracket', silent = true, noremap = true })
  -- vim.keymap.set('n', ']{', next_open_bracket, { desc = '[Bracket]: Go to next open bracket', silent = true, noremap = true })
  -- vim.keymap.set('n', '[{', prev_open_bracket, { desc = '[Bracket]: Go to previous open bracket', silent = true, noremap = true })

  local next_matching_bracket, prev_matching_bracket = create_repeatable_pair(
    function()
      ---@diagnostic disable-next-line Diagnostic have the wrong function signature for searchpair
      vim.fn.searchpair('{', '', '}')
    end, function()
      ---@diagnostic disable-next-line Diagnostic have the wrong function signature for searchpair
      vim.fn.searchpair('{', '', '}', 'b')
    end
  )
  local next_bracket_pair, prev_bracket_pair = create_repeatable_pair(
    function()
      vim.fn.search('[{}]')
    end, function()
      vim.fn.search('[{}]', 'b')
    end
  )
  vim.keymap.set('n', ']}', next_bracket_pair,
    { desc = '[Bracket]: Go to next bracket pair', silent = true, noremap = true })
  vim.keymap.set('n', '[}', prev_bracket_pair,
    { desc = '[Bracket]: Go to previous bracket pair', silent = true, noremap = true })
  vim.keymap.set('n', ']{', next_matching_bracket,
    { desc = '[Bracket]: Go to next matching bracket', silent = true, noremap = true })
  vim.keymap.set('n', '[{', prev_matching_bracket,
    { desc = '[Bracket]: Go to previous matching bracket', silent = true, noremap = true })
end

return {
  set_keymaps = set_keymaps,
  setup = function()
    require('nvim-treesitter').define_modules({
      fold_treesiter = {
        attach = function(buf, lang)
          -- Options set only for buffers with treesitter parser
          vim.opt_local.foldmethod = 'expr'
          vim.opt_local.foldexpr = 'nvim_treesitter#foldexpr()'
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
            [']b'] = { query = '@block.*', desc = '[TS] Next block start' },
            [']C'] = { query = '@comment.outer', desc = '[TS] Next comment start' }
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
            [']B'] = { query = '@block.outer', desc = '[TS] Next block end' },
          },
          goto_previous_start = {
            ['[m'] = { query = '@function.outer', desc = '[TS] Previous function start' },
            ['[['] = { query = '@class.outer', desc = '[TS] Previous class start' },
            ['[b'] = { query = '@block.*', desc = '[TS] Previous block start' },
            ['[C'] = { query = '@comment.outer', desc = '[TS] Previous comment start' }
          },
          goto_previous_end = {
            ['[M'] = { query = '@function.outer', desc = '[TS] Previous function end' },
            ['[]'] = { query = '@class.outer', desc = '[TS] Previous class end' },
            ['[B'] = { query = '@block.outer', desc = '[TS] Previous block end' },
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
