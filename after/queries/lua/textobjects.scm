; extends
;
; Lua: " and ' are single-char delimited; [[...]] / [=[...]=] are long-bracket
; strings (multi-char delimiters). All are a single `string` node with a
; `string_content` child.
;   "  -> double-quoted   '  -> single-quoted   q  -> any string (incl. [[ ]])
; No backtick strings in Lua.
;
; `inner` for " / ' uses an offset (1-char quotes). `inner` for q uses the
; `string_content` child so long-bracket delimiters are excluded correctly.

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
(string (string_content) @string.inner)
