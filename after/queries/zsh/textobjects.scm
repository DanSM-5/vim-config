; extends
;
; Zsh. NOTE: this targets the `zsh` parser (georgeharker/tree-sitter-zsh),
; which is NOT installed on this machine, so these captures are UNVERIFIED. The
; grammar is bash-derived and is expected to expose the same string node names.
; If you instead let zsh files use the bash parser (e.g.
; `vim.treesitter.language.register('bash', 'zsh')`), the bash query applies and
; this file is unused.
;
;   "  -> string (double)   '  -> raw_string (single)   q  -> any string
; Backtick `...` is command substitution, not a string -> builtin ` key.

; Double-quoted  ->  "
((string) @dquote.outer)
((string) @dquote.inner
  (#offset! @dquote.inner 0 1 0 -1))

; Single-quoted (raw)  ->  '
((raw_string) @squote.outer)
((raw_string) @squote.inner
  (#offset! @squote.inner 0 1 0 -1))

; Any string  ->  q
[(string) (raw_string) (ansi_c_string)] @string.outer
((string) @string.inner
  (#offset! @string.inner 0 1 0 -1))
((raw_string) @string.inner
  (#offset! @string.inner 0 1 0 -1))
((ansi_c_string) @string.inner
  (#offset! @string.inner 0 2 0 -1))
