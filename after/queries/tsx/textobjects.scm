; extends
;
; TSX shares the ecma string grammar (`string` + `template_string`); JSX
; attribute values are ordinary `string` nodes too, so the same rules apply.
; Kept self-contained on purpose (see typescript/textobjects.scm).
;   "  -> double-quoted   '  -> single-quoted   `  -> template literal
;   q  -> any string

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

(template_string) @bquote.outer
((template_string) @bquote.inner
  (#offset! @bquote.inner 0 1 0 -1))

[(string) (template_string)] @string.outer
((string) @string.inner
  (#offset! @string.inner 0 1 0 -1))
((template_string) @string.inner
  (#offset! @string.inner 0 1 0 -1))
