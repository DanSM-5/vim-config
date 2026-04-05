-- NOTE: Do NOT set. It is a mess with some windows like fzf floating window
-- if vim.fn.exists('&winborder') == 1 then
--   vim.o.winborder = 'rounded'
-- end

vim.o.emoji = true

if vim.fn.has('nvim-0.12.0') == 1 then
  -- enable UI2
  require('vim._core.ui2').enable({
    enable = true,
    msg = { -- Options related to the message module.
      ---@type 'cmd'|'msg' Default message target, either in the
      ---cmdline or in a separate ephemeral message window.
      ---@type string|table<string, 'cmd'|'msg'|'pager'> Default message target
      ---or table mapping |ui-messages| kinds and triggers to a target.
      targets = 'cmd',
      cmd = { -- Options related to messages in the cmdline window.
        height = 0.5, -- Maximum height while expanded for messages beyond 'cmdheight'.
      },
      dialog = { -- Options related to dialog window.
        height = 0.5, -- Maximum height.
      },
      msg = { -- Options related to msg window.
        height = 0.5, -- Maximum height.
        timeout = 4000, -- Time a message is visible in the message window.
      },
      pager = { -- Options related to message window.
        height = 0.5, -- Maximum height.
      },
    },
  })

  -- Built-in plugins
  -- vim.cmd.packadd('nvim.difftool')
  -- vim.cmd.packadd('nvim.tohtml')
  -- vim.cmd.packadd('nvim.undotree')
end
