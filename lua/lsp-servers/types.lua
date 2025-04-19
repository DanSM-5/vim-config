-- Types used inside lsp-settings and lsp-sources configurations

--- Same as lspconfig.Config but to avoid issues if module is not loaded
--- @class config.LspConfigExtended: vim.lsp.Config
--- @field cmd? string[]|fun(dispatchers: vim.lsp.rpc.Dispatchers): vim.lsp.rpc.PublicClient
--- @field enabled? boolean
--- @field single_file_support? boolean
--- @field filetypes? string[]
--- @field filetype? string
--- @field on_new_config? fun(new_config: config.LspConfigExtended?, new_root_dir: string)
--- @field autostart? boolean
--- @field package _on_attach? fun(client: vim.lsp.Client, bufnr: integer)
--- @field root_dir? string|fun(filename: string, bufnr: number)
--- @field use_legacy? boolean Legacy uses lspconfig['server'].setup(). New uses vim.lsp.config('server', {})

--- Options on setup to control the behavior of the server
---@class config.LspServerEntry.options
---@field keymaps? boolean|nil Additional options when configuring the server

--- Settings for lsp's configured manually
---@class config.LspServerEntry
---@field server string Name of the binary that launches the lsp server
---@field lsp string Name use in lspconfig
---@field options? config.LspServerEntry.options Additional options when configuring the server

--- Handler function that starts the lsp
---@alias config.LspHandlerFunc fun(server_name: string, options?: config.LspServerEntry.options):nil

--- Handler function for specially configured servers
---@alias config.LspSpecialSetupFunc fun(config: { lspconfig_handler: config.LspHandlerFunc }): nil

--- Options for enabling completions
---@class config.LspSettings.options
---@field enable { lazydev: boolean; crates: boolean }
---@field engine? 'cmp' | 'blink'

--- Options for lsp-settings setup function
---@class config.LspSettings
---@field completions config.LspSettings.options

--- Update capabilities function
---@alias config.UpdateCapabilities fun(base: config.LspConfigExtended): config.LspConfigExtended

--- Options for completion modules
---@class config.CompletionOpts
---@field lazydev boolean

--- Configure completion function
---@alias config.ConfigureCompletion fun(config: config.CompletionOpts)

---@class config.CompletionModule
---@field configure config.ConfigureCompletion
---@field get_update_capabilities fun(): update_capabilities: config.UpdateCapabilities

