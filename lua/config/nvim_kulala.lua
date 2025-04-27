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
      Run = kulala.run,
      RunAll = kulala.run_all,
      Replay = kulala.replay,
      Inspect = kulala.inspect,
      ShowStats = kulala.show_stats,
      Scratchpad = kulala.scratchpad,
      Copy = kulala.copy,
      FromCurl = kulala.from_curl,
      Close = kulala.close,
      Open = kulala.open,
      Version = kulala.version,
      ToggleView = kulala.toggle_view,
      Search = kulala.search,
      Prev = jump_next,
      Next = jump_prev,
      ScriptsClearGlobal = kulala.scripts_clear_global,
      EnvGet = get_selected_env,
      EnvSet = set_selected_env,
      DownloadGQL = kulala.download_graphql_schema,
      ClearCache = kulala.clear_cached_files,
    }

    ---Handler callback for Kulala command
    ---@param opts vim.api.keyset.create_user_command.command_args
    local command_handler = function (opts)
      local sub_command = opts.fargs[1]

      -- Select in fuzzy finder
      if not sub_command then
        local fzf = require('utils.fzf')
        fzf.fzf({
          source = vim.tbl_keys(commands),
          fullscreen = opts.bang,
          name = 'kulala',
          fzf_opts = fzf.fzf_with_options({
            '--no-mulit',
          }, 'bind'),
          sink = function (selected)
            if #selected < 2 then
              return
            end

            local sub = selected[2]
            commands[sub]()
          end
        })
      end

      local subs = vim.tbl_keys(commands)
      if not vim.tbl_contains(subs, sub_command) then
        vim.notify('[Kulala] Invalid sub command', vim.log.levels.WARN)
        return
      end

      commands[sub_command](unpack(opts.fargs, 2))
    end

    vim.api.nvim_create_user_command('Kulala', command_handler, {
      complete = function (curr)
        local subs = vim.tbl_keys(commands)
        local matched = vim.tbl_filter(function (sub)
          local _, matches = string.gsub(sub, curr, '')
          return matches > 0
        end, subs)

        return #matched > 0 and matched or subs
      end,
      bang = true,
      bar = true,
      desc = '[Kulala] Commands for kulala',
      force = true,
    })

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
