return {
  setup = function ()
    require('refjump').setup({})
    require('refjump.keymaps').create_keymaps({
      integrations = {
        demicolon = {
          enable = true,
        },
      },
      keymaps = {
        next = '<f7>',
        prev = '<s-f7>',
        enable = true,
      },
    })
  end
}
