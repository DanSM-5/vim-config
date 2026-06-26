; extends
;
; String textobjects for mini.ai treesitter quote textobjects.
; nvim-treesitter-textobjects does not ship string captures for bash, so we
; define them here. `mini.ai` reads `<cap>.outer` / `<cap>.inner` captures.
;
; The `#offset!` directive shifts the matched range inward by one column on
; each side, so `inner` becomes the content *between* the quote characters.
; This works uniformly even when the node has no `string_content` child
; (e.g. a raw_string, or a double-quoted string wrapping a command
; substitution), which a child-based capture cannot handle.
;
; NOTE: backtick `` `...` `` in bash parses as `command_substitution`, not a
; string, so there is no `bquote` capture here. The mini.ai `` ` `` key keeps
; its builtin pattern textobject in bash buffers (see lua/config/nvim_mai.lua).

; Double-quoted strings  ->  mini.ai `"` key
((string) @dquote.outer)
((string) @dquote.inner
  (#offset! @dquote.inner 0 1 0 -1))

; Single-quoted (raw) strings  ->  mini.ai `'` key
((raw_string) @squote.outer)
((raw_string) @squote.inner
  (#offset! @squote.inner 0 1 0 -1))

; Any string  ->  mini.ai `q` smart-quote key
[(string) (raw_string) (ansi_c_string)] @string.outer
((string) @string.inner
  (#offset! @string.inner 0 1 0 -1))
((raw_string) @string.inner
  (#offset! @string.inner 0 1 0 -1))
((ansi_c_string) @string.inner
  (#offset! @string.inner 0 2 0 -1))
