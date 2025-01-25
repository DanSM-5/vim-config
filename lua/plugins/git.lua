
return {
  {
    'tpope/vim-fugitive',
    dependencies = {
      'tpope/vim-rhubarb',
    }
  },
  {
    'jecaro/fugitive-difftool.nvim',
    cmd = {
      -- To the first
      'Gcfr',
      -- To the last
      'Gcla',
      -- To the next
      'Gcn',
      -- To the previous
      'Gcp',
      -- To the currently selected
      'Gcc',
    },
    -- Usage
    -- :Git! difftool --name-status master..my-feature
    -- :Gcc
    config = function ()
      require('config.nvim_figitive-difftool').setup()
    end,
  },
  {
    'rbong/vim-flog',
    lazy = true,
    cmd = { 'Flog', 'Flogsplit', 'Floggit' },
    dependencies = {
      'tpope/vim-fugitive',
    },
  },
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
      })
    end
  },
}

