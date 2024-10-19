---@class RepeatOptions
---@field forward boolean Initial movement of motion
---@field on_forward function Callback when moving forward
---@field on_backward function Callback when moving backward

return {
  ---Creates repeatable motions for ',' and ';' using demicolon plugin.
  ---The on_forward and on_backward will be used for directionality of the movement
  ---The forward prop is important as it signals the initial direction of the motion
  ---and it is used by demicolon (it mutates the ref object) to keep track of the directionality
  ---@param options RepeatOptions
  repeat_pair = function(options)
    local repeatably_do = require('demicolon.jump').repeatably_do
    local repeat_func = function()
      ---Main repeatable logic
      ---@param opts RepeatOptions
      repeatably_do(function(opts)
        if opts.forward == nil or opts.forward then
          opts.on_forward()
        else
          opts.on_backward()
        end
      end, options)
    end

    return repeat_func
  end,

  ---Creates dot repeatable motions using vim-repeat and repeatable.vim
  ---@param map_string string string to be use for mapping e.g. "mode lhs rhs"
  repeat_dot = function (map_string)
    -- Repeatable nnoremap <silent>mlu :<C-U>m-2<CR>==
    -- vim.cmd.Repeatable('nnoremap <silent>[g :tabprevious')
    vim.cmd.Repeatable(map_string)
  end
}
