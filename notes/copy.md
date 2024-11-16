Registers
============

For detail information check `:h registers`.

## Unnamed and Unnamedplus

Special registers to access system clipboard.

- `*` Unnamed register (`"*`)
- `+` Unnamedplus register (`"+`)

Set clipboard to any of the unnamed registers to use system clipboard for yank, paste and delete operations.

```vim
set clipboard+=unnamed
" or
set clipboard+=unnamedplus
```

## Copy all tabs

Copy all tabs contents to system clipboard

```vim
let @a='' | tabdo let @a=@a."\n".expand('%:p') | %y A | let @+=@a
```

