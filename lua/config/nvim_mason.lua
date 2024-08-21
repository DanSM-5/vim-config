-- Meson config
return {
  get_config = function()
    return {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
        }
      }
    }
  end
}
