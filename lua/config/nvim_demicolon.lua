return {
  setup = function()
    -- initialize
    require('demicolon').setup({})
    -- Custom repeats
    local jump = require('demicolon.jump')

    ---@class RepeatOptions
    ---@field forward boolean
    ---@field on_forward function
    ---@field on_backward function

    ---Function to make jumpconflict repeatable
    ---@param options RepeatOptions
    local repeat_wrapper = function(options)
      local repeat_func = function()
        ---Main repeatable logic
        ---@param opts RepeatOptions
        jump.repeatably_do(function(opts)
          if opts.forward == nil or opts.forward then
            opts.on_forward()
          else
            opts.on_backward()
          end
        end, options)
      end

      return repeat_func
    end

    vim.api.nvim_create_autocmd('VimEnter', {
      desc = 'Create repeatable bindings',
      pattern = { '*' },
      callback = function()
        local nxo = { 'n', 'x', 'o' }

        -- Jump to next conflict
        local jumpconflict_next = function()
          vim.cmd([[execute "normal \<Plug>JumpconflictContextNext"]])
        end
        local jumpconflict_prev = function()
          vim.cmd([[execute "normal \<Plug>JumpconflictContextPrevious"]])
        end
        vim.keymap.set(
          'n',
          ']n',
          repeat_wrapper({ forward = true, on_backward = jumpconflict_prev, on_forward = jumpconflict_next }),
          { desc = '[JumpConflict] Move to next conflict marker', noremap = true }
        )
        vim.keymap.set(
          'n',
          '[n',
          repeat_wrapper({ forward = false, on_backward = jumpconflict_prev, on_forward = jumpconflict_next }),
          { desc = '[JumpConflic] Move to previous conflict marker', noremap = true }
        )

        -- Move items in quickfix
        local quickfix_next = function()
          vim.cmd('silent! cnext')
        end
        local quickfix_prev = function()
          vim.cmd('silent! cprev')
        end
        vim.keymap.set(
          nxo,
          ']q',
          repeat_wrapper({ forward = true, on_forward = quickfix_next, on_backward = quickfix_prev }),
          {
            desc = '[Quickfix] Move to next error',
            noremap = true,
          }
        )
        vim.keymap.set(
          nxo,
          '[q',
          repeat_wrapper({ forward = false, on_forward = quickfix_next, on_backward = quickfix_prev }),
          {
            desc = '[Quickfix] Move to previous error',
            noremap = true,
          }
        )

        -- Move using aerial
        local aerial_next = function()
          vim.cmd('AerialNext')
        end
        local aerial_prev = function()
          vim.cmd('AerialPrev')
        end
        vim.keymap.set(
          nxo,
          ']a',
          repeat_wrapper({ forward = true, on_forward = aerial_next, on_backward = aerial_prev }),
          {
            desc = '[Aerial] Move to next symbol',
            noremap = true,
          }
        )
        vim.keymap.set(
          nxo,
          '[a',
          repeat_wrapper({ forward = false, on_forward = aerial_next, on_backward = aerial_prev }),
          {
            desc = '[Aerial] Move to previous symbol',
            noremap = true,
          }
        )
      end,
    })
  end,
}
