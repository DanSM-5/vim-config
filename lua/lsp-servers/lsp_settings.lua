-- Manual lsp-config
-- This runs when loading lsp from VimPlug

-- https://github.com/DanSM-5/vim-config
-- Setup the lsp config
-- See: `:help lspconfig-setup`
-- local lspconfig = require('lspconfig')
-- lspconfig.lua_ls.setup({})

return {
  ---Options when setting lsp features
  ---@param opts { enable_lazydev: boolean } | nil
  setup = function(opts)
    opts = opts or {}
    local manual_setup = vim.g.is_termux == 1 or vim.env.IS_FROM_CONTAINER == 'true'
    local language_servers = manual_setup and {} or {
      'lua_ls',
      'vimls',
      'biome',
      'bashls',
      -- 'tsserver'
    }

    -- Setup lsp servers
    require('config.nvim_lspconfig').setup({ manual_setup = manual_setup })

    -- Buffer information
    -- See `:help vim.lsp.buf`

    local sources = {
      { name = 'nvim_lsp' }
    }
    local cmp = require('cmp')
    local cmp_lsp = require('cmp_nvim_lsp')
    local mason_lsp = require('mason-lspconfig')
    local capabilities = vim.tbl_deep_extend(
      'force',
      {},
      vim.lsp.protocol.make_client_capabilities(),
      cmp_lsp.default_capabilities()
    )
    local cmp_select = { behavior = cmp.SelectBehavior.Replace }

    if opts.enable_lazydev then
      table.insert(sources, {
        name = "lazydev",
        group_index = 0, -- set group index to 0 to skip loading LuaLS completions
      })
    end

    -- local has_words_before = function()
    --   unpack = unpack or table.unpack
    --   local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    --   return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
    -- end
    cmp.setup({
      sources = sources,
      mapping = cmp.mapping.preset.insert({
        ['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item(cmp_select), { 'i' }),
        ['<C-n>'] = cmp.mapping(cmp.mapping.select_next_item(cmp_select), { 'i' }),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-e>'] = cmp.mapping.abort(),
        -- ['<Tab>'] = function(fallback)
        --   if not cmp.select_next_item() then
        --     if vim.bo.buftype ~= 'prompt' and has_words_before() then
        --       cmp.complete()
        --     else
        --       fallback()
        --     end
        --   end
        -- end,
        -- ['<S-Tab>'] = function(fallback)
        --   if not cmp.select_prev_item() then
        --     if vim.bo.buftype ~= 'prompt' and has_words_before() then
        --       cmp.complete()
        --     else
        --       fallback()
        --     end
        --   end
        -- end,
      }),
    })

    ---@param server_name string
    local lspconfig_handler = function(server_name)
      local base_config = require('lsp-servers.config').get_config()[server_name] or {}
      local config = vim.tbl_deep_extend('force', {}, base_config, { capabilities = capabilities })
      require('lspconfig')[server_name].setup(config)
    end

    local mason_lspconfig_opts = {
      ensure_installed = language_servers,
      handlers = {
        lspconfig_handler
      }
    }

    -- Setup mason_lspconfig to activate lsp servers
    -- automatically
    mason_lsp.setup(mason_lspconfig_opts)

    if manual_setup then
      require('lsp-servers.lsp_manual_config').setup({
        lspconfig_handler = lspconfig_handler
      })
    end
  end
}