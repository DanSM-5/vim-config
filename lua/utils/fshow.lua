---Open fshow script in a floating terminal window
---@param dir? string
local function fshow(dir)
  -- TODO: Consider make the fshow script a standalone script in path "user-scripts"
  -- rather than a utility script.
  local cwd = dir or vim.fn['utils#git_path']()
  local script_preview = vim.fn.stdpath('config') .. '/utils/lazy-git-preview'
  ---@type string[]
  local script_cmd = {}

  if vim.fn.has('win32') == 1 then
    script_cmd = {
      '-NoLogo',
      '-NonInteractive', '-NoProfile',
      '-ExecutionPolicy', 'Bypass',
      '-File', script_preview .. '.ps1',
    }
    if vim.fn.executable('pwsh') then
      table.insert(script_cmd, 1, 'pwsh.exe')
    else
      table.insert(script_cmd, 1, 'powershell.exe')
    end
  else
    script_cmd = { script_preview .. '.sh' }
  end

  require('utils.nvim').float_term(script_cmd, {
    term_opts = {
      cwd = cwd,
      env = {
        IS_TERMUX = vim.g.is_termux == 1 and 'true' or 'false',
      },
    },
  })
end

---Open git log in a floating terminal buffer
---@param dir? string
local function git_log(dir)
  local cwd = dir or vim.fn['utils#git_path']()
  require('utils.nvim')
    .float_term({
      'git', 'log', '--oneline', '--decorate', '--graph'
    }, {
      term_opts = {
        cwd = cwd,
      },
    })
end

return {
  fshow = fshow,
  git_log = git_log,
}

