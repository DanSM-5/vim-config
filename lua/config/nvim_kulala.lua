---Format http file. Requires kulala-fmt
---@param filename? string File to format
local format_file = function (filename)
  if vim.fn.executable('kulala-fmt') == 0 then
    vim.notify('Requires kulala-fmt!', vim.log.levels.ERROR)
    return;
  end

  -- Save before formatting
  vim.cmd.write()

  ---@type string
  local file = (filename == nil or filename == '%') and vim.fn.expand('%:p') or filename --[[@as string]]

  vim.system({ 'kulala-fmt', 'format', file }, { text = true }, function ()
    -- TODO: Handle errors?

    if filename == nil or filename == '%' then
      -- ensure latest version is loaded
      vim.schedule(vim.cmd.edit)
    end
  end)
end

---Format all http files in current directory. Requires kulala-fmt
local format_all = function ()
  vim.fn.wall()

  vim.system({ 'kulala-fmt', 'format' }, {
    text = true,
    cwd = vim.fn.getcwd(),
  }, function ()
    -- TODO: Handle errors?

    vim.schedule(vim.cmd.edit)
  end)
end

---Convert file to http
---@param format 'openapi' | 'postman' | 'bruno' Input format. Default 'openapi'.
---@param file string file to convert or a url to fetch the file to convert.
---@param on_exit? fun(file: string) Function to run on exit.
local convert = function (format, file, on_exit)
  if not (vim.uv or vim.loop).fs_stat(file) then
    return
  end

  on_exit = on_exit or vim.schedule_wrap(function (converted_file)
    vim.cmd.edit(converted_file)
  end)

  vim.system({ 'kulala-fmt', 'convert', '--from', format, file }, {
    text = true,
    stdout = function (err, data)
      if err then
        vim.schedule(function ()
          vim.notify('Could not convert file', vim.log.levels.ERROR)
        end)
        return
      end

      if data == '' or data == nil then
        return
      end

      --Sample:
      --Converted OpenAPI spec file: notes/swagger.json --> notes/swagger.default.http
      local output = require('utils.stdlib').split(data, '%-->')
      if output[2] == nil then
        return
      end

      local converted_file = string.gsub(output[2], '%s+', '')

      if (vim.uv or vim.loop).fs_stat(converted_file) then
        on_exit(converted_file)
      end
    end
  })
end

---Convert file to http
---@param format 'openapi' | 'postman' | 'bruno' Input format. Default 'openapi'.
---@param file_or_url string file to convert or a url to fetch the file to convert.
---@param outfile? string filename to use if a url was provided. Defaults to last segment of the url.
local convert_to_http = function (format, file_or_url, outfile)
  local use_format = format or 'openapi'

  if (vim.uv or vim.loop).fs_stat(file_or_url) then
    -- vim.fn.system({ 'kulala-fmt', 'convert', '--from', use_format, file_or_url })
    convert(format, file_or_url)
    return
  end

  local tmp_dir = vim.fn.tempname()
  tmp_dir = vim.fn.fnamemodify(tmp_dir, '%:p:h')
  local cwd = vim.fn.getcwd()
  local name = outfile

  if name == nil then
    -- Use last path segment as name
    local segments = require('utils.stdlib').split(file_or_url, '/')
    name = segments[#segments]
    -- Remove query string and fragment
    name = string.gsub(name, '%?.*$', '')
    name = string.gsub(name, '%#.*$', '')
  end

  local download_file = tmp_dir .. '/' .. name

  if (vim.uv or vim.loop).fs_stat(download_file) then
    vim.notify('[Convert] Out file "'..download_file..'" already exists', vim.log.levels.WARN)
    return
  end

  local final_name = cwd .. '/' .. name .. '.http'
  local on_converted = vim.schedule_wrap(function (converted_file)
    os.rename(converted_file, final_name)
    vim.cmd.edit(final_name)
    local tmp_files = vim.fn.readdir(tmp_dir)
    for _, tmp_f in ipairs(tmp_files) do
      pcall(os.remove, tmp_f)
    end
  end)

  vim.system({ 'curl', '-sL', '--create-dirs', file_or_url, '-o', download_file }, { text = true }, function ()
    convert(format, download_file, on_converted)
  end)
end

local set_commands = function ()
  local has_kulala, kulala = pcall(require, 'kulala')

  if has_kulala then

    local jump_next, jump_prev = require('utils.repeat_motion')
      .create_repeatable_pair(kulala.jump_next, kulala.jump_prev)

    local get_selected_env = function ()
      local curr_env = kulala.get_selected_env()
      vim.notify(curr_env, vim.log.levels.WARN)
    end

    ---Set an environment variable
    ---@param value string
    local set_selected_env = function(value)
      kulala.set_selected_env(value)
    end

    local commands = {
      run = kulala.run,
      runAll = kulala.run_all,
      replay = kulala.replay,
      inspect = kulala.inspect,
      showStats = kulala.show_stats,
      scratchpad = kulala.scratchpad,
      copy = kulala.copy,
      fromCurl = kulala.from_curl,
      close = kulala.close,
      open = kulala.open,
      version = kulala.version,
      toggleView = kulala.toggle_view,
      search = kulala.search,
      prev = jump_prev,
      next = jump_next,
      scriptsClearGlobal = kulala.scripts_clear_global,
      envGet = get_selected_env,
      envSet = set_selected_env,
      downloadGQL = kulala.download_graphql_schema,
      clearCache = kulala.clear_cached_files,
      format = format_file,
      formatAll = format_all,
      convert = convert_to_http,
    }


    ---Handler callback for Kulala command
    ---@param opts vim.api.keyset.create_user_command.command_args
    local command_handler = function (opts)
      local sub_command = opts.fargs[1]
      local subs = vim.tbl_keys(commands)

      -- Select in fuzzy finder
      if not sub_command then
        local fzf = require('utils.fzf')
        fzf.fzf({
          source = subs,
          fullscreen = opts.bang,
          name = 'kulala',
          fzf_opts = fzf.fzf_with_options({
            '--no-multi',
          }, 'bind'),
          sink = function (selected)
            if #selected < 2 then
              return
            end

            local sub = selected[2]
            commands[sub]()
          end
        })

        return
      end

      if not vim.tbl_contains(subs, sub_command) then
        vim.notify('[Kulala] Invalid sub command', vim.log.levels.WARN)
        return
      end

      commands[sub_command](unpack(opts.fargs, 2))
    end

    vim.api.nvim_create_user_command('Kulala', command_handler, {
      complete = function (curr)
        local match_str = '^'..string.lower(curr)
        local subs = vim.tbl_keys(commands)
        local matched = vim.tbl_filter(function (sub)
          local _, matches = string.gsub(string.lower(sub), match_str, '')
          return matches > 0
        end, subs)

        return #matched > 0 and matched or subs
      end,
      nargs = '*',
      bang = true,
      bar = true,
      desc = '[Kulala] Commands for kulala',
      force = true,
    })

    vim.api.nvim_create_user_command(
      'KulalaFormat',
      format_file, {
        desc = '[Kulala] Format current file',
        bar = true,
        nargs = 1,
        complete = 'dir',
      }
    )

    vim.api.nvim_create_user_command(
      'KulalaFormatAll',
      format_all, {
        desc = '[Kulala] Format all files in cwd',
        bar = true,
        nargs = 0,
      }
    )

    -- vim.api.nvim_create_user_command(
    --   'KulalaRun',
    --   kulala.run, {
    --     desc = '[Kulala] Run the current request',
    --     bar = true,
    --   }
    -- )
    -- vim.api.nvim_create_user_command(
    --   'KulalaRunAll',
    --   kulala.run_all, {
    --     desc = '[Kulala] Run all requests in current buffer',
    --     bar = true,
    --   }
    -- )
    -- vim.api.nvim_create_user_command(
    --   'KulalaReplay',
    --   kulala.replay, {
    --     desc = '[Kulala] Replay the last run request',
    --     bar = true,
    --   }
    -- )
    -- vim.api.nvim_create_user_command(
    --   'KulalaInspect',
    --   kulala.inspect, {
    --     desc = '[Kulala] Inspects the current request in a floating window',
    --     bar = true,
    --   }
    -- )
    -- vim.api.nvim_create_user_command(
    --   'KulalaShowStats',
    --   kulala.show_stats, {
    --     desc = '[Kulala] Shows the statistics of the last run',
    --     bar = true,
    --   }
    -- )
    -- vim.api.nvim_create_user_command(
    --   'KulalaScratchpad',
    --   kulala.scratchpad, {
    --     desc = '[Kulala] Open throwaway buffer to test requests without needed to save them',
    --     bar = true,
    --   }
    -- )
    -- vim.api.nvim_create_user_command(
    --   'KulalaCopy',
    --   kulala.copy, {
    --     desc = '[Kulala] Copies the current request as curl to clipboard',
    --     bar = true,
    --   }
    -- )
    -- vim.api.nvim_create_user_command(
    --   'KulalaFromCurl',
    --   kulala.from_curl, {
    --     desc = '[Kulala] Converts a curl cmd to http',
    --     bar = true,
    --   }
    -- )
    -- vim.api.nvim_create_user_command(
    --   'KulalaClose',
    --   kulala.close, {
    --     desc = '[Kulala] Closes the kulala window and the current buffer',
    --     bar = true,
    --   }
    -- )
    -- vim.api.nvim_create_user_command(
    --   'KulalaOpen',
    --   kulala.open, {
    --     desc = '[Kulala] Open the kulala window in the current buffer',
    --     bar = true,
    --   }
    -- )
    -- vim.api.nvim_create_user_command(
    --   'KulalaVersion',
    --   kulala.version, {
    --     desc = '[Kulala] Prints the version of kulala',
    --     bar = true,
    --   }
    -- )
    -- vim.api.nvim_create_user_command(
    --   'KulalaToggleView',
    --   kulala.toggle_view, {
    --     desc = '[Kulala] Toggles body and headers view of the last run request',
    --     bar = true,
    --   }
    -- )
    -- vim.api.nvim_create_user_command(
    --   'KulalaSearch',
    --   kulala.search, {
    --     desc = '[Kulala] Searches named requests in the current buffer and shows them with vim.ui.select',
    --     bar = true,
    --   }
    -- )
    -- local jump_next, jump_prev = require('utils.repeat_motion')
    --   .create_repeatable_pair(kulala.jump_next, kulala.jump_prev)
    -- vim.api.nvim_create_user_command(
    --   'KulalaPrev',
    --   jump_prev, {
    --     desc = '[Kulala] Jumps to the previous request',
    --     bar = true,
    --   }
    -- )
    -- vim.api.nvim_create_user_command(
    --   'KulalaNext',
    --   jump_next, {
    --     desc = '[Kulala] Jumps to the next request',
    --     bar = true,
    --   }
    -- )
    -- vim.api.nvim_create_user_command(
    --   'KulalaScriptsClearGlobal',
    --   ---@param opts { bang: boolean, fargs: string[] }
    --   function (opts)
    --     local variable = table.concat(opts.fargs, '')
    --     kulala.scripts_clear_global(variable)
    --   end, {
    --     desc = '[Kulala] Clears a global variable set via `client.global.set`',
    --     nargs = 1,
    --     bar = true,
    --   }
    -- )
    -- vim.api.nvim_create_user_command(
    --   'KulalaEnvGet',
    --   function ()
    --     local curr_env = kulala.get_selected_env()
    --     vim.notify(curr_env, vim.log.levels.WARN)
    --   end, {
    --     desc = '[Kulala] Returns the selected environment',
    --     bar = true,
    --   }
    -- )
    -- vim.api.nvim_create_user_command(
    --   'KulalaEnvSet',
    --   ---@param opts { bang: boolean, fargs: string[] }
    --   function (opts)
    --     if #opts.fargs == 0 then
    --       kulala.set_selected_env()
    --     else
    --       local env_name = table.concat(opts.fargs, '')
    --       kulala.set_selected_env(env_name)
    --     end
    --   end, {
    --     desc = '[Kulala] Sets the environment or open environment with vim.ui.select',
    --     nargs = 1,
    --     bar = true,
    --   }
    -- )
    -- vim.api.nvim_create_user_command(
    --   'KulalaDownloadGQL',
    --   kulala.download_graphql_schema, {
    --     desc = '[Kulala] Downloads graphql schema if cursor is in a graphql request',
    --     bar = true,
    --   }
    -- )
    -- vim.api.nvim_create_user_command(
    --   'KulalaClearCache',
    --   kulala.clear_cached_files, {
    --     desc = '[Kulala] Clear all cached files',
    --     bar = true,
    --   }
    -- )

  end

end

---Sets keymaps for kulala
---@param opts { buf: number } Buffer
local set_keymaps = function (opts)
  local jump_next, jump_prev = require('utils.repeat_motion')
    .create_repeatable_pair(function ()
      require('kulala').jump_next()
    end, function ()
      require('kulala').jump_prev()
    end)

  local nxo = { 'n', 'x', 'o' }
  vim.keymap.set(nxo, ']r', jump_next, {
    buffer = opts.buf,
    noremap = true,
    desc = '[Kulala] Move to next request',
  })
  vim.keymap.set(nxo, '[r', jump_prev, {
    buffer = opts.buf,
    noremap = true,
    desc = '[Kulala] Move to previous request',
  })
  vim.keymap.set('n', '<Enter>', function ()
    require('kulala').run()
  end, {
    buffer = opts.buf,
    noremap = true,
    desc = '[Kulala] Run the current request',
  })
  vim.keymap.set('n', '<localleader>f', format_file, {
    desc = '[Kulala] Format current file',
    buffer = opts.buf,
    noremap = true,
  })
  vim.keymap.set('n', '<localleader>F', format_all, {
    desc = '[Kulala] Format all files in cwd',
    buffer = opts.buf,
    noremap = true,
  })
end

local setup = function ()
  require('kulala').setup({
    -- enable reading vscode rest client environment variables
    vscode_rest_client_environmentvars = true,
    -- debug = true, -- get full stacktrace
    -- environment_scope = 'g', -- scope to buffer 'b' or global 'g'
  })
  set_commands()

  local buf = vim.api.nvim_get_current_buf()
  local filetype = vim.api.nvim_get_option_value('filetype', {
    buf = buf,
  })

  if filetype == 'http' or filetype == 'rest' then
    set_keymaps({ buf = buf })
  end
end

return {
  set_commands = set_commands,
  set_keymaps = set_keymaps,
  setup = setup,
}
