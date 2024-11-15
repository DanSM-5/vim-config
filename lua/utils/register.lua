
---Copy the content from a register to another
---@param destination string Name of register to copy to
---@param source string Name of register to copy from
local function regmove(destination, source)
  vim.fn.setreg(destination, vim.fn.getreg(source))
end

return {
  regmove = regmove,
}

