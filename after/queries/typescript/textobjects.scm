; extends
;
; TypeScript shares the ecma string grammar with JavaScript (`string` +
; `template_string`). Kept self-contained (rather than `; inherits: javascript`)
; on purpose: inheriting javascript pulls in JSX-specific rules whose node types
; (e.g. jsx_attribute) don't exist in the typescript grammar and would fail to
; compile the whole query.
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
