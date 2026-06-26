; extends
;
; Python. NOTE: the `python` parser is NOT installed on this machine, so these
; captures are UNVERIFIED (written from the tree-sitter-python grammar). Install
; the parser to use them.
;
; A python `string` is `(string (string_start) (string_content)* (string_end))`.
; `string_start` carries any prefix (f, r, b, rb, ...) plus the opening quote(s)
; ("'", '"', triple-quoted). The quote kind is told apart with a predicate that
; allows an optional letter prefix before the quote.
;   "  -> double-quoted   '  -> single-quoted   q  -> any string
; Python has no backtick strings.
;
; `inner` uses the `string_content` child(ren) so triple-quotes and prefixes are
; excluded. For f-strings with interpolations, mini.ai selects the content
; fragment under the cursor (it does not span across `{...}` substitutions).

((string) @dquote.outer
  (#lua-match? @dquote.outer "^%a*\""))
((string (string_content) @dquote.inner) @_dq
  (#lua-match? @_dq "^%a*\""))

((string) @squote.outer
  (#lua-match? @squote.outer "^%a*'"))
((string (string_content) @squote.inner) @_sq
  (#lua-match? @_sq "^%a*'"))

(string) @string.outer
(string (string_content) @string.inner)
