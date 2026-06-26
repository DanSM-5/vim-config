; extends
;
; JSON5 allows both single- and double-quoted strings (one `string` node for
; both), so the quote kind is told apart with a first-char predicate.
;   "  -> double-quoted   '  -> single-quoted   q  -> any string

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

(string) @string.outer
((string) @string.inner
  (#offset! @string.inner 0 1 0 -1))
