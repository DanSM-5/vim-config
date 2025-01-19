require('lsp-servers.types')

---@type config.CompletionModule
local blink_module = {
  ---@type config.ConfigureCompletion
  configure = function (opts)
    local blink_sources_default = {
      'lsp',
      'snippets',
      'css-variables',
      'git',
      -- TODO: Check if keep
      'buffer',
      'path',
    }
    -- local blink_sources_completion = {
    --   enabled_providers = {
    --     'lsp',
    --     'snippets',
    --     -- 'css-variables',
    --     -- 'git',
    --   },
    -- }
    local blink_sources_providers = {
      lsp = {
        min_keyword_length = 2,
        score_offset = 5,
      },
      snippets = {
        min_keyword_length = 2,
      },
      ['css-variables'] = {
        name = 'css-variables',
        module = 'blink.compat.source',
      },
      git = {
        name = 'git',
        module = 'blink.compat.source',
        min_keyword_length = 0,
      },
    }


    local blink_kind_icon = {
      width = { fill = true }
    }

    local has_color_hl, nvim_hl_color = pcall(require, 'nvim-highlight-colors')
    if has_color_hl then
      blink_kind_icon.text = function(ctx)
        -- default kind icon
        local icon = ctx.kind_icon
        -- if LSP source, check for color derived from documentation
        if ctx.item.source_name == 'LSP' then
          local color_item = nvim_hl_color.format(ctx.item.documentation, { kind = ctx.kind })
          if color_item and color_item.abbr then
            icon = color_item.abbr
          end
        end
        return icon .. ctx.icon_gap
      end
      blink_kind_icon.highlight = function(ctx)
        -- default highlight group
        local highlight = 'BlinkCmpKind' .. ctx.kind
        -- if LSP source, check for color derived from documentation
        if ctx.item.source_name == 'LSP' then
          local color_item = nvim_hl_color.format(ctx.item.documentation, { kind = ctx.kind })
          if color_item and color_item.abbr_hl_group then
            highlight = color_item.abbr_hl_group
          end
        end
        return highlight
      end
    end

    if os.getenv('START_DB') == '1' then
      table.insert(blink_sources_default, 'dadbod')
      blink_sources_providers.dadbod = { name = 'Dadbod', module = 'vim_dadbod_completion.blink' }
    end

    -- if opts.completions.enable.crates then
    --   table.insert(blink_sources_default, 'crates')
    -- end
    require('blink-compat').setup({})
    local blink = require('blink.cmp')

    -- if opts.crates then
    --   table.insert(blink_sources_default, 'crates')
    -- end
    require('blink-compat').setup({})
    require('cmp_git').setup({})
    require('luasnip.loaders.from_vscode').lazy_load()

    -- Add ripgrep source if binary is available
    if vim.fn.executable('rg') then
      -- table.insert(blink_sources_completion.enabled_providers, { 'ripgrep' })
      table.insert(blink_sources_default, 'ripgrep')
      blink_sources_providers.ripgrep = {
        module = 'blink-ripgrep',
        name = 'Ripgrep',
        -- the options below are optional, some default values are shown
        ---@module 'blink-ripgrep'
        ---@type blink-ripgrep.Options
        opts = {
          -- For many options, see `rg --help` for an exact description of
          -- the values that ripgrep expects.

          -- the minimum length of the current word to start searching
          -- (if the word is shorter than this, the search will not start)
          prefix_min_len = 3,

          -- The number of lines to show around each match in the preview
          -- (documentation) window. For example, 5 means to show 5 lines
          -- before, then the match, and another 5 lines after the match.
          context_size = 5,

          -- The maximum file size of a file that ripgrep should include in
          -- its search. Useful when your project contains large files that
          -- might cause performance issues.
          -- Examples:
          -- "1024" (bytes by default), "200K", "1M", "1G", which will
          -- exclude files larger than that size.
          max_filesize = '2M',

          -- (advanced) Any additional options you want to give to ripgrep.
          -- See `rg -h` for a list of all available options. Might be
          -- helpful in adjusting performance in specific situations.
          -- If you have an idea for a default, please open an issue!
          --
          -- Not everything will work (obviously).
          additional_rg_options = {},
        },
      }
    end

    if opts.lazydev then
      blink_sources_providers.lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', fallbacks = { 'lsp' } }
      table.insert(blink_sources_default, 'lazydev')
    end

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    local blink_opts = {
      -- 'default' for mappings similar to built-in completion
      -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
      -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
      -- see the "default configuration" section below for full documentation on how to define
      -- your own keymap.
      keymap = {
        preset = 'enter',
        -- preset = 'default',
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
        ['<C-e>'] = { 'hide' },
        ['<C-y>'] = { 'select_and_accept' },
        ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
        ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
        ['<C-/>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-Space>'] = { 'select_and_accept' },
        ['<S-up>'] = { 'scroll_documentation_up', 'fallback' },
        ['<S-down>'] = { 'scroll_documentation_down', 'fallback' },
        ['<C-l>'] = { 'snippet_forward', 'fallback' },
        ['<C-h>'] = { 'snippet_backward', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
        -- ['<c-g>'] = {
        --   function()
        --     -- invoke manually, requires blink >v0.7.6
        --     require('blink-cmp').show({ sources = { 'ripgrep' } })
        --   end,
        -- },
      },
      appearance = {
        -- Sets the fallback highlight groups to nvim-cmp's highlight groups
        -- Useful for when your theme doesn't support blink.cmp
        -- will be removed in a future release
        use_nvim_cmp_as_default = true,
        -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
        kind_icons = {
          Text = '󰉿',
          Method = '󰆧',
          Function = '󰊕',
          Constructor = '󰒓',

          Field = '󰜢',
          Variable = '󰆦',
          Property = '󰖷',

          Class = '󰠱',
          Interface = '',
          Struct = '',
          Module = '󰅩',

          Unit = '󰪚',
          Value = '󰎠',
          Enum = '',
          EnumMember = '',

          Keyword = '󰌋',
          Constant = '󰏿',

          Snippet = '󱄽',
          Color = '󰏘',
          File = '󰈙',
          Reference = '󰬲',
          Folder = '󰉋',
          Event = '',
          Operator = '󰪚',
          TypeParameter = '󰬛',
        },
      },

      -- default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, via `opts_extend`
      sources = {
        default = blink_sources_default,
        -- completion = blink_sources_completion,
        providers = blink_sources_providers,

        -- Disabled completion for command line mode
        cmdline = {},
        -- cmdline = function ()
        --   local type = vim.fn.getcmdtype()
        --   -- Return buffer completion when searching
        --   if type == '/' or type == '?' then
        --     return { 'buffer' }
        --   end

        --   -- if type == ':' then
        --   --   return { 'cmdline' }
        --   -- end

        --   -- Disable other completions
        --   -- return { 'cmdline' }
        --   return {}
        -- end,
      },

      -- experimental signature help support
      signature = {
        enabled = true,
        window = { border = 'rounded' },
      },
      snippets = {
        preset = 'luasnip',
        expand = function(snippet) require('luasnip').lsp_expand(snippet) end,
        active = function(filter)
          if filter and filter.direction then
            return require('luasnip').jumpable(filter.direction)
          end
          return require('luasnip').in_snippet()
        end,
        jump = function(direction) require('luasnip').jump(direction) end,

        -- Default
        -- Function to use when expanding LSP provided snippets
        -- expand = function(snippet) vim.snippet.expand(snippet) end,
        -- Function to use when checking if a snippet is active
        -- active = function(filter) return vim.snippet.active(filter) end,
        -- Function to use when jumping between tab stops in a snippet, where direction can be negative or positive
        -- jump = function(direction) vim.snippet.jump(direction) end,
      },

      -- Example for blocking multiple filetypes
      -- enabled = function()
      --  return not vim.tbl_contains({ "lua", "markdown" }, vim.bo.filetype)
      --    and vim.bo.buftype ~= "prompt"
      --    and vim.b.completion ~= false
      -- end,

      completion = {
        -- NOTE: Currently causes issues
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 250,
          treesitter_highlighting = true,
          window = { border = 'rounded' },
        },
        -- list = {
        --   ---Selection of completion for blink
        --   ---@param ctx { mode: string }
        --   ---@return 'auto_insert' | 'preselect' | 'manual'
        --   selection = function (ctx)
        --     return ctx.mode == 'cmdline' and 'auto_insert' or 'preselect'
        --   end,
        -- },
        menu = {
          border = 'rounded',
          draw = {
            padding = { 1, 1 },
            columns = {
              { 'label', 'label_description', gap = 1 },
              { 'kind_icon', 'kind', gap = 1 },
              { 'source_name' },
            },
            components = {
              kind_icon = blink_kind_icon,
            },
          },
        },
      },
    }

    blink.setup(blink_opts)
  end,

  get_update_capabilities = function ()
    local blink = require('blink.cmp')
    local capabilities =
      vim.tbl_deep_extend('force', {}, vim.lsp.protocol.make_client_capabilities(), blink.get_lsp_capabilities())

    ---Update capabilities of base config
    ---@param base LspConfigExtended
    ---@return LspConfigExtended
    local function update_capabilities(base)
      local config = vim.tbl_deep_extend('force', {}, base, {
        capabilities = base.capabilities and blink.get_lsp_capabilities(base.capabilities) or capabilities
      })

      return config
    end
    return update_capabilities
  end
}

return blink_module

