Banned keys for mappings
==========

Banned keys (sequences) are keys that have a special meaning in the terminal and share a sequence code with other known keys.

# Banned Keys

The following keys maps are considered banned from usage:

- `<c-m>`: Equivalent to carriage return (enter) character (cr)
- `<c-i>`: Equivalent to tab character
- `<c-h>`: Equivalent to backspace
- `<c-[>`: Equivalent to escape
- `<c-j>`: Equivalent to line feed character (lf)

# Rationale

Using these keys are very prone to unexpected effects. They are unreliable and behave different on different platforms,
terminals and shells.

# Candidates

- `<c-w>`: Deletes one word to the left in insert mode.
- `<c-d>`: Removes indentation level of the current line.
- `<c-t>`: Increases indentation level of the current line.

