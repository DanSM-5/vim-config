; extends
;
; JSONC is JSON plus comments; strings are identical (double-quoted only).
; Kept self-contained for robustness.
;   "  -> string        q  -> string (smart-quote alias, same thing here)

((string) @dquote.outer)
((string) @dquote.inner
  (#offset! @dquote.inner 0 1 0 -1))

(string) @string.outer
((string) @string.inner
  (#offset! @string.inner 0 1 0 -1))
