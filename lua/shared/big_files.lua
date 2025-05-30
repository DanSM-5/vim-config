local BIG_FILE_SIZE = 1.5 * 1024 * 1024 -- 1.5MB
local FILETYPE = 'bigfile'

return {
  load = function()
    -- Disable certain features when opening large files
    local big_file = vim.api.nvim_create_augroup('BigFile', { clear = true })
    vim.filetype.add({
      pattern = {
        ['.*'] = {
          function(path, buf)
            return vim.bo[buf]
                and vim.bo[buf].filetype ~= FILETYPE
                and path
                and vim.fn.getfsize(path) > BIG_FILE_SIZE
                and FILETYPE
              or nil -- bigger than 500KB
          end,
        },
      },
    })

    vim.api.nvim_create_autocmd({ 'FileType' }, {
      group = big_file,
      pattern = FILETYPE,
      ---Turn off features that affect working in big files
      ---@param evt { buf: number }
      callback = function(evt)
        local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(evt.buf), ':p:~:.')
        vim.notify(('Warnging: Big file detected: "%s"'):format(path), vim.log.levels.WARN)

        -- Detach gitsigns
        local ok_signs, signs = pcall(require, 'gitsigns.attach')
        if ok_signs then
          signs.detach(evt.buf)
        end

        vim.api.nvim_buf_call(evt.buf, function ()
          -- Disable treesitter
          if vim.fn.exists(':TSBufDisable') then
            vim.cmd.TSBufDisable('highlight ' .. evt.buf)
          end
          -- vim.cmd('syntax off')
          local ft = vim.filetype.match({ buf = evt.buf }) or ''
          vim.schedule(function ()
            vim.bo[evt.buf].syntax = ft
          end)
          -- Turn off all lsp clients in buffer
          local clients = vim.lsp.get_clients({ bufnr = evt.buf })
          for _, client in ipairs(clients) do
            vim.lsp.buf_detach_client(evt.buf, client.id)
          end
        end)

        -- vim.opt_local.foldmethod = 'manual'
        -- vim.opt_local.spell = false
        -- vim.schedule(function()
        --   vim.bo[ev.buf].syntax = vim.filetype.match({ buf = ev.buf }) or ''
        -- end)
      end,
    })
  end,
}

