
return {
  {
    'oflisback/cursor-git-ref-command.nvim',
    config = function ()
      require('cursor-git-ref-command').setup({
        pick_sha_or_ref = function (commit_hash, refs, callback)
          if #refs == 0 then
            callback(commit_hash)
            return
          end

          local source = { commit_hash }
          for _, ref in ipairs(refs) do
            table.insert(source, ref)
          end

          local sink = function (selected)
            if #selected < 2 then
              return
            end
            callback(selected[2])
          end

          local fzf = require('utils.fzf')
          fzf.fzf({
            source = source,
            fzf_opts = require('utils.stdlib').concat(fzf.fzf_bind_options, {
              '--prompt', 'Select Ref> ',
              '--no-multi',
            }),
            name = 'git-commit',
            fullscreen = false,
            sink = sink,
          })
        end
      })
    end
  },
}

