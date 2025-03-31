local set_keymaps = function(bufnr)
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

  vim.keymap.set(
    'n',
    '<leader>ss',
    '<cmd>AerialToggle<cr>',
    { desc = '[Aerial] Toggle window', noremap = true, buffer = bufnr }
  )
  vim.keymap.set(
    'n',
    '<leader>sS',
    '<cmd>AerialToggle!<cr>',
    { desc = '[Aerial] Toggle window no move', noremap = true, buffer = bufnr }
  )
  vim.keymap.set(
    'n',
    '<leader>fa',
    '<cmd>call aerial#fzf()<cr>',
    { desc = '[Aerial] Aerial fzf selector', noremap = true, buffer = bufnr }
  )

  repeat_pair({
    keys = 'S',
    desc_forward = '[Aerial] Move to next symbol',
    desc_backward = '[Aerial] Move to previous symbol',
    on_forward = aerial_next,
    on_backward = aerial_prev,
    bufnr = bufnr,
  })
end

return {
  set_keymaps = set_keymaps,
  setup = function()
    local aerial_group = vim.api.nvim_create_augroup('aerial', { clear = true })
    vim.api.nvim_create_autocmd({ 'FileType' }, {
      group = aerial_group,
      pattern = 'aerial',
      ---Callback for aerial autocmd
      ---@param opts { buf: integer } Options from autocmd
      callback = function(opts)
        vim.keymap.set(
          'n',
          '<leader>ss',
          '<cmd>AerialToggle<cr>',
          {
            desc = '[Aerial] Toggle window',
            noremap = true,
            buffer = opts.buf
          }
        )
      end,
      desc = '[Aerial] Add keymaps to aerial buffer',
    })

    require('aerial').setup({
      on_attach = set_keymaps,
    })
  end,
}

