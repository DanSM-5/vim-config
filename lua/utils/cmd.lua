---Get the matching value from the a list
---Return all the options when no match is found
---@param options string[] Available options to compare against
---@param value string Value to match against
---@param opt_processor? fun(option: string): string Preprocess options when iterated against
---@return string[]
local function get_matched(options, value, opt_processor)

  ---Helper function to add an extra function call for option processing
  ---@param option string
  ---@return boolean
  local filter_fn = opt_processor and function (option)
    local _, matches = string.gsub(opt_processor(option), value, '')
    return matches > 0
  end or function (option)
    local _, matches = string.gsub(option, value, '')
    return matches > 0
  end

  local matched = vim.tbl_filter(filter_fn, options)

  return #matched > 0 and matched or options
end

return {
  get_matched = get_matched,
}
