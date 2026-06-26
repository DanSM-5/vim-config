; extends
;
; Vimscript: " and ' are single-char delimited `string_literal` nodes (note: a
; leading " at the start of a line is a comment, which the grammar parses as a
; `comment`, not a `string_literal`, so it is correctly excluded).
;   "  -> double-quoted   '  -> single-quoted   q  -> any string
; No backtick / template strings.

((string_literal) @dquote.outer
  (#lua-match? @dquote.outer "^\""))
((string_literal) @dquote.inner
  (#lua-match? @dquote.inner "^\"")
  (#offset! @dquote.inner 0 1 0 -1))

((string_literal) @squote.outer
  (#lua-match? @squote.outer "^'"))
((string_literal) @squote.inner
  (#lua-match? @squote.inner "^'")
  (#offset! @squote.inner 0 1 0 -1))

(string_literal) @string.outer
((string_literal) @string.inner
  (#offset! @string.inner 0 1 0 -1))
