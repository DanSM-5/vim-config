Treesitter quote textobjects for mini.ai
==========

How our quote textobjects (`"`, `'`, `` ` ``, `q`) use treesitter instead of the
builtin Lua-pattern matching, why, and how to add/repair queries when a parser
changes or Neovim updates.

> **Recreate-from-prompt note (for AI assistants):** this whole feature can be
> regenerated from this document. The design, the constraints discovered, the
> exact node names per language, the inspection script, and the verification
> harness are all below. If asked to "add language X" or "fix the broken
> query", read this file first, then follow *Adding a new language* and
> *Testing*. Everything was validated end-to-end on Neovim 0.12.3.

# Why this exists

`mini.ai`'s builtin `"`/`'`/`` ` ``/`q` textobjects match quotes with Lua
patterns (`%b""` etc.). On nested quotes they match in pairs, not by structure.
Example (shell):

```bash
message="$(echo "foo" | tr "f" "c" | something else)"
```

With the cursor on the `t` of `tr`, builtin `ci"` deletes ` | tr ` (the pair of
inner `"` around it) instead of the outer command-substitution string.
Treesitter knows the real structure: the only `string` node covering `tr` is the
outer `"$(...)"`, so the treesitter object selects it correctly.

# Architecture

Three pieces:

1. **`lua/config/nvim_mai.lua`** — a `FileType` autocommand (plus a VeryLazy
   catch-up loop) that, per buffer:
   - gets the treesitter parser (`pcall`, `{ error = false }`); bails if none;
   - gets the language's `textobjects` query (`pcall`); bails if none/invalid;
   - for each quote key whose capture exists in the query, overrides that key
     **buffer-locally** via `vim.b.miniai_config` with a function that tries
     the treesitter capture and only trusts it if a returned region actually
     covers the cursor, otherwise falling back to the builtin pattern spec
     (see *Fallback to pattern matching* below);
   - if no captures match, sets nothing → builtin quotes stay (fallback).

2. **`after/queries/<lang>/textobjects.scm`** — query files defining the string
   captures. nvim-treesitter-textobjects does **not** ship string captures, so
   we provide them ourselves.

3. **`lua/shared/treesitter.lua`** — registers filetype->parser aliases (general
   treesitter setup, not mini.ai-specific). Required from `shared/nvim_load.lua`
   early at startup. See *Filetype -> parser aliases* below.

This is mini.ai's documented Option-A pattern (`vim.b.miniai_config` per
buffer). The global `mini.ai` config keeps the builtin quotes, so any buffer
without a parser/query just works the old way.

## Key -> capture mapping

mini.ai builtin quote textobjects (`:h MiniAi-textobject-builtin`, source
`H.builtin_textobjects`):

| Key | Meaning            | Our capture family |
|-----|--------------------|--------------------|
| `"` | double quoted      | `dquote`           |
| `'` | single quoted      | `squote`           |
| `` ` `` | backtick/template | `bquote`        |
| `q` | smart quote (any)  | `string`           |

Each family needs `.outer` (includes delimiters) and `.inner` (between
delimiters) captures, e.g. `@dquote.outer` / `@dquote.inner`. The autocmd maps
keys to families in the `quote_keys` table; a key is only switched to treesitter
if `<family>.outer` is present in the query (so e.g. backtick stays builtin in
languages that have no template/backtick string).

`mini.ai` is wired to these via `gen_spec.treesitter({ a = '@x.outer', i = '@x.inner' })`.

# Fallback to pattern matching when treesitter has no capture for the cursor

**The bug** — `da"`/`ca"`/`di'`/etc. do nothing (or, worse, would need
language-specific special-casing to work) whenever the cursor sits on a
quote character that has no corresponding treesitter node. Three distinct
ways this happens, all confirmed:

```bash
# a "quoted word" in a comment          <- da" here did nothing
some_var='
  nested type of quotes "just like this one right here" makes not possible
'                                        <- da" on that " did nothing either
```
```javascript
const s = "she said 'hello' to me";     // da' on 'hello' did nothing
```

1. **Comments.** A `comment` node is a leaf — the lexer swallows the whole
   span as one opaque token, the parser never descends into it. Confirmed by
   dumping the parse tree (see *Inspect a parser's tree* below):
   `comment  [# Some comment (with parenthesis) that I…]` — no children.
2. **Raw/literal strings** (bash/zsh `'...'`, PowerShell verbatim strings).
   Same story: `raw_string  ['\n  Some multiline string like this wit…]` — a
   single leaf node. A `"` inside bash `'...'` has no syntactic meaning at
   all (that's *why* the language treats it as one token), so there's no
   node boundary a query could ever capture there.
3. **A "wrong-kind" quote nested inside a shared `string` node.** Languages
   where `'` and `"` are told apart by a first-character predicate on one
   `string` node (js/ts/tsx/json5/lua/vim/python — see *Hard-won
   constraints*) have exactly the same problem one level up: `'hello'`
   inside `"she said 'hello' to me"` is not a separate node either — the
   whole double-quoted span is one `string` node whose text starts with
   `"`, so it fails the `squote` predicate, and there is nothing else
   there for `@squote.outer` to match.

None of these are a missing capture or a fixable query — categorically
different from the *Why this exists* command-substitution case, where the
nested `"..."` actually gets reparsed as real bash syntax (real nested nodes
exist to capture). Here there is nothing to capture, in any language,
because the grammar doesn't produce a node boundary at that position.

**The fix — don't special-case node types or languages; check whether
treesitter's answer actually covers the cursor.** `gen_spec.treesitter(...)`
returns *every* matching region for the capture across the buffer (within
`n_lines`), and mini.ai (configured here with `search_method = 'cover'`)
only accepts one that covers the cursor. So instead of guessing from node
types which cases are "opaque" per language, call the treesitter spec, then
directly check whether one of its returned regions covers the cursor — the
same "cover" condition mini.ai itself applies. If none do (case 1, 2, or 3
above — or any other case not yet discovered), fall back to mini.ai's own
builtin (Lua-pattern) quote spec, which scans raw buffer text and is
completely blind to syntax, so it matches nested/commented/mismatched quotes
exactly like it would in a plain-text file. No per-language table to
maintain, and it generalizes automatically to languages/cases not
enumerated here. Implemented entirely in `lua/config/nvim_mai.lua`:

- `quote_patterns`: the fallback spec per key, copied verbatim from
  mini.ai's `H.builtin_textobjects` (`{ '%b""', '^.().*().$' }` etc.) — the
  same patterns the builtin quote textobjects already use everywhere.
- `region_covers(region, line, col)`: a plain 1-indexed, end-inclusive
  interval check (matching mini.ai's own region convention) — no treesitter
  or node-type knowledge involved, just "is this cursor position inside
  this from/to range".
- Each per-key override in `apply_treesitter_quotes` becomes a function
  that: calls the treesitter spec (`pcall`, since it can be invoked for an
  `ai_type` whose capture doesn't exist, e.g. `i` on an outer-only
  PowerShell here-string); if any returned region covers the cursor,
  returns those regions; otherwise returns `quote_patterns[key]` (mini.ai
  accepts a plain pattern-spec array returned from a custom-textobject
  function, per `H.get_textobject_spec`'s "allow function returning spec or
  region(s)").

Verified end-to-end (see *Testing*): nested quotes inside a bash raw string;
quotes inside bash/JS comments for every overridden key including `q`;
mismatched squote/dquote pairs nested inside a shared `string` node in
JavaScript, Lua, Python, JSON5, and Vimscript; and — as a regression check —
the original command-substitution case
(`message="$(echo "foo" | tr "f" "c")"`) and a nested template-literal
backtick case in JS still correctly use the treesitter path and select the
*outer*/structural match, since those regions do cover the cursor.

**If you add a new language:** no opaque-node table to update — the
coverage check is language-agnostic and applies automatically. Just add its
per-key fallback pattern to `quote_patterns` if you're wiring a new key
(`` ` ``/`q` already cover all current keys; a brand-new key would need one).

# Hard-won constraints (do not relearn these the hard way)

- **`; extends` is mandatory on every file.** Neovim core `vim.treesitter.query.get`
  (see `runtime/lua/vim/treesitter/query.lua`, `get_files`) treats the first
  modeline-less file as the *base* and **drops** any later modeline-less file.
  nvim-treesitter-textobjects ships a base `textobjects.scm` for most langs, so
  our `after/` file is dropped unless it starts with `; extends` (or
  `; inherits:`). Symptom of forgetting: query loads but our captures are absent.

- **Do NOT use `; inherits: javascript` for typescript/tsx.** It pulls
  nvim-treesitter-textobjects' JS rules, which reference `jsx_attribute` — a node
  type that does not exist in the `typescript` grammar — and the *entire* query
  fails to compile. Keep js/ts/tsx self-contained (they only need `string` and
  `template_string`, present in all three). Same reasoning: avoid `; inherits:`
  unless the parent uses only nodes the child grammar also has.

- **`#offset!` is honored by mini.ai.** mini.ai reads ranges via
  `vim.treesitter.get_range(node, buf, metadata)`, which applies `#offset!`
  metadata. Use `(#offset! @cap 0 1 0 -1)` to shrink a range inward by one column
  per side — this is how `inner` is derived for single-char delimiters even when
  the node has no content child (raw strings, leaf string nodes).
  Format: `#offset! @cap <start_row> <start_col> <end_row> <end_col>`.

- **`#match!`/`#make-range!` directives are NOT safe.** The mini.ai docs warn
  core won't treat capture-producing directives as captures. Stick to `#offset!`
  and predicates (`#lua-match?`, `#eq?`, `#any-of?`).

- **Distinguishing `'` vs `"` when the grammar uses one `string` node:** use a
  first-character predicate on the node text. Verified working through mini.ai:
  - double: `(#lua-match? @cap "^\"")`  (note the escaped `"` inside the scm string)
  - single: `(#lua-match? @cap "^'")`
  - with optional prefixes (Python `f"`/`r'`): `"^%a*\""` / `"^%a*'"`

- **`inner` for multi-char delimiters** (Lua `[[ ]]`, Python `"""`, prefixes):
  do **not** use `#offset! 0 1 0 -1` (wrong by N chars). Use the content child
  instead, e.g. `(string (string_content) @cap.inner)`. For single-char quotes
  offset is fine.

- **The autocmd must `pcall` `query.get`.** A grammar/query incompatibility
  (e.g. after a parser update) makes `query.get` throw; without `pcall` that
  breaks every `FileType` event. On failure we fall back to builtin quotes.

- **Treesitter ranges are 0-based, end-exclusive; mini.ai regions are 1-based,
  end-inclusive.** mini.ai's `gen_spec.treesitter` already converts. You only
  deal with treesitter coordinates inside `#offset!` (0-based, signed deltas).

# Filetype -> parser aliases (REQUIRED on nvim-treesitter `main`)

nvim-treesitter's **`main`** branch does **not** register any filetype->parser
aliases (confirmed: no `vim.treesitter.language.register` calls in its source),
and Neovim core's `vim.treesitter.language.get_lang(ft)` **falls back to the
filetype name** when nothing is registered. So for any filetype whose name
differs from the parser (lang) name, `vim.treesitter.get_parser(buf)` fails ->
the autocmd bails -> builtin quotes (the bug looks like "treesitter quotes don't
work for X files").

`shared/treesitter.lua` (the `filetype_aliases` table + `load()`) registers the
aliases our queries need; it is invoked early at startup from
`shared/nvim_load.lua`, before any real buffer's `FileType` and before mini.ai's
`VeryLazy` setup:

| filetype          | parser (lang) |
|-------------------|---------------|
| `sh`              | `bash`        |
| `ps1`             | `powershell`  |
| `typescriptreact` | `tsx`         |
| `javascriptreact` | `javascript`  |

(`bash`, `zsh`, `typescript`, `javascript`, `json`, `jsonc`, `json5`, `lua`,
`vim`, `python` already match their parser name, so no alias is needed.)
`vim.treesitter.language.register(lang, fts)` is **additive** — it preserves the
default `<filetype> == <lang>` mappings. It lives in `shared/treesitter.lua`
(not `nvim_mai.lua`) because it also fixes core treesitter highlighting/folds for
those filetypes — it is general treesitter setup, not mini.ai-specific. **To add
a new filetype alias, edit `M.filetype_aliases` there.**

**Symptom & check:** "treesitter quotes don't work for `<ft>` files". In such a
buffer run `:=vim.treesitter.language.get_lang(vim.bo.filetype)` — if it returns
the filetype name and no parser of that name exists, you need an alias here.
When adding a new language, check its filetype(s) vs parser name and add an
alias if they differ.

# Load order (VeryLazy catch-up)

mini.ai loads on `VeryLazy`, **after** the first edited buffer's `FileType` has
already fired. A pure `FileType` autocmd would therefore miss that first buffer.
`setup()` ends by iterating `nvim_list_bufs()` and applying the same logic to
already-loaded buffers. Keep this catch-up loop if you refactor. (The apply
logic is factored into `apply_treesitter_quotes(buf)` so the autocmd and the
catch-up loop share it.)

# Per-language reference (node types, verified on the installed parsers)

`outer` = node incl. delimiters; `inner` strategy noted. `parser:lang()` (not
filetype) selects the query dir.

| lang (dir)   | `"` node                          | `'` node                          | `` ` `` node       | `q` (any)                                   | inner strategy |
|--------------|-----------------------------------|-----------------------------------|--------------------|---------------------------------------------|----------------|
| `bash`       | `string`                          | `raw_string`                      | — (cmd-subst)      | `string`,`raw_string`,`ansi_c_string`       | offset; ansi_c `0 2 0 -1` |
| `zsh`        | `string`                          | `raw_string`                      | — (cmd-subst)      | same as bash                                | same as bash |
| `powershell` | `expandable_string_literal` + `expandable_here_string_literal` | `verbatim_string_characters` + `verbatim_here_string_literal` | — (escape char) | `string_literal` wrapper | offset (here-strings: outer only) |
| `javascript` | `string` + predicate `^"`         | `string` + predicate `^'`         | `template_string`  | `string`,`template_string`                  | offset |
| `typescript` | same as javascript (self-contained)| same                             | `template_string`  | same                                        | offset |
| `tsx`        | same as javascript (self-contained)| same; JSX attrs are `string` too | `template_string`  | same                                        | offset |
| `json`       | `string`                          | — (none)                          | —                  | `string`                                    | offset |
| `jsonc`      | `string` (self-contained)         | —                                 | —                  | `string`                                    | offset |
| `json5`      | `string` + predicate `^"`         | `string` + predicate `^'`         | —                  | `string`                                    | offset |
| `lua`        | `string` + predicate `^"`         | `string` + predicate `^'`         | —                  | `string` (incl. `[[ ]]`/`[=[ ]=]`)          | "/' offset; `q` uses `string_content` child |
| `vim`        | `string_literal` + predicate `^"` | `string_literal` + predicate `^'` | —                  | `string_literal`                            | offset |
| `python`     | `string` + predicate `^%a*"`      | `string` + predicate `^%a*'`      | —                  | `string`                                    | `string_content` child (f-string inner is per-fragment) |

Notes:
- Backtick in bash/zsh and PowerShell is command-substitution / escape, **not** a
  string, so `` ` `` keeps its builtin object there (correct behavior).
- PowerShell here-strings (`@"…"@`, `@'…'@`) get `outer` only; their multi-char,
  multi-line delimiters can't be expressed with a fixed `#offset!`.
- Python f-string `inner` selects the content fragment under the cursor (it does
  not span across `{…}` interpolations) because each `string_content` is a
  separate node.

# File locations

- Config:  `lua/config/nvim_mai.lua` (mini.ai setup + quote autocmd/catch-up)
- Aliases: `lua/shared/treesitter.lua` (filetype->parser registration), loaded
  from `lua/shared/nvim_load.lua`
- Queries: `after/queries/<lang>/textobjects.scm`
- mini.ai source (read when in doubt): `~/.local/share/nvim/lazy/mini.ai/lua/mini/ai.lua`
  - `gen_spec.treesitter` (~line 1042), `get_matched_ranges_builtin` (~1622),
    `get_config`/`vim.b.miniai_config` merge (~1311), `H.builtin_textobjects` (~1214).

# Adding a new language

1. **Confirm the parser is installed and find its lang name.**
   ```
   :=vim.treesitter.language.get_lang(vim.bo.filetype)   " filetype -> lang
   :=vim.treesitter.query.get_files(<lang>, 'textobjects')  " query files seen
   ```
   The query dir name = the lang, not the filetype (e.g. `ps1` -> `powershell`,
   `sh` -> `bash`, `typescriptreact` -> `tsx`).

2. **Inspect the string node types.** Run the inspection script (below) with a
   sample covering every quote style the language has. Note: the node type for
   each quote kind, whether `'`/`"` share a node (need a predicate), and whether
   there's a content child for `inner`.

3. **Write `after/queries/<lang>/textobjects.scm`.** Start with `; extends`.
   Define `@dquote.{outer,inner}`, `@squote.{outer,inner}`, `@bquote.{outer,inner}`
   (only where a template/backtick string exists), and `@string.{outer,inner}`
   (`q`, union of all string kinds). Pick the `inner` strategy per the
   constraints above.

4. **Add nothing to the config** — the autocmd auto-detects the new query via the
   `quote_keys` table. (Only edit `quote_keys` if you introduce a new key.)

5. **Test** (below). Add cases for each quote kind, nested quotes, and the
   `q` alias.

## Query template (single-char-quote languages, with predicate)

```scheme
; extends
; <lang>: " and ' share one `string` node, distinguished by first char.

((string) @dquote.outer
  (#lua-match? @dquote.outer "^\""))
((string) @dquote.inner
  (#lua-match? @dquote.inner "^\"")
  (#offset! @dquote.inner 0 1 0 -1))

((string) @squote.outer
  (#lua-match? @squote.outer "^'"))
((string) @squote.inner
  (#lua-match? @squote.inner "^'")
  (#offset! @squote.inner 0 1 0 -1))

; add this block only if the language has template/backtick strings:
; (template_string) @bquote.outer
; ((template_string) @bquote.inner (#offset! @bquote.inner 0 1 0 -1))

(string) @string.outer
((string) @string.inner
  (#offset! @string.inner 0 1 0 -1))
```

## Query template (distinct node per quote kind, e.g. bash)

```scheme
; extends
((string) @dquote.outer)
((string) @dquote.inner (#offset! @dquote.inner 0 1 0 -1))
((raw_string) @squote.outer)
((raw_string) @squote.inner (#offset! @squote.inner 0 1 0 -1))
[(string) (raw_string) (ansi_c_string)] @string.outer
((string) @string.inner (#offset! @string.inner 0 1 0 -1))
((raw_string) @string.inner (#offset! @string.inner 0 1 0 -1))
```

# Testing

Both scripts are self-contained; adjust the rtp lines if plugin paths change.

**Parser install location.** With nvim-treesitter's `main` branch, `:TSInstall`
writes parsers to `stdpath('data')/site/parser/`
(= `~/.local/share/nvim/site/parser/`) and queries to `site/queries/<lang>/`.
This is nvim-treesitter's default (`config.lua`: `install_dir = stdpath('data')/site`),
**independent of the plugin manager** — `~/.local/share/nvim/site/` is always on
the default `runtimepath`. So this path is the same under lazy.nvim and under
`vim.pack` (vim.pack only changes where the *plugin* lives:
`site/pack/core/opt/nvim-treesitter/`, not where parsers go). Override only via
`require('nvim-treesitter').setup({ install_dir = ... })`.

Note: some parsers may also sit in the plugin's own dir
(`<plugin>/parser/`, e.g. `lazy/nvim-treesitter/parser/`). Those vanish if the
plugin dir is removed (e.g. dropping lazy for vim.pack) — re-run `:TSInstall` to
land them in the persistent `site/parser/`. The scripts below append both the
plugin dir and `site` to be safe in the minimal `-u` env.

## Inspect a parser's tree (find node names)

Save as `/tmp/inspect.lua`, run `nvim --headless -u /tmp/inspect.lua`:

```lua
vim.opt.rtp:append('~/.local/share/nvim/lazy/nvim-treesitter')
vim.opt.rtp:append('~/.local/share/nvim/site')
local function dump(lang, code)
  print('===== '..lang..' =====')
  local p = vim.treesitter.get_string_parser(code, lang)
  local function w(n, d)
    if n:named() then
      local t = vim.treesitter.get_node_text(n, code):gsub('\n', '\\n')
      if #t > 30 then t = t:sub(1, 30)..'…' end
      print(('  '):rep(d)..n:type()..'  ['..t..']')
    end
    for c in n:iter_children() do w(c, d + 1) end
  end
  w(p:parse()[1]:root(), 1)
end
-- one dump() per language; include every quote style:
dump('python', 'a = "dq"\nb = \'sq\'\nc = f"x {a}"\nd = """t"""\ne = r\'raw\'')
vim.cmd('qa!')
```

## End-to-end verification harness (the real config + real query files)

Save as `/tmp/qtest.lua`, run `nvim --headless -u /tmp/qtest.lua`. It loads the
**actual** config and `after/queries`, drives `find_textobject`, and asserts the
selected text. Register any filetype->lang aliases nvim-treesitter normally sets
up at startup (this minimal env doesn't run its setup).

```lua
vim.opt.rtp:append('~/.local/share/nvim/lazy/nvim-treesitter')
vim.opt.rtp:append('~/.local/share/nvim/lazy/nvim-treesitter-textobjects')
vim.opt.rtp:append('~/.local/share/nvim/lazy/mini.ai')
vim.opt.rtp:append('~/.local/share/nvim/site')        -- :TSInstall parsers
vim.opt.rtp:prepend('~/.config/nvim')                 -- real after/queries + lua/config
package.path = package.path .. ';' .. vim.fn.expand('~/.config/nvim/lua/?.lua')

-- filetype -> parser aliases nvim-treesitter registers at startup:
vim.treesitter.language.register('bash',       { 'sh', 'bash' })
vim.treesitter.language.register('powershell', { 'ps1', 'powershell' })
vim.treesitter.language.register('tsx',        { 'typescriptreact' })
vim.treesitter.language.register('javascript', { 'javascript', 'javascriptreact' })
vim.treesitter.language.register('zsh',        { 'zsh' })

require('config.nvim_mai').setup()
local ai = require('mini.ai')
local fails, total = 0, 0
local function check(ft, lines, cursor, id, t, expect)
  total = total + 1
  vim.cmd('enew!')
  vim.bo.filetype = ft
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  pcall(vim.cmd, 'doautocmd FileType')
  local okp, parser = pcall(vim.treesitter.get_parser, 0)
  if okp and parser then pcall(function() parser:parse(true) end) end
  vim.api.nvim_win_set_cursor(0, cursor)
  local okf, r = pcall(ai.find_textobject, t, id)
  local got = (okf and r) and vim.fn.getline(r.from.line):sub(r.from.col, r.to.col) or '<none>'
  local pass = got == expect
  if not pass then fails = fails + 1 end
  print(('  [%-8s] %s%s -> %-22s %s'):format(ft, t, id, '['..got..']',
    pass and 'OK' or ('!! want ['..expect..']')))
end

-- the original bug: cursor on the `t` of `tr` selects the OUTER string
check('sh', { [[message="$(echo "foo" | tr "f" "c" | x)"]] }, {1,24}, '"', 'a',
  '"$(echo "foo" | tr "f" "c" | x)"')
check('javascript', { [[const a = "dq"; const b = 'sq'; const c = `t`;]] }, {1,12}, '"', 'i', 'dq')
check('javascript', { [[const a = "dq"; const b = 'sq'; const c = `t`;]] }, {1,28}, "'", 'i', 'sq')
check('lua', { [=[local d = [[brk]]]=] }, {1,12}, 'q', 'i', 'brk')
check('python', { [[d = """triple"""]] }, {1,8}, '"', 'i', 'triple')

-- pattern fallback: nested quote inside a raw (single-quoted) string
check('sh', {
  [[some_var=']], [[  Some multiline string like this with]],
  [[  nested type of quotes "just like this one right here" makes not possible]],
  [[  to match because treesitter assumes nodes.]], [[']],
}, {3, 30}, '"', 'a', '"just like this one right here"')

-- pattern fallback: quotes inside comments (every overridden quote key)
check('sh', { [[# a "quoted word" in a comment]] }, {1, 10}, '"', 'a', '"quoted word"')
check('sh', { [[# some text 'quoted here' and more]] }, {1, 18}, "'", 'a', "'quoted here'")
check('sh', { [[# a "quoted word" in a comment]] }, {1, 10}, 'q', 'a', '"quoted word"')
check('javascript', { [[// a "quoted word" here]] }, {1, 6}, '"', 'a', '"quoted word"')

-- pattern fallback: "wrong-kind" quote pair nested inside a shared `string`
-- node (languages where '/" share one node, told apart by a predicate)
check('javascript', { [[const s = "she said 'hello' to me";]] }, {1,22}, "'", 'a', "'hello'")
check('javascript', { [[const s = 'she said "hello" to me';]] }, {1,22}, '"', 'a', '"hello"')
check('lua', { [[local s = "she said 'hello' to me"]] }, {1,22}, "'", 'a', "'hello'")
check('python', { [[s = "she said 'hello' to me"]] }, {1,16}, "'", 'a', "'hello'")
check('json5', { [[{ s: "she said 'hello' to me" }]] }, {1,17}, "'", 'a', "'hello'")
check('vim', { [[let s = "she said 'hello' to me"]] }, {1,20}, "'", 'a', "'hello'")

-- regression: nested template-literal backtick must still use treesitter
check('javascript', { [[const x = `outer ${`inner ${y}`} more`;]] }, {1,22}, '`', 'i', 'inner ${y}')
-- ... add a case per language / quote kind / nesting ...

print(('%d/%d passed%s'):format(total - fails, total,
  fails == 0 and '  -- ALL GREEN' or ('  -- '..fails..' FAILED')))
vim.cmd('qa!')
```

# Troubleshooting (parser update / Neovim update broke quotes)

Inside the affected buffer:

1. **Is the buffer using treesitter at all?**
   ```
   :=vim.b.miniai_config            " nil  => autocmd bailed (no parser/query)
   ```
   nil means it fell back to builtin (safe but not treesitter). Find out why:

2. **Parser present / filetype aliased?**  `:=vim.treesitter.get_parser(0)`
   (errors/nil). If it fails, check
   `:=vim.treesitter.language.get_lang(vim.bo.filetype)` — if that returns the
   filetype name and no parser of that name exists, add a filetype->parser alias
   (see *Filetype -> parser aliases*). Otherwise `:TSInstall <lang>`.

3. **Query loads and is valid?**
   ```
   :=vim.treesitter.query.get(vim.treesitter.language.get_lang(vim.bo.filetype), 'textobjects')
   ```
   If this **throws**, a node type in the query no longer exists in the grammar
   (common after a parser bump). The error names the offending node and line.
   Fix the query to the new node name (re-run the inspection script to see the
   new tree). The config's `pcall` keeps editing working meanwhile (builtin
   quotes).

4. **Query loads but our captures missing?** Check the file starts with
   `; extends`. Verify the capture is recognized:
   ```
   :=vim.treesitter.query.get(<lang>, 'textobjects').captures
   ```
   Look for `dquote.outer`, `string.inner`, etc.

5. **Wrong selection (pairs again)?** You're on the builtin path — see step 1.
   If on the treesitter path, the node is likely wrong; re-inspect the tree.

6. **Textobject silently does nothing on a quote inside a comment, a raw
   string, or nested with the "wrong" quote kind inside a shared `string`
   node?** Expected — see *Fallback to pattern matching* above: no
   treesitter node exists there, so the cursor-coverage check should already
   route to `quote_patterns[key]`. If it's still failing, the bug is in the
   fallback pattern itself (or `region_covers`), not a missing per-language
   table entry — there is no such table anymore.

7. **Re-run the verification harness** after any change.

# Change history / provenance

- Designed against `mini.ai` (lazy) and Neovim **0.12.3**.
- Core modeline support (`; extends`, `; inherits:`) confirmed in
  `runtime/lua/vim/treesitter/query.lua` (`MODELINE_FORMAT`, `EXTENDS_FORMAT`,
  `get_files`).
- All 12 languages verified end-to-end (24 + 11 assertions, all green):
  bash, zsh, powershell, javascript, typescript, tsx, json, jsonc, json5, lua,
  vim, python.
- Added a pattern-matching fallback (`quote_patterns` / `region_covers` in
  `lua/config/nvim_mai.lua`) after real-world reports that `da"`/`ca"` etc.
  did nothing on quotes nested inside a bash raw string or inside a `#`/`//`
  comment. First iteration used a hand-maintained per-language
  `opaque_node_types` table (comment/raw_string/etc. node names) — root
  causing via parse-tree inspection showed those are leaf nodes with no
  children. That iteration was then found (by testing JS/Lua with a
  genuinely nested `'hello'` inside a `"..."` string) to miss languages
  where `'`/`"` share one `string` node distinguished by a predicate: a
  "wrong-kind" nested quote there has no separate node either, but isn't a
  named opaque type, so the per-language table couldn't catch it. Replaced
  with a general, language-agnostic fix: check whether the treesitter spec's
  returned regions actually cover the cursor (mirroring this config's
  `search_method = 'cover'`) and fall back to the pattern spec if not — no
  per-language table needed at all. Verified against the bash raw-string
  case, bash/JS comments for every overridden quote key, mismatched
  squote/dquote pairs nested in a shared `string` node across JS, Lua,
  Python, JSON5, and Vimscript, and regression checks that the original
  command-substitution fix and nested-template-literal backtick matching
  still select the correct outer/structural match.
