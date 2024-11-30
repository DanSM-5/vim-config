-- Types used inside lsp-settings and lsp-sources configurations

--- Same as lspconfig.Config but to avoid issues if module is not loaded
--- @class LspConfigExtended: vim.lsp.ClientConfig
--- @field enabled? boolean
--- @field single_file_support? boolean
--- @field filetypes? string[]
--- @field filetype? string
--- @field on_new_config? fun(new_config: LspConfigExtended?, new_root_dir: string)
--- @field autostart? boolean
--- @field package _on_attach? fun(client: vim.lsp.Client, bufnr: integer)
--- @field root_dir? string|fun(filename: string, bufnr: number)

--- Options on setup to control the behavior of the server
---@class LspServersSettings.options
---@field keymaps? boolean|nil Additional options when configuring the server

--- Settings for lsp's configured manually
---@class LspServersSettings
---@field server string Name of the binary that launches the lsp server
---@field lsp string Name use in lspconfig
---@field options? LspServersSettings.options Additional options when configuring the server

--- Handler function that starts the lsp
---@alias LspHandlerFunc fun(server_name: string, options?: LspServersSettings.options):nil

--- Handler function for specially configured servers
---@alias LspSpecialSetupFunc fun(config: { lspconfig_handler: LspHandlerFunc }): nil

--- Options for enabling completions
---@class LspSettings.options
---@field enable { lazydev: boolean; crates: boolean }

--- Options for lsp-settings setup function
---@class LspSetttings
---@field completions LspSettings.options

