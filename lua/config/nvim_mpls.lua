return {
  config = function ()
    local configs = require('lspconfig.configs')
    if not configs.mpls then
      configs.mpls = {
        default_config = {
          cmd = { 'mpls', '--dark-mode', '--enable-emoji' },
          filetypes = { 'markdown' },
          single_file_support = true,
          root_dir = function (startpath)
            -- require("lspconfig").util.find_git_ancestor,
            return vim.fs.dirname(vim.fs.find('.git', { path = startpath, upward = true })[1])
          end,
          settings = {},
        },
        docs = {
          description = [[https://github.com/mhersson/mpls

Markdown Preview Language Server (MPLS) is a language server that provides
live preview of markdown files in your browser while you edit them in your favorite editor.
          ]],
        },
      }
    end

    ---Auto command for starting MPLS
    ---@param opts { bang: boolean }
    vim.api.nvim_create_user_command('MPLS', function (opts)

      -- Prevent running if client does not exist
      if vim.fn.executable('mpls') == 0 then
        return
      end

      -- Set automatically for next buffers
      vim.g.SetupLsp('mpls')

      -- If start with bang, do not try to attach buffer
      if opts.bang then
        return
      end

      -- Start client if current buffer is markdown
      local bufnr = vim.api.nvim_get_current_buf()
      local curr_buff_ft = vim.api.nvim_get_option_value('filetype', { buf = bufnr })
      local base_config = require('lsp-servers.config').get_config('mpls') or {}
      if curr_buff_ft == 'markdown' then
        -- Try to gess root dir
        local root_dir = vim.fs.dirname(vim.fs.find('.git', { path = vim.fn.expand('%:p:h'), upward = true })[1]) or vim.fn.expand('%:p:h')
        -- Start lsp on buffer
        local client_id = vim.lsp.start(
          vim.tbl_deep_extend('force', {
            cmd = { 'mpls', '--dark-mode', '--enable-emoji' },
            filetypes = { 'markdown' },
            single_file_support = true,
            root_dir = root_dir,
            settings = {},
            on_attach = require('lsp-servers.keymaps').set_lsp_keys
          }, base_config)
        , {
            bufnr = bufnr,
            silent = false,
            reuse_client = function () return false end
        })

        -- Attach to client
        if client_id ~= nil then
          vim.lsp.buf_attach_client(bufnr, client_id)
          vim.notify('[MPLS] bufnr: '..bufnr..' client: '..client_id, vim.log.levels.INFO)
        end
      end
    end, { desc = '[Lsp] Start mpls lsp server', bar = true, bang = true, nargs = 0 })
  end
}
