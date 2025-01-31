
---@return string?
local function head(file)
  local f = io.open(file)
  if f then
    local ret = f:read()
    f:close()
    return ret
  end
end

---@return {branch: string, hash:string}?
local function git_info(dir)
  local path = vim.fn.expand(dir)
  local line = head(path .. '/.git/HEAD')
  if line then
    ---@type string, string
    local ref, branch = line:match("ref: (refs/heads/(.*))")

    if ref then
      return {
        branch = branch,
        hash = head(path .. '/.git/' .. ref),
      }
    end
  end
end

return {
  head = head,
  git_info = git_info,
}

