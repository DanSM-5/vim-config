---Custom function to select correct ref
---@param commit_hash string Hash of the commit under the cursor
---@param refs string[] List of refs (tags, branches, stashes, etc.)
---@param callback fun(ref: string)
local pick_sha_or_ref = function (commit_hash, refs, callback)
  if #refs == 0 then
    callback(commit_hash)
    return
  end

  local source = { commit_hash }
  for _, ref in ipairs(refs) do
    table.insert(source, ref)
  end

  ---Sink function for fzf selection
  ---Sink function will always have an empty string as first item (1 index based)
  ---for the `--expect` flag in fzf, so real value needs to be checked at index 2.
  ---@param selected string[] List of selected items.
  local sink = function (selected)
    if #selected < 2 then
      return
    end
    callback(selected[2])
  end

  local preview_cmd = string.format(
    'git show --color=always {} %s | %s',
    vim.fn.executable('delta') and '| delta ' or '',
    vim.fn.executable('bat') and ' bat -p --color=always ' or ' cat'
  )

  local fzf = require('utils.fzf')
  fzf.fzf({
    source = source,
    fzf_opts = require('utils.stdlib').concat(fzf.fzf_bind_options, {
      '--prompt', 'Select Ref> ',
      '--no-multi',
      '--preview-window', '70%',
      '--preview', preview_cmd,
    }),
    name = 'git-commit',
    fullscreen = false,
    sink = sink,
  })
end

return {
  setup = function ()
    require('cursor-git-ref-command').setup({
      pick_sha_or_ref = pick_sha_or_ref,
    })
  end,
}

