require('lsp-servers.types')

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
  -- nvim_lua = '[Lua]',
  -- latex_symbols = '[LaTeX]',
  ['css-variables'] = '[CssVar]',
  nvim_lsp_signature_help = '[LspSignature]',
  rg = '[RipGrep]',
  git = '[Git]',
}

local cmp_format = function (entry, vim_item)
  if vim.tbl_contains({ 'path' }, entry.source.name) then
    local icon, hl_group = require('nvim-web-devicons').get_icon(entry:get_completion_item().label)
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

return {
  ---@type config.ConfigureCompletion
  configure = function(opts)
    -- NOTE: For css-variable set the global variable files with
    -- vim.g.css_variables_files = { 'variables.css', 'other/path' }

    local sources = {
      { name = 'nvim_lsp' },
      { name = 'css-variables' },
      { name = 'nvim_lsp_signature_help' },
      { name = 'luasnip' },
      { name = 'git' },
    }
    -- if opts.completions.enable.crates then
    --   table.insert(sources, { name = 'crates' })
    -- end
    local cmp = require('cmp')
    local cmp_lsp = require('cmp_nvim_lsp')
    local capabilities =
      vim.tbl_deep_extend('force', {}, vim.lsp.protocol.make_client_capabilities(), cmp_lsp.default_capabilities())

    -- Add ripgrep source if binary is available
    if vim.fn.executable('rg') then
      table.insert(sources, { name = 'rg', keyword_length = 3 })
    end

    if opts.lazydev then
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
        if require('luasnip').expand_or_locally_jumpable() then
          require('luasnip').expand_or_jump()
        end
      end, { 'i', 's' }),
      ['<C-h>'] = cmp.mapping(function()
        if require('luasnip').locally_jumpable(-1) then
          require('luasnip').jump(-1)
        end
      end, { 'i', 's' }),
      -- ['C-k'] = cmp.mapping(function ()
      --   if require('luasnip').expand_or_jumpable() then
      --     require('luasnip').expand_or_jump()
      --   end
      -- end, { 'i', 's' }),
      -- ['C-j'] = cmp.mapping(function ()
      --   if require('luasnip').jumpable(-1) then
      --     require('luasnip').jump(-1)
      --   end
      -- end, { 'i', 's' }),
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
          if require('luasnip').expandable() then
            require('luasnip').expand()
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
        elseif require('luasnip').locally_jumpable(1) then
          require('luasnip').jump(1)
        else
          fallback()
        end
      end, { 'i', 's' }),

      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif require('luasnip').locally_jumpable(-1) then
          require('luasnip').jump(-1)
        else
          fallback()
        end
      end, { 'i', 's' }),
    })

    cmp.setup({
      sources = sources,
      mapping = cmp_mappings,
      view = {
        entries = { name = 'custom', selection_order = 'near_cursor' }
      },
      formatting = {
        format = cmp_format
      },
      snippet = {
        expand = function (args)
          require('luasnip').lsp_expand(args.body)
        end
      }
    })

    require('cmp_git').setup()
    require('luasnip.loaders.from_vscode').lazy_load()

    ---@type config.UpdateCapabilities
    local update_capabilities = function (base)
      if base.capabilities then
        local config = vim.tbl_deep_extend('force', base, {
          capabilities = vim.tbl_deep_extend('force', {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities(base.capabilities))
        })

        return config
      end

      local config = vim.tbl_deep_extend('force', {}, base, { capabilities = capabilities })

      return config
    end

    return update_capabilities
  end
}
