local lf = function()
  local temp = vim.fn.tempname()
  local buf = vim.api.nvim_create_buf(false, true)
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

  -- vim.api.nvim_create_autocmd('TermClose', {
  --   once = true,
  --   buffer = buf,
  --   callback = function ()
  --     -- Term specific cleanup
  --     -- vim.fn.feedkeys('i')
  --   end
  -- })

  vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_buf_call(buf, function()
    vim.fn.termopen({ 'lf', '-selection-path=' .. temp }, {
      cwd = cwd,
      on_exit = function(jobId, code, evt)
        local ok_fileredable = pcall(vim.fn.filereadable, temp)
        if not ok_fileredable then
          -- Needed to remove "[Process exited 0]"
          vim.fn.feedkeys('i')
          return
        end

        local ok_names, names = pcall(vim.fn.readfile, temp)

        if not ok_names then
          -- Needed to remove "[Process exited 0]"
          vim.fn.feedkeys('i')
          return
        end

        vim.print(names)

        if #names == 0 then
          -- Needed to remove "[Process exited 0]"
          vim.fn.feedkeys('i')
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

