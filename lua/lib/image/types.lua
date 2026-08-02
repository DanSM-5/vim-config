---@meta

---@alias LibImageBackendName 'auto'|'kitty'|'iterm2'|'sixel'|string
---@alias LibImageLayoutKind 'float'|'tab'|'preview'|'window'

---@class LibImageSource
---@field data? string Raw source bytes.
---@field mime? string MIME type for `data`.
---@field name? string Display name or filename hint.
---@field path? string Local path after resolution.
---@field uri? string Original URI.
---@field cleanup? fun() Releases request-owned temporary files.

---@class LibImageTarget
---@field kind? LibImageLayoutKind
---@field winid? integer Required by the `window` layout.
---@field bufnr? integer Existing buffer to retain in the target window.
---@field focus? boolean Whether a newly created layout should receive focus.

---@class LibImagePreviewOpts
---@field bufnr? integer Buffer used for relative paths and local configuration.
---@field row? integer Optional 1-indexed row for `preview_at_cursor()`.
---@field column? integer Optional 0-indexed byte column for `preview_at_cursor()`.
---@field explicit? boolean Permit any readable file to reach the conversion pipeline.
---@field notify? boolean Override user-facing error notifications for this request.
---@field target? LibImageTarget

---@class LibImagePreviewResult
---@field handled boolean Whether the source or cursor location was claimed.
---@field id? integer Request identifier.
---@field error? string Immediate validation error.

---@class LibImageStatus
---@field active boolean
---@field generation? integer
---@field id? integer
---@field phase? 'resolving'|'converting'|'layout'|'encoding'|'ready'|'error'
---@field error? string
---@field source? string|LibImageSource
---@field source_bufnr? integer
---@field backend? string
---@field winid? integer
---@field bufnr? integer

---@class LibImageResolvedCursor
---@field target string
---@field kind 'markdown_image'|'html_image'|'cursor_path'
---@field range? integer[] `{ start_row, start_col, end_row, end_col }`.

---@class LibImageCapabilities
---@field neovim boolean
---@field backends table<string, boolean>
---@field executables table<string, boolean>
---@field parsers table<string, boolean>
---@field remote_schemes string[]

---@class LibImageResolverContext
---@field bufnr integer
---@field base_dir string

---@class LibImageNormalizedImage
---@field data string PNG bytes.
---@field width integer Pixel width.
---@field height integer Pixel height.
---@field name string

---@class LibImageBackend
---@field name string
---@field available fun(config: LibImageConfig): boolean
---@field encode fun(data: string, layout: table, cell_width: number, cell_height: number, config: LibImageConfig, callback: fun(encoded: unknown?, err: string?)): table?
---@field draw fun(encoded: unknown, layout: table): boolean
---@field clear fun(encoded?: unknown)

---@class LibImageConfig
---@field backend LibImageBackendName
---@field notify boolean
---@field markdown LibImageMarkdownConfig
---@field auto_preview LibImageAutoPreviewConfig
---@field layout LibImageLayoutConfig
---@field renderer LibImageRendererConfig
---@field conversion LibImageConversionConfig
---@field remote LibImageRemoteConfig

---@class LibImageMarkdownConfig
---@field filetypes string[]
---@field html boolean
---@field reference_links boolean

---@class LibImageAutoPreviewConfig
---@field enabled boolean
---@field extensions string[]

---@class LibImageLayoutConfig
---@field default LibImageLayoutKind
---@field close_keys string[]
---@field float LibImageFloatConfig
---@field preview LibImagePreviewWindowConfig

---@class LibImageFloatConfig
---@field max_width number Integer cells or a fraction of the editor width.
---@field max_height number Integer cells or a fraction of the editor height.
---@field border string|string[]
---@field title boolean|string|fun(source: LibImageSource): string?
---@field title_pos 'left'|'center'|'right'
---@field zindex integer

---@class LibImagePreviewWindowConfig
---@field height number Integer rows or a fraction of the editor height.
---@field vertical boolean
---@field width number Integer columns or a fraction of the editor width.

---@class LibImageRendererConfig
---@field terminal_query_timeout integer
---@field fallback_cell_width number
---@field fallback_cell_height number
---@field kitty LibImageKittyConfig
---@field sixel LibImageSixelConfig

---@class LibImageKittyConfig
---@field chunk_size integer Maximum base64 payload bytes per protocol command, capped at 4096.
---@field force boolean Select Kitty in `auto` mode when environment detection is unavailable.

---@class LibImageSixelConfig
---@field command string
---@field work integer

---@class LibImageConversionConfig
---@field mcat string
---@field ffmpeg string
---@field ghostscript string
---@field libreoffice string
---@field max_input_bytes integer
---@field timeout integer
---@field video_seek number

---@class LibImageRemoteConfig
---@field enabled boolean
---@field curl string
---@field timeout integer
---@field max_bytes integer
---@field schemes string[]

---@alias LibImageResolver fun(input: string, context: LibImageResolverContext, config: LibImageConfig, callback: fun(source: LibImageSource?, err: string?)): table?

return {}
