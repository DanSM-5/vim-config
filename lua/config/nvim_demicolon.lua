return {
  setup = function()
    -- initialize
    require('demicolon').setup({})

    vim.api.nvim_create_autocmd('VimEnter', {
      desc = 'Create repeatable bindings',
      pattern = { '*' },
      callback = function()
        local nxo = { 'n', 'x', 'o' }
        local repeat_pair = require('utils.repeat_motion').repeat_pair

        -- Jump to next conflict
        local jumpconflict_next = function()
          vim.cmd([[execute "normal \<Plug>JumpconflictContextNext"]])
        end
        local jumpconflict_prev = function()
          vim.cmd([[execute "normal \<Plug>JumpconflictContextPrevious"]])
        end
        vim.keymap.set(
          'n',
          ']n',
          repeat_pair({ forward = true, on_backward = jumpconflict_prev, on_forward = jumpconflict_next }),
          { desc = '[JumpConflict] Move to next conflict marker', noremap = true }
        )
        vim.keymap.set(
          'n',
          '[n',
          repeat_pair({ forward = false, on_backward = jumpconflict_prev, on_forward = jumpconflict_next }),
          { desc = '[JumpConflic] Move to previous conflict marker', noremap = true }
        )

        -- Move items in quickfix
        local quickfix_next = function()
          vim.cmd('silent! cnext')
        end
        local quickfix_prev = function()
          vim.cmd('silent! cprev')
        end
        vim.keymap.set(
          nxo,
          ']q',
          repeat_pair({ forward = true, on_forward = quickfix_next, on_backward = quickfix_prev }),
          {
            desc = '[Quickfix] Move to next error',
            noremap = true,
          }
        )
        vim.keymap.set(
          nxo,
          '[q',
          repeat_pair({ forward = false, on_forward = quickfix_next, on_backward = quickfix_prev }),
          {
            desc = '[Quickfix] Move to previous error',
            noremap = true,
          }
        )

      end,
    })
  end,
}
