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
      local custom = {}
      for key, cap in pairs(quote_keys) do
        if query_has_capture(query, cap .. '.outer') then
          custom[key] = ai.gen_spec.treesitter({ a = '@' .. cap .. '.outer', i = '@' .. cap .. '.inner' })
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
