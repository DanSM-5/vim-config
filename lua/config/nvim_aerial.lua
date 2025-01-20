return {
  setup = function()
    require('aerial').setup({
      on_attach = function(bufnr)
        -- Old mapping setup
        -- vim.keymap.set('n', '[a', '<cmd>AerialPrev<CR>', { buffer = bufnr })
        -- vim.keymap.set('n', ']a', '<cmd>AerialNext<CR>', { buffer = bufnr })
        local repeat_pair = require('utils.repeat_motion').repeat_pair

        -- Move using aerial
        local aerial_next = function()
          vim.cmd('AerialNext')
        end
        local aerial_prev = function()
          vim.cmd('AerialPrev')
        end


        vim.keymap.set('n', '<leader>ss', '<cmd>AerialToggle<cr>', { desc = '[Aerial] Toggle window', noremap = true, buffer = bufnr })
        vim.keymap.set('n', '<leader>sS', '<cmd>AerialToggle!<cr>', { desc = '[Aerial] Toggle window no move', noremap = true, buffer = bufnr })
        vim.keymap.set(
          'n',
          '<leader>fa',
          '<cmd>call aerial#fzf()<cr>',
          { desc = '[Aerial] Aerial fzf selector', noremap = true, buffer = bufnr }
        )

        repeat_pair({
          keys = 'a',
          desc_forward = '[Aerial] Move to next symbol',
          desc_backward = '[Aerial] Move to previous symbol',
          on_forward = aerial_next,
          on_backward = aerial_prev,
          bufnr = bufnr,
        })
      end,
    })
  end,
}

