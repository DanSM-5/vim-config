
local has_kulala, kulala = pcall(require, 'kulala')

if has_kulala then
  vim.api.nvim_create_user_command(
    'KulalaRun',
    kulala.run, {
      desc = '[Kulala] Run the current request',
      bar = true,
    }
  )
  vim.api.nvim_create_user_command(
    'KulalaRunAll',
    kulala.run_all, {
      desc = '[Kulala] Run all requests in current buffer',
      bar = true,
    }
  )
  vim.api.nvim_create_user_command(
    'KulalaReplay',
    kulala.replay, {
      desc = '[Kulala] Replay the last run request',
      bar = true,
    }
  )
  vim.api.nvim_create_user_command(
    'KulalaInspect',
    kulala.inspect, {
      desc = '[Kulala] Inspects the current request in a floating window',
      bar = true,
    }
  )
  vim.api.nvim_create_user_command(
    'KulalaShowStats',
    kulala.show_stats, {
      desc = '[Kulala] Shows the statistics of the last run',
      bar = true,
    }
  )
  vim.api.nvim_create_user_command(
    'KulalaScratchpad',
    kulala.scratchpad, {
      desc = '[Kulala] Open throwaway buffer to test requests without needed to save them',
      bar = true,
    }
  )
  vim.api.nvim_create_user_command(
    'KulalaCopy',
    kulala.copy, {
      desc = '[Kulala] Copies the current request as curl to clipboard',
      bar = true,
    }
  )
  vim.api.nvim_create_user_command(
    'KulalaClose',
    kulala.close, {
      desc = '[Kulala] Closes the kulala window and the current buffer (.http or .rest file)',
      bar = true,
    }
  )
  vim.api.nvim_create_user_command(
    'KulalaToggleView',
    kulala.toggle_view, {
      desc = '[Kulala] Toggles body and headers view of the last run request',
      bar = true,
    }
  )
  vim.api.nvim_create_user_command(
    'KulalaSearch',
    kulala.search, {
      desc = '[Kulala] Searches named requests in the current buffer and shows them with vim.ui.select',
      bar = true,
    }
  )
  vim.api.nvim_create_user_command(
    'KulalaPrev',
    kulala.jump_prev, {
      desc = '[Kulala] Jumps to the previous request',
      bar = true,
    }
  )
  vim.api.nvim_create_user_command(
    'KulalaNext',
    kulala.jump_next, {
      desc = '[Kulala] Jumps to the next request',
      bar = true,
    }
  )
  vim.api.nvim_create_user_command(
    'KulalaScriptsClearGlobal',
    ---@param opts { bang: boolean, fargs: string[] }
    function (opts)
      local variable = table.concat(opts.fargs, '')
      kulala.scripts_clear_global(variable)
    end, {
      desc = '[Kulala] Clears a global variable set via `client.global.set`',
      nargs = 1,
      bar = true,
    }
  )
  vim.api.nvim_create_user_command(
    'KulalaEnvGet',
    function ()
      local curr_env = kulala.get_selected_env()
      vim.notify(curr_env, vim.log.levels.WARN)
    end, {
      desc = '[Kulala] Returns the selected environment',
      bar = true,
    }
  )
  vim.api.nvim_create_user_command(
    'KulalaEnvSet',
    ---@param opts { bang: boolean, fargs: string[] }
    function (opts)
      if #opts.fargs == 0 then
        kulala.set_selected_env()
      else
        local env_name = table.concat(opts.fargs, '')
        kulala.set_selected_env(env_name)
      end
    end, {
      desc = '[Kulala] Sets the environment or open environment with vim.ui.select',
      nargs = 1,
      bar = true,
    }
  )
  vim.api.nvim_create_user_command(
    'KulalaDownloadGQL',
    kulala.download_graphql_schema, {
      desc = '[Kulala] Downloads graphql schema if cursor is in a graphql request',
      bar = true,
    }
  )
  vim.api.nvim_create_user_command(
    'KulalaClearCache',
    kulala.clear_cached_files, {
      desc = '[Kulala] Clear all cached files',
      bar = true,
    }
  )

end

