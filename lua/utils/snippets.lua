--- Pick snippet to expand
--- Ref: https://github.com/blaze-d83/snipbrowzurr.nvim/blob/main/lua/snipbrowzurr.lua

---@class SnippetTable
---@field label string
---@field trigger string
---@field raw table
---@field idx integer

local function try_one(fn)
  local ok, _ = pcall(fn)
  return ok
end

-- Convert a snippet's body into plain text suitable for insertion into a
-- buffer when expansion via LuaSnip fails. Supports several snippet shapes:
-- - body: string -> returned as-is
-- - body: table -> lines joined with "\n"
-- - get_doc: function -> call and use returned string if valid
-- - nodes: table -> `vim.inspect` nodes and join them
-- Fallback: inspect the snippet and return the string representation.
--
-- snippet_body_text(snippet) -> string
local function snippet_body_text(sn)
  if not sn then
    return ''
  end
  if type(sn.body) == 'table' then
    return table.concat(sn.body, '\n')
  end
  if type(sn.body) == 'string' then
    return sn.body
  end
  if type(sn.get_doc) == 'function' then
    local ok, val = pcall(sn.get_doc, sn)
    if ok and val and type(val) == 'string' then
      return val
    end
  end
  if sn.nodes and type(sn.nodes) == 'table' and #sn.nodes > 0 then
    local out = {}
    for _, node in ipairs(sn.nodes) do
      table.insert(out, vim.inspect(node))
    end
    return table.concat(out, '\n\n')
  end
  local ok, s = pcall(function()
    return vim.inspect(sn)
  end)
  return (ok and s) or ''
end

-- Attempt to expand text as a snippet using LuaSnip extension points.
-- The function tries the following in order, returning true on first
-- successful attempt:
-- 1) ls.lsp_expand(text)
-- 2) parsed = ls.parser.parse_snippet(nil, text, {}); ls.snip_expand(parsed)
--
-- The function uses pcall to avoid throwing on missing or failing
-- implementation details; return `true` only if expansion succeeded.
--
-- try_expand_with_text(ls, text) -> boolean
local function try_expand_with_text(ls, text)
  if not text or text == '' then
    return false
  end

  if ls.lsp_expand then
    if try_one(function()
      ls.lsp_expand(text)
    end) then
      return true
    end
  end

  if ls.parser and ls.parser.parse_snippet and ls.snip_expand then
    if
      try_one(function()
        local parsed = ls.parser.parse_snippet(nil, text, {})
        ls.snip_expand(parsed)
      end)
    then
      return true
    end
  end

  return false
end

--- Expand the given snippet (or raw text) into the given window's buffer.
--- If `winid` is valid the function will switch to that window prior to
--- expansion and ensure the editor is in insert mode. Expansion attempts
--- are resilient: several strategies are tried via try_expand_with_text.
---
--- If expansion ultimately fails, the function inserts a fallback plain
--- text representation of the snippet (using snippet_body_text) with
--- `nvim_put` and warns the user via `vim.notify`.
---
---@param snip_or_text SnippetTable|string
local function expand_snippet(snip_or_text)
  local ok, luasnip = pcall(require, 'luasnip')
  if not ok then
    vim.notify('luasnip is not installed', vim.log.levels.WARN)
    return
  end

  if vim.fn.mode() ~= 'i' then
    vim.cmd.startinsert()
  end

  if type(snip_or_text) == 'string' and snip_or_text ~= '' then
    if try_expand_with_text(luasnip, snip_or_text) then
      return
    end
  end

  if type(snip_or_text) == 'table' then
    local sn = snip_or_text

    if type(sn.body) == 'string' then
      if try_expand_with_text(luasnip, sn.body) then
        return
      end
    elseif type(sn.body) == 'table' then
      local body = table.concat(sn.body, '\n')
      if try_expand_with_text(luasnip, body) then
        return
      end
    end

    if type(sn.get_doc) == 'function' then
      local ok, doc = pcall(sn.get_doc, sn)
      if ok and type(doc) == 'string' and doc ~= '' then
        if try_expand_with_text(luasnip, doc) then
          return
        end
      end
    end

    if sn.nodes and type(sn.nodes) == 'table' and #sn.nodes > 0 then
      local ok, _ = pcall(function()
        if luasnip.snip_expand then
          luasnip.snip_expand(sn)
        else
          local body = snippet_body_text(sn)
          local parsed = luasnip.parser and luasnip.parser.parse_snippet and luasnip.parser.parse_snippet(nil, body, {})
          if parsed and luasnip.snip_expand then
            luasnip.snip_expand(parsed)
          else
            error('no snip_expand available')
          end
        end
      end)
      if ok then
        return
      end
    end
  end

  if
    type(snip_or_text) == 'string'
    and snip_or_text ~= ''
    and luasnip.parser
    and luasnip.parser.parse_snippet
    and luasnip.snip_expand
  then
    local ok, _ = pcall(function()
      local parsed = luasnip.parser.parse_snippet(nil, snip_or_text, {})
      luasnip.snip_expand(parsed)
    end)
    if ok then
      return
    end
  end

  -- Fallback: Insert plain text insertion
  local text = snippet_body_text(snip_or_text)
  vim.api.nvim_put(vim.split(text, '\n', { plain = true }), 'c', true, true)
  vim.notify('Snippet expansion failed; inserted fallback text', vim.log.levels.WARN)
end

--- Returns: flat array of snippet objects (may be empty)
---
--- Take the raw snippet structure returned by luasnip (which can be nested
--- and mixed between dictionary-like tables and lists) and return a flat
--- array of snippet-like tables.
---
--- The function recognizes snippet-like objects by the presence of fields
--- such as `body`, `trigger`, `prefix`, `get_doc`, or `nodes`. It will
--- recursively descend into tables that don't look like snippets.
---
--- Parameters:
--- - raw: (table) arbitrary nested table returned by luasnip.get_snippets
--- - out: (table|nil) optional accumulator used during recursion
---
---@param raw table
---@param out table
---@return table
local function flatten_snippets(raw, out)
  out = out or {}
  if type(raw) ~= 'table' then
    return out
  end

  if vim.islist(raw) then
    for _, v in ipairs(raw) do
      if type(v) == 'table' then
        flatten_snippets(v, out)
      end
    end
    return out
  end

  for _, v in pairs(raw) do
    if type(v) == 'table' then
      if vim.islist(v) then
        for _, e in ipairs(v) do
          if type(e) == 'table' then
            table.insert(out, e)
          end
        end
      else
        local looks_like_snippet = false
        if v.body or v.trigger or v.prefix or v.get_doc or v.nodes then
          looks_like_snippet = true
        end
        if looks_like_snippet then
          table.insert(out, v)
        else
          flatten_snippets(v, out)
        end
      end
    end
  end

  return out
end

--- Returns: flat array of snippet objects produced by flatten_snippets.
---
--- Collect snippets for the given filetype using luasnip. If luasnip is
--- not available or returns an empty set, an empty table is returned.
---
--- Special handling:
--- - luasnip may return an object with a `.tbl` key. In that case we use
--- `.tbl` as the snippet container before flattening.
---
--- Parameters:
--- - filetype: optional string; if omitted the current buffer's filetype
--- is used (via get_filetype()).
---
---@param filetype string?
local get_snippets_by_ft = function(filetype)
  local ok, luasnip = pcall(require, 'luasnip')
  if not ok then
    vim.notify('luasnip is not installed', vim.log.levels.WARN)
    return {}
  end

  local ft = filetype or vim.api.nvim_get_option_value('filetype', {
    buf = 0,
  })

  local ok, raw = pcall(luasnip.get_snippets, ft)

  if not ok or not raw or next(raw) == nil then
    return {}
  end

  if type(raw) == 'table' and type(raw.tbl) == 'table' then
    raw = raw.tbl
  end

  return flatten_snippets(raw, {})
end

-- Returns: string label (never nil)
--
-- Produce a short, human-readable label for a snippet. This label is used
-- in the list UI and should be concise. The function prefers fields in the
-- following order: name, description/desc/dscr/desr, trigger/trig, prefix,
-- opts.description. If none of those exist it falls back to `vim.inspect`
-- of the snippet (trimmed) or a placeholder for `nil`.
--
-- Parameters:
-- - sn: snippet table (may be nil)
--
-- snippet_label(snippet) -> string
local function snippet_label(sn)
  if not sn then
    return '<nil-snippet>'
  end
  local candidates = {
    sn.name,
    sn.description,
    sn.desc,
    sn.dscr,
    sn.descr,
    sn.trigger,
    sn.trig,
    sn.prefix,
    (sn.opts and sn.opts.description),
  }
  for _, v in ipairs(candidates) do
    if v and v ~= '' then
      return tostring(v)
    end
  end
  local ok, s = pcall(function()
    return vim.inspect(sn)
  end)
  if ok and s then
    return vim.trim(s:gsub('\n', ' '))
  end
  return '<snippet>'
end

---Format snippet to display
---@param it SnippetTable
---@return string
local function format_item_display(it)
  local trig = it.trigger ~= '' and (' [' .. it.trigger .. ']') or ''
  local label = it.label:gsub('\t', ' ')
  local prefix = it.idx .. ' '
  return prefix .. label .. trig
end

---Select snippet from luasnip
---@param fullscreen boolean
local snippets = function(fullscreen)
  local snps = get_snippets_by_ft()

  if #snps == 0 then
    vim.notify('No snippets found for filetype', vim.log.levels.INFO)
    return
  end

  ---@type SnippetTable[]
  local items = {}
  ---@type string[]
  local labels = {}
  for i, sn in ipairs(snps) do
    local trigger = (sn.trigger or sn.trig or sn.prefix or '')
    local label = snippet_label(sn)
    ---@type SnippetTable
    local snippet = {
      label = label,
      trigger = trigger,
      raw = sn,
      idx = i,
    }

    table.insert(items, snippet)
    table.insert(labels, format_item_display(snippet))
  end
  local fzf_opts = require('utils.stdlib').concat(vim.g.fzf_bind_options, {
    '--with-nth',
    '2..',
    '--no-multi',
  })
  require('utils.fzf').fzf({
    source = labels,
    sink = function(selection)
      if #selection < 2 then
        return
      end

      local idx = vim.split(selection[2], ' ', { plain = true, trimempty = true })[1]
      local snippet = items[tonumber(idx)]
      expand_snippet(snippet.raw)
    end,
    fullscreen = fullscreen,
    name = 'luasnip',
    fzf_opts = fzf_opts,
  })
end

return {
  snippets = snippets,
}
