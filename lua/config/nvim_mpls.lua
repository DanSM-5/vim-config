local name = 'mpls'

return {
  config = function ()
    local configs = require('lspconfig.configs')
    if not configs.mpls then
      configs.mpls = {
        default_config = {
          name = name,
          cmd = { name, '--dark-mode', '--enable-emoji' },
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
      if vim.fn.executable(name) == 0 then
        return
      end

      -- Set automatically for next buffers
      require('lsp-servers.lsp_settings')
        .get_lsp_handler()(name)

      -- If start with bang, do not try to attach buffer
      if opts.bang then
        return
      end

      -- Start client if current buffer is markdown
      local bufnr = vim.api.nvim_get_current_buf()
      local curr_buff_ft = vim.api.nvim_get_option_value('filetype', { buf = bufnr })

      -- Continue only if in a markdown buffer
      if curr_buff_ft ~= 'markdown' then
        return
      end

      local base_config = require('lsp-servers.config').get_config(name) or {}
      local update_capabilities = require('lsp-servers.lsp_settings')
        .get_completion_module_from_settings()
        .get_update_capabilities()
      local lsp_config = update_capabilities(base_config)
      -- Try to gess root dir
      local root_dir = vim.fs.dirname(vim.fs.find('.git', { path = vim.fn.expand('%:p:h'), upward = true })[1]) or vim.fn.expand('%:p:h')
      -- Start lsp on buffer
      local client_id = vim.lsp.start(
        vim.tbl_deep_extend('force', {
          name = name,
          cmd = { name, '--dark-mode', '--enable-emoji' },
          filetypes = { 'markdown' },
          single_file_support = true,
          root_dir = root_dir,
          settings = {},
          on_attach = require('lsp-servers.keymaps').set_lsp_keys
        }, lsp_config)
        , {
          bufnr = bufnr,
          silent = false,
          ---Since this should be the first created client,
          ---no other client should be reused
          ---@param client vim.lsp.Client
          ---@param config vim.lsp.ClientConfig
          ---@return boolean
          reuse_client = function (client, config)
            return client.name == name
          end
        })

      -- Attach to client
      -- Even though bufnr is specified above in the options for vim.lsp.start
      -- it still may not attach the requested buffer, so we add it manually
      if client_id ~= nil then
        vim.lsp.buf_attach_client(bufnr, client_id)
        vim.notify('[MPLS] bufnr: '..bufnr..' client: '..client_id, vim.log.levels.INFO)
      end
    end, { desc = '[Lsp] Start mpls lsp server', bar = true, bang = true, nargs = 0 })
  end,
  download = function ()
    local download_helper = vim.fn.substitute(vim.fn.expand('~/vim-config/utils/download_mpls'), '\\', '/', 'g')
    ---@type string[]
    local cmd = {}
    if vim.fn.has('win32') == 1 then
      -- Use powershell script on windows
      cmd = { 'powershell.exe', '-NoLogo', '-NonInteractive', '-NoProfile', '-File', download_helper .. '.ps1' }
    else
      cmd = { download_helper }
    end

    pcall(vim.system, cmd, {}, function ()
      vim.schedule(function ()
        vim.notify('[MPLS] Download completed', vim.log.levels.INFO)
      end)
    end)
  end,
}

