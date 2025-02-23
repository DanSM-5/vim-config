local create_autocmd = function()
  ---Options for DevDocsOpen command
  ---@param opts { bang: boolean; fargs?: string[]; }
  vim.api.nvim_create_user_command('DevDocsOpen', function(opts)
    local devdocs = require('devdocs')
    local installedDocs = devdocs.GetInstalledDocs()
    local fzf = require('utils.fzf')

    local on_doc = function(selected)
      if #selected < 2 then
        return
      end
      local docDir = vim.fn.substitute(devdocs.GetDocDir(selected[2]) or '', '\\', '/', 'g')
      vim.print('DocDir:' .. docDir)
      vim.fn['fzfcmd#fzf_files'](docDir, fzf.fzf_preview_options, opts.bang and 1 or 0)
    end

    local options = {
      '--no-multi',
    }
    if #opts.fargs > 0 then
      table.insert(options, '--query')
      table.insert(options, table.concat(opts.fargs, ' '))
    end

    fzf.fzf({
      source = installedDocs,
      fullscreen = opts.bang,
      name = 'devdocs',
      sink = on_doc,
      fzf_opts = require('utils.stdlib').concat(fzf.fzf_bind_options, options),
    })
  end, { desc = '[DevDocs] Open devdocs', bang = true, bar = true, nargs = '*', force = true })

  local complete_func = function ()
    return require('devdocs').GetInstalledDocs()
  end

  local on_delete = function(doc)
    local devdocs = require('devdocs')
    local dir = devdocs.GetDocDir(doc)
    if not vim.fn.isdirectory(dir) then
      return
    end

    if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 or os.getenv('OS') == 'Windows_NT' then
      os.execute(
        "powershell.exe -NoLogo -NonInteractive -NoProfile -Command Remove-Item -ErrorAction SilentlyContinue -Recurse -Force -LiteralPath '"
          .. dir
          .. "'"
      )
    else
      os.execute("rm -rf '" .. dir .. "'")
    end
  end

  vim.api.nvim_create_user_command(
    'DevDocsRemove',
    ---Options for DevDocsOpen command
    ---@param opts { bang: boolean; fargs?: string[]; }
    function(opts)
      if #opts.fargs > 0 then
        on_delete(opts.fargs[1])
        return
      end

      local devdocs = require('devdocs')
      local installedDocs = devdocs.GetInstalledDocs()
      local fzf = require('utils.fzf')
      local on_doc = function(selected)
        if #selected < 2 then
          return
        end
        on_delete(selected[2])
      end

      fzf.fzf({
        source = installedDocs,
        fullscreen = opts.bang,
        name = 'devdocs',
        sink = on_doc,
        fzf_opts = require('utils.stdlib').concat(fzf.fzf_bind_options, {
          '--no-multi',
        }),
      })
    end,
    {
      desc = '[DevDocs] Remove docs',
      bang = true,
      bar = true,
      nargs = '?',
      complete = complete_func,
      force = true,
    }
  )
end

return {
  setup = function()
    local devdocs = require('devdocs')

    devdocs.setup({
      -- ensure_installed = {
      --   -- "go",
      --   "html",
      --   "dom",
      --   "http",
      --   "css",
      --   "javascript",
      --   -- "rust",
      --   -- some docs such as lua require version number along with the language name
      --   -- check `DevDocs install` to view the actual names of the docs
      --   "lua~5.1",
      --   -- "openjdk~21"
      -- },
    })

    create_autocmd()
  end,
  create_autocmd = create_autocmd,
}
