local create_autocmd = function ()
  vim.api.nvim_create_autocmd('FileType', {
    group =  vim.api.nvim_create_augroup('grug-far-keymaps', { clear = true }),
    pattern = { 'grug-far' },
    ---Callback for keymap autocmd
    ---@param evt { buf: integer } Options from autocmd
    callback = function(evt)
      -- vim.keymap.set('n', '<localleader>w', function()
      --   local state = unpack(require('grug-far').toggle_flags({ '--fixed-strings' }))
      -- end, { buffer = evt.buf })
    end,
  })
end

local set_keymaps = function ()
  vim.keymap.set('n', '<C-t>t', function ()
    require('grug-far').open()
  end, {
    noremap = true,
    desc = '[GrugFar] Open grug-far window'
  })

  ---Open grug-far with word under cursor
  ---@param all boolean If false (default), current path only. If true, all files
  local open_gf_word = function (all)
    local prefills = {
      search = vim.fn.expand('<cword>')
    }

    if not all then
      prefills.paths = vim.fn.expand('%:p')
    end

    require('grug-far').open({ prefills = prefills })
  end
  vim.keymap.set('n', '<C-t>w', function ()
    open_gf_word(true)
  end, {
    noremap = true,
    desc = '[GrugFar] Open grug-far with search the word under the cursor'
  })
  vim.keymap.set('n', '<C-t>W', function ()
    open_gf_word(true)
  end, {
    noremap = true,
    desc = '[GrugFar] Open grug-far with search the word under the cursor current file'
  })

  ---Open grug-far with visual selection
  ---@param all boolean If false (default), current path only. If true, all files
  local open_gf_visual = function (all)
    -- local search = table.concat(
    --   vim.fn['utils#get_selected_text'](),
    --   '\n'
    -- )

    -- require('grug-far').open({
    --   prefills = { search = search }
    -- })

    local prefills = {}

    if not all then
      prefills.paths = vim.fn.expand('%:p')
    end

    require('grug-far').with_visual_selection({ prefills = prefills })
  end

  vim.keymap.set('v', '<C-t>W', open_gf_visual, {
    noremap = true,
    desc = '[GrugFar] Open grug-far with visual selected text in all files'
  })
  vim.keymap.set('v', '<C-t>w', function ()
    open_gf_visual(true)
  end, {
    noremap = true,
    desc = '[GrugFar] Open grug-far with visual selected text'
  })

  vim.keymap.set('n', '<C-t>s', function ()
    require('grug-far').open({
      prefills = { search = vim.fn.getreg('/') }
    })
  end, {
    noremap = true,
    desc = '[GrugFar] Open grug-far with the last searched string'
  })
end

---Open grug far with the paths from
---a file explorer/project drawer
---@param prefills { paths: string }
local function open_from_explorer(prefills)
  local ok, grug_far = pcall(require, 'grug-far')

  if not ok then
    vim.notify('Grug-far not available')
    return
  end

  -- instance check
  if not grug_far.has_instance('explorer') then
    grug_far.open({
      instanceName = 'explorer',
      staticTitle = 'Find and Replace from Explorer',
    })
  else
    grug_far.open_instance('explorer')
  end

  -- doing it seperately because multiple paths doesn't work when passed with open
  -- updating the prefills without clearing the search and other fields
  grug_far.update_instance_prefills('explorer', prefills, false)
end

-- For neo-tree
-- local search_grug_far = function (state)
--   local node = state.tree:get_node()
--   local prefills = {
--     -- also escape the paths if space is there
--     -- if you want files to be selected, use ':p' only, see filename-modifiers
--     paths = node.type == 'directory' and vim.fn.fnameescape(vim.fn.fnamemodify(node:get_id(), ':p'))
--       or vim.fn.fnameescape(vim.fn.fnamemodify(node:get_id(), ':h')),
--   }
--   open_from_explorer(prefills)
-- end

-- -- https://github.com/nvim-neo-tree/neo-tree.nvim/blob/fbb631e818f48591d0c3a590817003d36d0de691/doc/neo-tree.txt#L535
-- local grug_far_replace_visual = function(state, selected_nodes, callback)
--   local paths = {}
--   for _, node in pairs(selected_nodes) do
--     -- also escape the paths if space is there
--     -- if you want files to be selected, use ':p' only, see filename-modifiers
--     local path = node.type == 'directory' and vim.fn.fnameescape(vim.fn.fnamemodify(node:get_id(), ':p'))
--     or vim.fn.fnameescape(vim.fn.fnamemodify(node:get_id(), ':h'))
--     table.insert(paths, path)
--   end
--   local prefills = { paths = table.concat(paths, "\n") }
--   open_from_explorer(prefills)
-- end

return {
  setup = function ()
    require('grug-far').setup({
      keymaps = {
        replace = { n = '<localleader>r' },
        qflist = { n = '<localleader>q' },
        syncLocations = { n = '<localleader>s' },
        syncLine = { n = '<localleader>l' },
        close = { n = '<localleader>c' },
        historyOpen = { n = '<localleader>t' },
        historyAdd = { n = '<localleader>a' },
        refresh = { n = '<localleader>f' },
        openLocation = { n = '<localleader>o' },
        -- openNextLocation = { n = '<down>' },
        -- openPrevLocation = { n = '<up>' },
        openNextLocation = { n = '<c-j>' },
        openPrevLocation = { n = '<c-k>' },
        gotoLocation = { n = '<enter>' },
        pickHistoryEntry = { n = '<enter>' },
        abort = { n = '<localleader>b' },
        help = { n = 'g?' },
        toggleShowCommand = { n = '<localleader>p' },
        swapEngine = { n = '<localleader>e' },
        previewLocation = { n = '<localleader>i' },
        swapReplacementInterpreter = { n = '<localleader>x' },
        applyNext = { n = '<localleader>j' },
        applyPrev = { n = '<localleader>k' },
      },
    })
    create_autocmd()
    set_keymaps()
  end,
  create_autocmd = create_autocmd,
  set_keymaps = set_keymaps,
  open_from_explorer = open_from_explorer,
}

