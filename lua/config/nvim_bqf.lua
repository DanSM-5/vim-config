return {
  setup = function ()
    require('bqf').setup({
      filter = {
        fzf = {
          extra_opts = {
            '--bind', 'ctrl-f:preview-half-page-down,ctrl-b:preview-half-page-up',
            '--bind', 'ctrl-o:toggle-all',
            '--bind', 'alt-f:first',
            '--bind', 'alt-l:last',
            '--bind', 'alt-c:clear-query',
            '--bind', 'alt-a:select-all',
            '--bind', 'alt-d:deselect-all',
            '--bind', 'ctrl-l:toggle-preview',
            '--bind', 'ctrl-/:toggle-preview',
            '--bind', 'alt-up:preview-page-up',
            '--bind', 'alt-down:preview-page-down',
            -- '--bind', 'ctrl-s:toggle-sort',
          }
        }
      }
    })
  end
}

