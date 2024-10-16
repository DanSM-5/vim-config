-- Manual lsp-config
-- This runs when loading lsp from VimPlug

-- https://github.com/DanSM-5/vim-config
-- Setup the lsp config
-- See: `:help lspconfig-setup`
-- local lspconfig = require('lspconfig')
-- lspconfig.lua_ls.setup({})

---@class CompletionsOpts
---@field enable { lazydev: boolean; crates: boolean }

---@class LspSetupOpts
---@field completions CompletionsOpts

---@type LspSetupOpts
local defaultLspSetupOpts = {
  completions = {
    enable = {
      lazydev = false,
      crates = false,
    },
  },
}

return {
  ---Options when setting lsp features
  ---@param opts LspSetupOpts | nil
  setup = function(opts)
    ---@type LspSetupOpts
    opts = vim.tbl_deep_extend('force', defaultLspSetupOpts, opts or {})
    local manual_setup = vim.g.is_termux == 1 or vim.env.IS_FROM_CONTAINER == 'true'
    local language_servers = manual_setup and {}
      or {
        'lua_ls',
        'vimls',
        -- 'biome',
        'bashls',
        'ts_ls',
      }

    -- Setup lsp servers
    require('config.nvim_lspconfig').setup()

    -- Buffer information
    -- See `:help vim.lsp.buf`

    -- NOTE: For css-variable set the global variable files with
    -- vim.g.css_variables_files = { 'variables.css', 'other/path' }

    local sources = {
      { name = 'nvim_lsp' },
      { name = 'css-variables' },
      { name = 'nvim_lsp_signature_help' },
    }
    local cmp = require('cmp')
    local cmp_lsp = require('cmp_nvim_lsp')
    local luasnip = require('luasnip')
    local capabilities =
      vim.tbl_deep_extend('force', {}, vim.lsp.protocol.make_client_capabilities(), cmp_lsp.default_capabilities())
    local cmp_select = { behavior = cmp.SelectBehavior.Replace }

    if opts.completions.enable.lazydev then
      table.insert(sources, {
        name = 'lazydev',
        group_index = 0, -- set group index to 0 to skip loading LuaLS completions
      })
    end

    -- if opts.completions.enable.crates then
    --   table.insert(sources, { name = 'crates' })
    -- end

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
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<S-up>'] = cmp.mapping.scroll_docs(-4),
        ['<S-down>'] = cmp.mapping.scroll_docs(4),
        ['<C-e>'] = cmp.mapping.abort(),
        -- <c-l> will move you to the right of each of the expansion locations.
        -- <c-h> is similar, except moving you backwards.
        ['<C-l>'] = cmp.mapping(function()
          if luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          end
        end, { 'i', 's' }),
        ['<C-h>'] = cmp.mapping(function()
          if luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          end
        end, { 'i', 's' }),
        -- ['<CR>'] = cmp.mapping.confirm({ select = true }),
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
        ['<CR>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            if luasnip.expandable() then
              luasnip.expand()
            else
              cmp.confirm({
                select = true,
              })
            end
          else
            fallback()
          end
        end),

        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.locally_jumpable(1) then
            luasnip.jump(1)
          else
            fallback()
          end
        end, { 'i', 's' }),

        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { 'i', 's' }),
      }),
    })

    require('luasnip.loaders.from_vscode').lazy_load()

    ---@param server_name string
    local lspconfig_handler = function(server_name)
      -- Prevent mason-lspconfig from trying to start the LSP server
      -- for rust_analyzer. This is done through mrcjkb/rustaceanvim plugin
      if server_name == 'rust_analyzer' then
        return
      end

      local base_config = require('lsp-servers.config').get_config()[server_name] or {}
      local config = vim.tbl_deep_extend('force', {}, base_config, { capabilities = capabilities })
      require('lspconfig')[server_name].setup(config)
    end

    local mason_lspconfig_opts = {
      ensure_installed = language_servers,
      handlers = {
        lspconfig_handler,
      },
    }

    -- Setup mason_lspconfig to activate lsp servers
    -- automatically
    local mason_lsp = require('mason-lspconfig')
    mason_lsp.setup(mason_lspconfig_opts)

    local none_ls = require('null-ls')
    none_ls.setup({
      sources = {
        none_ls.builtins.formatting.stylua,
        -- none_ls.builtins.formatting.eslint,
        -- none_ls.builtins.diagnostics.prettier,
      },
    })

    -- Completes words in buffer, paths and snippets
    -- not in mason, so call it manually
    if vim.fn.executable('basics-language-server') == 1 then
      lspconfig_handler('basics_ls')
    end

    if manual_setup then
      require('lsp-servers.lsp_manual_config').setup({
        lspconfig_handler = lspconfig_handler,
      })
    end
  end,
}
