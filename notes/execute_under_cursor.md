Execute lines under the cursor
=============

# Eval line under the cursor vimscript

```vim
:call execute(getline('.'))
" or from normal mode
Y:@"<cr>
```

# Eval line under the cursor lua (nvim)

```lua
:.lua
```

# Execute external command and insert output under the cursor

```vim
:.!<command>
" or
:call system(@u)
" or (special chars for vim are expanded like '%')
:exe '!'.@u
```

