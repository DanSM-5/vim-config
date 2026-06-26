; extends
;
; PowerShell (Windows PowerShell 5 and PowerShell 7 share this grammar).
; String node kinds:
;   expandable_string_literal        "..."      (interpolating)   -> "
;   verbatim_string_characters       '...'      (literal)         -> '
;   expandable_here_string_literal   @"...\n"@                    -> "
;   verbatim_here_string_characters  @'...\n'@                    -> '
; The backtick `` ` `` is PowerShell's escape character, not a string, so the
; `` ` `` key keeps its builtin textobject.
;
; `inner` is provided for the single-line (1-char delimited) forms via offset.
; Here-strings (multi-char, multi-line @"/"@ delimiters) get `outer` only; their
; `inner` is intentionally omitted because a fixed column offset cannot describe
; their delimiters.

; Any string  ->  q  (outer wrapper covers single-line and here-strings)
(string_literal) @string.outer
((expandable_string_literal) @string.inner
  (#offset! @string.inner 0 1 0 -1))
((verbatim_string_characters) @string.inner
  (#offset! @string.inner 0 1 0 -1))

; Double / expandable  ->  "
(expandable_string_literal) @dquote.outer
(expandable_here_string_literal) @dquote.outer
((expandable_string_literal) @dquote.inner
  (#offset! @dquote.inner 0 1 0 -1))

; Single / verbatim  ->  '
(verbatim_string_characters) @squote.outer
(verbatim_here_string_literal) @squote.outer
((verbatim_string_characters) @squote.inner
  (#offset! @squote.inner 0 1 0 -1))
