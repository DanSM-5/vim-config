CMP-RG
=======

# Manually trigger cmp-rg

Call rg source manually with ctrl-x ctrl-r

```lua
vim.keymap.set("i", "<c-x><c-r>", function()
  require("cmp").complete({
    config = {
      sources = {
        {
          name = "rg",
        },
      },
    },
  })
end)
```

