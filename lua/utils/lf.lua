local lf = function()
  -- Store current buffer reference for navigating back
  local curr_buf = vim.api.nvim_get_current_buf()
  local temp = vim.fn.tempname()
  local buf = vim.api.nvim_create_buf(false, true)
  -- Priorities
  -- repository > buffer dir > home directory
  local cwd = vim.fn.GitPath() or vim.fn.expand('%:p:h')
  if not vim.fn.isdirectory(cwd) then
    cwd = vim.fn.FindProjectRoot('.git')
    if not cwd then
      cwd = vim.fn.expand('~')
    end
  end
  pcall(vim.api.nvim_set_option_value, 'filetype', 'lf_buffer', { buf = buf })

  -- Enable insert mode on open
  vim.api.nvim_create_autocmd('BufEnter', {
    buffer = buf,
    callback = function()
      vim.cmd.startinsert()
    end,
  })

  -- For cleanup (if needed)
  -- vim.api.nvim_create_autocmd('TermClose', {
  --   once = true,
  --   buffer = buf,
  --   callback = function ()
  --     -- Term specific cleanup
  --     -- vim.fn.feedkeys('i')
  --   end
  -- })

  -- Apend buffer in current window
  vim.api.nvim_win_set_buf(0, buf)
  -- Run termopen on the context of the created buffer
  vim.api.nvim_buf_call(buf, function()
    vim.fn.termopen({ 'lf', '-selection-path=' .. temp }, {
      cwd = cwd,
      on_exit = function(jobId, code, evt)
        -- NOTE: when closing without selection we need to
        -- move to a different buffer to avoid afecting
        -- the window layout.
        local on_no_selection = function ()
          -- Needed to remove "[Process exited 0]"
          -- vim.fn.feedkeys('i')

          -- Check if buffer from where LF open is still available
          -- and go back to it. Fallback to :bnext otherwise.
          if vim.api.nvim_buf_is_loaded(curr_buf) then
            vim.cmd.buffer(curr_buf)
          else
            vim.cmd.bnext()
          end
        end

        local ok_fileredable = pcall(vim.fn.filereadable, temp)
        if not ok_fileredable then
          on_no_selection()
          return
        end

        local ok_names, names = pcall(vim.fn.readfile, temp)

        if not ok_names then
          on_no_selection()
          return
        end

        if #names == 0 then
          on_no_selection()
          return
        end

        for i = 1, #names do
          if i == 1 then
            vim.fn.execute('edit ' .. vim.fn.fnameescape(names[i]))
          else
            vim.fn.execute('argadd ' .. vim.fn.fnameescape(names[i]))
          end
        end
      end,
    })
  end)
end

return {
  lf = lf,
}

