return {
  setup = function ()
    local ai = require('mini.ai')

    -- mini.ai quote textobjects and the treesitter capture family each one
    -- should use when a parser + query are available for the buffer.
    --   "  double quoted   '  single quoted   `  backtick/template
    --   q  smart quote (builtin matches any of ' " `)
    -- A key is only switched to treesitter if the language's `textobjects`
    -- query actually defines the matching `<cap>.outer` capture; otherwise the
    -- builtin (Lua-pattern) quote textobject stays in effect for that key.
    local quote_keys = {
      ['"'] = 'dquote',
      ["'"] = 'squote',
      ['`'] = 'bquote',
      ['q'] = 'string',
    }

    -- mini.ai's builtin (Lua-pattern) spec per quote key -- copied from
    -- `H.builtin_textobjects` in mini.ai's source. Used as the syntax-blind
    -- fallback below: it scans raw buffer text, so it matches quotes nested
    -- inside a comment or a raw/literal string that treesitter cannot see
    -- into (there is no node for them), and quotes of the "wrong" kind
    -- nested inside a string whose node covers the whole span (there is no
    -- separate node for them either -- e.g. a `'...'` phrase inside a JS/Lua
    -- `"..."` string, where both quote kinds share one `string` node).
    local quote_patterns = {
      ['"'] = { '%b""', '^.().*().$' },
      ["'"] = { "%b''", '^.().*().$' },
      ['`'] = { '%b``', '^.().*().$' },
      ['q'] = { { "%b''", '%b""', '%b``' }, '^.().*().$' },
    }

    -- True when 1-indexed (line, col) falls inside `region` (mini.ai region:
    -- 1-based, end-inclusive -- see notes/mini-ai-treesitter-quotes.md).
    local function region_covers(region, line, col)
      if not (region and region.from and region.to) then return false end
      if line < region.from.line or line > region.to.line then return false end
      if line == region.from.line and col < region.from.col then return false end
      if line == region.to.line and col > region.to.col then return false end
      return true
    end

    ai.setup({
      search_method = 'cover',
      n_lines = 999999,
      custom_textobjects = {
        -- Quotes are left on their builtin textobjects globally. Treesitter
        -- versions are applied per-buffer by the autocommand below (so buffers
        -- without a parser/query keep working pattern-based quotes).
        -- Set function call to F
        ['f'] = false,
        ['F'] = ai.gen_spec.function_call(),
      },
    })

    -- NOTE: filetype->parser aliases (sh->bash, ps1->powershell, ...) that this
    -- relies on are registered early at startup in `shared/treesitter.lua`
    -- (required from `shared/nvim_load.lua`). Without them `get_parser()` fails
    -- for those filetypes and the builtin quotes are kept.

    local function query_has_capture(query, name)
      for _, capture in ipairs(query.captures) do
        if capture == name then return true end
      end
      return false
    end

    -- Switch quote textobjects to treesitter for `buf`, but only when both a
    -- parser and a suitable `textobjects` query exist. This avoids the
    -- nested-quote mismatch of pattern matching (e.g. `ci"` on the `tr` in
    -- `message="$(echo "foo" | tr "f" "c")"` removing ` | tr ` instead of the
    -- outer command-substitution quotes). Otherwise the builtin quotes remain.
    local function apply_treesitter_quotes(buf)
      if not vim.api.nvim_buf_is_valid(buf) then return end

      -- 1) Require a working treesitter parser for this buffer.
      local ok, parser = pcall(vim.treesitter.get_parser, buf, nil, { error = false })
      if not ok or parser == nil then return end

      -- 2) Require a reachable, valid `textobjects` query for the language.
      -- `query.get` can throw if a query references a node type the grammar
      -- doesn't have; treat that as "no query" and keep builtin quotes.
      local has_query, query = pcall(vim.treesitter.query.get, parser:lang(), 'textobjects')
      if not has_query or query == nil then return end

      -- 3) Override only the quote keys whose capture exists in the query.
      -- Each override tries the treesitter capture first, but only trusts it
      -- if one of the returned regions actually covers the cursor (matching
      -- this config's `search_method = 'cover'`). If nothing covers -- the
      -- cursor is inside a comment, a raw string, or a "wrong-kind" nested
      -- quote inside a shared string node, none of which have a matching
      -- node/capture -- fall back to the builtin pattern spec, which is
      -- syntax-blind and matches those cases directly off the buffer text.
      local custom = {}
      for key, cap in pairs(quote_keys) do
        if query_has_capture(query, cap .. '.outer') then
          local ts_spec = ai.gen_spec.treesitter({ a = '@' .. cap .. '.outer', i = '@' .. cap .. '.inner' })
          custom[key] = function(ai_type, id, opts)
            local ok_ts, regions = pcall(ts_spec, ai_type, id, opts)
            if ok_ts and regions then
              local cursor = vim.api.nvim_win_get_cursor(0)
              local line, col = cursor[1], cursor[2] + 1
              for _, region in ipairs(regions) do
                if region_covers(region, line, col) then return regions end
              end
            end
            return quote_patterns[key]
          end
        end
      end

      -- 4) No matching captures -> keep the builtin quote textobjects.
      if vim.tbl_isempty(custom) then return end

      local cfg = vim.b[buf].miniai_config or {}
      cfg.custom_textobjects = vim.tbl_extend('force', cfg.custom_textobjects or {}, custom)
      vim.b[buf].miniai_config = cfg
    end

    local group = vim.api.nvim_create_augroup('MiniAiTreesitterQuotes', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
      group = group,
      desc = 'Use treesitter quote textobjects when a parser and query exist',
      callback = function(args) apply_treesitter_quotes(args.buf) end,
    })

    -- mini.ai loads on `VeryLazy`, after the first buffer's `FileType` has
    -- already fired, so catch up any buffers that are already loaded.
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) then apply_treesitter_quotes(buf) end
    end
  end
}
