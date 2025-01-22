-- Collection of utility functions
-- There must not be imports on the top level of this script

---Concatenates 2 arrays
---@generic T
---@param t1 T[]
---@param t2 T[]
---@return T[]
local function array_concat(t1, t2)
  local result = {}
  for _, v in ipairs(t1) do table.insert(result, v) end
  for _, v in ipairs(t2) do table.insert(result, v) end
  return result
end

---Split the string into a list using the separator as delimiter
---@param inputstr string String to split
---@param sep string Character or group of characters to use for separator
---@return string[] List of strings after split
local function split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, '([^'..sep..']+)') do
    table.insert(t, str)
  end
  return t
end

---Echo a message using a specific highlight group
---Defaults to WarningMsg highlight group
--- Usage:
--- echo('WarningMsg', 'Some message')
---@param hlgroup string Highlight group to use. See `:h hi`.
---@param msg string Message to echo
local function echo(hlgroup, msg)
  local group = hlgroup
  if not group then
    group = 'WarningMsg'
  end
  vim.cmd('echohl ' .. group)
  vim.cmd('echo "' .. msg .. '"')
  vim.cmd('echohl None')
end

---Shallow copy a table
---@generic T Type of the table to shallow clone
---@param t T Table to shallow clone
---@return T New table with same keys and values from the original
local function shallow_clone(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

---Find the root directory or a given file
---@param lookFor string Name of the file to look for
---@return string|nil Path of the file name provided
local function find_root(lookFor)
  local path_to_file = vim.fs.find(lookFor, {
    path = vim.fn.expand('%:p:h'),
    upward = true,
  })[1]

  local root_dir = vim.fs.dirname(path_to_file)

  return root_dir
end

return {
  find_root = find_root,
  concat = array_concat,
  split = split,
  echo = echo,
  shallow_clone = shallow_clone,
}

