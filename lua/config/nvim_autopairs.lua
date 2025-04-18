return {
  ---Setup function for nvim-autopairs
  ---@param opts? { use_cmp?: boolean; }
  setup = function (opts)
    opts = opts or {}
    -- Don't add pairs if the next char is alphanumeric
    local autopairs = require('nvim-autopairs')
    -- local Rule = require('nvim-autopairs.rule')
    local cond = require('nvim-autopairs.conds')

    -- setup
    autopairs.setup({
      -- ignored_next_char = "[%w%.]", -- will ignore alphanumeric and `.` symbol
      -- enable_check_bracket_line = false,
    })

    -- Prevent pair if previous is alphanumeric and `.`
    autopairs.get_rules('"')[1]:with_pair(cond.not_before_regex("[%w%.]"))
    autopairs.get_rules('`')[1]:with_pair(cond.not_before_regex("[%w%.]"))
    autopairs.get_rules("'")[1]:with_pair(cond.not_before_regex("[%w%.]"))

    if opts.use_cmp then
      -- If you want to automatically add `(` after selecting a function or method
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      local cmp = require('cmp')
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end
  end
}
