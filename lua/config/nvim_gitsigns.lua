return {
  setup = function()
    local gitsigns = require('gitsigns')

    -- Quickfix command
    vim.api.nvim_create_user_command('Gqf', function(opts)
      -- NOTE: to use quickfix on buffer only use
      -- :Gitsigns setqflist
      local target = opts.bang and 'attached' or 'all'
      gitsigns.setqflist(target)
    end, { bang = true, bar = true })

    -- Set mappings
    gitsigns.setup({
      -- Enable debug logs
      -- debug_mode = true,

      -- Set to above diagnostic signs (10) so that in multi
      -- sign column setups (2 or more), the hunk sing does not
      -- misalign with the rest of the hunk by being pushed right.
      sign_priority = 11, -- defaults to 6
      on_attach = function(bufnr)
        -- Navigation
        -- vim.keymap.set('n', '<space>nh', gitsigns.next_hunk, { desc = 'Gitsigns: Go to next hunk', buffer = bufnr })
        -- vim.keymap.set('n', '<space>nH', gitsigns.prev_hunk, { desc = 'Gitsigns: Go to previous hunk', buffer = bufnr })
        -- NOTE: Commented in favor of repeatable keybindings
        -- vim.keymap.set('n', ']g', gitsigns.next_hunk, { desc = 'Gitsigns: Go to next hunk', buffer = bufnr })
        -- vim.keymap.set('n', '[g', gitsigns.prev_hunk, { desc = 'Gitsigns: Go to previous hunk', buffer = bufnr })

        -- Actions
        vim.keymap.set('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'Gitsigns: Stage hunk', buffer = bufnr })
        vim.keymap.set('v', '<leader>hs', function()
          gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, { desc = 'Gitsigns: Stage hunk', buffer = bufnr })
        vim.keymap.set('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'Gitsigns: Stage buffer', buffer = bufnr })
        vim.keymap.set('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'Gitsigns: Reset hunk', buffer = bufnr })
        vim.keymap.set('v', '<leader>hr', function()
          gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, { desc = 'Gitsigns: Reset hunk', buffer = bufnr })
        vim.keymap.set('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'Gitsigns: Reset buffer', buffer = bufnr })
        -- Keep until removed
        vim.keymap.set(
          'n',
          '<leader>hu',
          gitsigns.undo_stage_hunk,
          { desc = 'Gitsigns: Undo stage hunk', buffer = bufnr }
        )
        vim.keymap.set('v', '<leader>hu', function()
          -- Call stage_hunk on staged signs
          gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, { desc = 'Gitsigns: Undo stage hunk', buffer = bufnr })
        vim.keymap.set(
          'n',
          '<leader>hU',
          gitsigns.reset_buffer_index,
          { desc = 'Gitsigns: Undo stage hunk', buffer = bufnr }
        )
        vim.keymap.set(
          'n',
          '<leader>hp',
          gitsigns.preview_hunk,
          { desc = 'Gitsigns: Preview hunk, repeat to enter preview window', buffer = bufnr }
        )
        vim.keymap.set('n', '<leader>hb', function()
          gitsigns.blame_line({ full = true })
        end, { desc = 'Gitsigns: Blame line', buffer = bufnr })
        vim.keymap.set(
          'n',
          '<leader>hB',
          gitsigns.toggle_current_line_blame,
          { desc = 'Gitsigns: Toggle line blame', buffer = bufnr }
        )
        vim.keymap.set('n', '<leader>hd', gitsigns.diffthis, { desc = 'Gitsigns: Diff hunk', buffer = bufnr })
        vim.keymap.set('n', '<leader>hD', function()
          gitsigns.diffthis('~')
        end, { desc = 'Gitsigns: Diff all', buffer = bufnr })
        vim.keymap.set(
          'n',
          '<leader>td',
          gitsigns.preview_hunk_inline,
          { desc = 'Gitsigns: Toggle deleted hunk', buffer = bufnr }
        )
        -- Text object
        vim.keymap.set(
          { 'o', 'x' },
          'ih',
          ':<C-U>Gitsigns select_hunk<CR>',
          { desc = 'Gitsigns: Text object inner hunk', buffer = bufnr }
        )
      end,
    })
  end,
}
