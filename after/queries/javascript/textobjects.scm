; extends
;
; String textobjects for mini.ai (javascript / jsx).
;   "  -> double-quoted   '  -> single-quoted   `  -> template literal
;   q  -> any string
; The js grammar uses a single `string` node for both '...' and "...", so the
; quote kind is told apart with a `#lua-match?` predicate on the first char.
; `#offset!` shifts the range inward by one column per side to get `inner`.

; Double-quoted  ->  "
((string) @dquote.outer
  (#lua-match? @dquote.outer "^\""))
((string) @dquote.inner
  (#lua-match? @dquote.inner "^\"")
  (#offset! @dquote.inner 0 1 0 -1))

; Single-quoted  ->  '
((string) @squote.outer
  (#lua-match? @squote.outer "^'"))
((string) @squote.inner
  (#lua-match? @squote.inner "^'")
  (#offset! @squote.inner 0 1 0 -1))

; Template literal  ->  `
(template_string) @bquote.outer
((template_string) @bquote.inner
  (#offset! @bquote.inner 0 1 0 -1))

; Any string  ->  q
[(string) (template_string)] @string.outer
((string) @string.inner
  (#offset! @string.inner 0 1 0 -1))
((template_string) @string.inner
  (#offset! @string.inner 0 1 0 -1))
