return {
  setup = function()
    -- initialize
    require('demicolon').setup({
      -- prevent diagnostic_motions
      keymaps = {
        -- Create t/T/f/F key mappings
        horizontal_motions = false,
        -- Create ]d/[d, etc. key mappings to jump to diganostics. See demicolon.keymaps.create_default_diagnostic_keymaps
        diagnostic_motions = false,
        -- Create ; and , key mappings
        repeat_motions = false,
        -- Create ]q/[q/]<C-q>/[<C-q> and ]l/[l/]<C-l>/[<C-l> quickfix and location list mappings
        list_motions = false,
        -- Create `]s`/`[s` key mappings for jumping to spelling mistakes
        spell_motions = true,
        -- Create `]z`/`[z` key mappings for jumping to folds
        fold_motions = true,
      },
      integrations = {
        neotest = { enabled = false },
        vimtex = { enabled = false },
        gitsigns = { enable = true },
      }
    })
  end,
}

