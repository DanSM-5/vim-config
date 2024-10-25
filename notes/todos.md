
# Add bindings or commands to resolve conflicts

- [ ] Implement bindings/commands to resolve conflicts
  - [x] Investigate information about how to accept conflicts in different editors
  - [ ] Support in vim config
  - [ ] Support in vscode-nvim config

## VSCode Nvim conflict resolution

In vscode the following actions are available

```lua
local vscode = require('vscode')
vscode.action('merge-conflict.accept.all-both')
vscode.action('merge-conflict.accept.all-current')
vscode.action('merge-conflict.accept.all-incoming')
vscode.action('merge-conflict.accept.both')
vscode.action('merge-conflict.accept.current')
vscode.action('merge-conflict.accept.incoming')
vscode.action('merge-conflict.accept.selection')
vscode.action('merge-conflict.compare')
vscode.action('merge-conflict.next')
vscode.action('merge-conflict.previous')
```

## (neo)vim conflict resolution with fugitive

For vim the following may be useful

```lua
-- open file using dv (:Gvdiffsplit), position cursor on conflicted hunk and use:

vim.keymap.set('n', 'gh', '<cmd>diffget //2<cr>', { desc = '[Conflict] Accept changes on left (current?)' })
vim.keymap.set('n', 'gl', '<cmd>diffget //3<cr>', { desc = '[Conflict] Accept changes on right (incoming?)' })
```

