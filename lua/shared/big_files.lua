local autocmd = vim.api.nvim_create_autocmd
local autogroup = vim.api.nvim_create_augroup
local FIVE_HUNDRED_K = 1024 * 500

return {
  setup = function()
    -- Disable certain features when opening large files
    local big_file = autogroup('BigFile', { clear = true })
    vim.filetype.add({
      pattern = {
        ['.*'] = {
          function(path, buf)
            return vim.bo[buf]
                and vim.bo[buf].filetype ~= 'bigfile'
                and path
                and vim.fn.getfsize(path) > FIVE_HUNDRED_K
                and 'bigfile'
              or nil -- bigger than 500KB
          end,
        },
      },
    })

    autocmd({ 'FileType' }, {
      group = big_file,
      pattern = 'bigfile',
      ---Turn off features that affect working in big files
      ---@param ev { buf: number }
      callback = function(ev)
        vim.cmd(
          'echohl WarningMsg | echo "Warnging: Big file detected (buffer '
            .. ev.buf
            .. '), disabling features..." | echohl None'
        )
        vim.cmd('syntax off')
        vim.cmd('Gitsigns detach')

        -- Turn off all lsp clients in buffer
        local clients = vim.lsp.get_clients({ bufnr = ev.buf })
        for _, client in ipairs(clients) do
          vim.lsp.buf_detach_client(ev.buf, client.id)
        end

        -- vim.opt_local.foldmethod = 'manual'
        -- vim.opt_local.spell = false
        -- vim.schedule(function()
        --   vim.bo[ev.buf].syntax = vim.filetype.match({ buf = ev.buf }) or ''
        -- end)
      end,
    })
  end,
}
