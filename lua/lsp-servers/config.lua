return {
  get_config = function()
    return {
      ['lua_ls'] = {},
      vimls = {},
      biome = {},
      -- For bash lsp
      bashls = {
        settings = {
          bashIde = {
            globPattern = '*@(.sh|.inc|.bash|.command|.zsh|.uconfrc|.uconfgrc|.ualiasrc|.ualiasgrc)'
          }
        }
      }
    }
  end
}