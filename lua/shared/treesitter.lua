-- Shared treesitter setup/helpers.

local M = {}

-- Filetype -> parser (lang) aliases.
--
-- nvim-treesitter's `main` branch does NOT register filetype->parser aliases,
-- and Neovim core's `vim.treesitter.language.get_lang()` falls back to the
-- filetype name when nothing is registered. So for any filetype whose name
-- differs from the parser (lang) name, `vim.treesitter.get_parser()` fails and
-- every core-treesitter feature silently skips that buffer (highlighting, folds,
-- and our mini.ai treesitter quote textobjects -- see config/nvim_mai.lua).
--
-- Mapping is `parser (lang) -> { extra filetypes }`. Filetypes that already
-- match their parser name (bash, zsh, typescript, javascript, json, jsonc,
-- json5, lua, vim, python, ...) need no entry.
M.filetype_aliases = {
  bash = { 'sh' },
  powershell = { 'ps1' },
  tsx = { 'typescriptreact' },
  javascript = { 'javascriptreact' },
}

-- Register the aliases. `vim.treesitter.language.register(lang, fts)` is
-- additive: it preserves the default <filetype> == <lang> mappings.
function M.load()
  for lang, filetypes in pairs(M.filetype_aliases) do
    vim.treesitter.language.register(lang, filetypes)
  end
end

return M
