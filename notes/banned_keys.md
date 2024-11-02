Banned keys for mappings
==========

Banned keys (sequences) are keys that have a special meaning in the terminal and share a sequence code with other knwon keys.

# Banned Keys

The following keys maps are considered banned from usage:

- `<c-m>`: Treated as enter
- `<c-i>`: Treated as tab
- `<c-h>`: Treated as backspace
- `<c-[>`: Treated as escape

# Rationale

Maps that are a single key are restricted and using them have a very specific meaning. Therefore having a key combination that behaves as a single key is considered dangerous and potential source of conflicts with other keys.

# Candidates

- `<c-j>`: Terminals often use is as a new line character `\n`. However, unlike `<c-m>`, there is not a dedicated key to enter the new line sequence like `<Enter>`. For now `<c-j>` is not considered banned but its usage should be limited and tested before setting it as a keymap.

