return {
  setup = function()
    require('aerial').setup({
      on_attach = function(bufnr)
        -- Old mapping setup
        -- vim.keymap.set('n', '[a', '<cmd>AerialPrev<CR>', { buffer = bufnr })
        -- vim.keymap.set('n', ']a', '<cmd>AerialNext<CR>', { buffer = bufnr })
        local nxo = { 'n', 'x', 'o' }
        local repeat_pair = require('utils.repeat_motion').repeat_pair

        -- Move using aerial
        local aerial_next = function()
          vim.cmd('AerialNext')
        end
        local aerial_prev = function()
          vim.cmd('AerialPrev')
        end
        vim.keymap.set(
          nxo,
          ']a',
          repeat_pair({ forward = true, on_forward = aerial_next, on_backward = aerial_prev }),
          {
            desc = '[Aerial] Move to next symbol',
            noremap = true,
          }
        )
        vim.keymap.set(
          nxo,
          '[a',
          repeat_pair({ forward = false, on_forward = aerial_next, on_backward = aerial_prev }),
          {
            desc = '[Aerial] Move to previous symbol',
            noremap = true,
          }
        )
      end,
    })

    vim.keymap.set('n', '<leader>ta', '<cmd>AerialToggle!<cr>', { desc = '[Aerial] Toggle window', noremap = true })
    vim.keymap.set('n', '<leader>fa', '<cmd>call aerial#fzf()<cr>', { desc = '[Aerial] Aerial fzf selector', noremap = true })
  end,
}
