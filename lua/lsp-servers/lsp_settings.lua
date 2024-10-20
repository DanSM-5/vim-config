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

local kind_icons = {
  Text = "",
  Method = "󰆧",
  Function = "󰊕",
  Constructor = "",
  Field = "󰇽",
  Variable = "󰂡",
  Class = "󰠱",
  Interface = "",
  Module = "",
  Property = "󰜢",
  Unit = "",
  Value = "󰎠",
  Enum = "",
  Keyword = "󰌋",
  Snippet = "",
  Color = "󰏘",
  File = "󰈙",
  Reference = "",
  Folder = "󰉋",
  EnumMember = "",
  Constant = "󰏿",
  Struct = "",
  Event = "",
  Operator = "󰆕",
  TypeParameter = "󰅲",
}

local cmp_formatting_menu = {
  buffer = '[Buffer]',
  nvim_lsp = '[LSP]',
  luasnip = '[LuaSnip]',
  nvim_lua = '[Lua]',
  latex_symbols = '[LaTeX]',
  ['css-variables'] = '[CssVar]',
  nvim_lsp_signature_help = '[LspSignature]',
}

local get_cmp_format = function ()
  local get_icon = require('nvim-web-devicons').get_icon

  return function (entry, vim_item)
    if vim.tbl_contains({ 'path' }, entry.source.name) then
      local icon, hl_group = get_icon(entry:get_completion_item().label)
      if icon then
        vim_item.kind = icon
        vim_item.kind_hl_group = hl_group
        return vim_item
      end
    end

    -- Kind icons
    vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatenates the icons with the name of the item kind
    -- Source
    vim_item.menu = cmp_formatting_menu[entry.source.name] or '[Unknown]'
    return vim_item
  end
end

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
    -- if opts.completions.enable.crates then
    --   table.insert(sources, { name = 'crates' })
    -- end

    local cmp = require('cmp')
    local cmp_lsp = require('cmp_nvim_lsp')
    local luasnip = require('luasnip')
    local capabilities =
      vim.tbl_deep_extend('force', {}, vim.lsp.protocol.make_client_capabilities(), cmp_lsp.default_capabilities())

    if opts.completions.enable.lazydev then
      table.insert(sources, {
        name = 'lazydev',
        group_index = 0, -- set group index to 0 to skip loading LuaLS completions
      })
    end

    -- local has_words_before = function()
    --   unpack = unpack or table.unpack
    --   local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    --   return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
    -- end

    local cmp_select = { behavior = cmp.SelectBehavior.Replace }
    local cmp_mappings = cmp.mapping.preset.insert({
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
    })

    local cmp_format = get_cmp_format()

    cmp.setup({
      sources = sources,
      mapping = cmp_mappings,
      view = {
        entries = { name = 'custom', selection_order = 'near_cursor' }
      },
      formatting = {
        format = cmp_format
      }
    })

    require('luasnip.loaders.from_vscode').lazy_load()

    ---@param server_name string
    local lspconfig_handler = function(server_name)
      -- Prevent mason-lspconfig from trying to start the LSP server
      -- for rust_analyzer. This is done through mrcjkb/rustaceanvim plugin
      if server_name == 'rust_analyzer' then
        return
      end

      local base_config = require('lsp-servers.config').get_config(server_name) or {}
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
      -- WARN: basics_ls attaches to all buffers which could cause issues due to additional keybindings
      -- Exclusions can be added in `./lua/lsp-servers/keymaps.lua`
      lspconfig_handler('basics_ls')
    end

    -- Configure aerial.nvim
    require('config.nvim_aerial').setup()

    if manual_setup then
      require('lsp-servers.lsp_manual_config').setup({
        lspconfig_handler = lspconfig_handler,
      })
    end
  end,
}
