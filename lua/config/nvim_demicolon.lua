return {
  setup = function()
    -- initialize
    require('demicolon').setup({
      -- prevent diagnostic_motions
      keymaps = {
        diagnostic_motions = false,
      },
      integrations = {
        neotest = { enabled = false },
        vimtex = { enabled = false },
      }
    })
  end,
}

