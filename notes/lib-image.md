# `lib.image`

`lib.image` is a lazy, Neovim-specific image preview library. It resolves local
paths or URLs, converts supported inputs to PNG, and renders one active preview
through a terminal graphics backend. The public API and LuaDoc types live in
[`lua/lib/image/init.lua`](../lua/lib/image/init.lua) and
[`lua/lib/image/types.lua`](../lua/lib/image/types.lua).

## Requirements

- Neovim 0.12 or newer.
- A Sixel-capable terminal, such as Windows Terminal or WezTerm.
- `chafa` for the current Sixel backend.
- `mcat` as the primary file-to-image converter.
- Tree-sitter parsers `markdown`, `markdown_inline`, and `html` for Markdown
  cursor previews.

Optional tools enable additional inputs or fallbacks:

- `curl` for HTTP and HTTPS sources.
- `ffmpeg` for video and animated-image thumbnails when `mcat` cannot convert
  them.
- Ghostscript (`gs` on Unix, `gswin64c` on Windows) for PDF fallback.
- `soffice` for Office-document fallback; it converts the first page through
  PDF and Ghostscript.

Inspect the current environment from Neovim with:

```lua
vim.print(require('lib.image').capabilities())
```

The result reports the Neovim version check, available backends, executables,
Tree-sitter parsers, and registered URI schemes.

## Basic use

```lua
local image = require('lib.image')

image.preview_float('/path/to/image.png')
image.preview_tab('/path/to/document.pdf')
image.preview_window('https://example.com/image.webp')
image.preview_in_window('/path/to/video.mp4', vim.api.nvim_get_current_win())

local result = image.preview_at_cursor()
if not result.handled then
  vim.lsp.buf.hover({ border = 'rounded' })
end

image.redraw()
image.close()
```

Relative Markdown paths are resolved against the current buffer. Inline
images, reference-style images, and HTML `<img src="...">` elements are
supported. Explicit `preview*()` calls may attempt any readable format;
automatic preview buffers are restricted to configured extensions.

The lower-level API also exposes `resolve_source()`, `normalize()`,
`register_resolver()`, and `register_backend()` for plugin adapters or future
URI schemes and graphics protocols.

## Configuration

The effective configuration is merged in this order:

1. Immutable defaults.
2. Internal overrides applied by `config()`.
3. `g:lib_image_config`.
4. `b:lib_image_config` for the requested buffer.

```lua
local image = require('lib.image')

image.config({
  layout = {
    float = { max_width = 0.9, max_height = 0.9 },
  },
  remote = { enabled = true },
})

vim.g.lib_image_config = {
  conversion = { video_seek = 2 },
}

vim.b.lib_image_config = {
  auto_preview = { enabled = false },
}
```

`restore()` resets only the internal overrides. It never changes global or
buffer-local variables. See the defaults and merge implementation in
[`lua/lib/image/config.lua`](../lua/lib/image/config.lua).

## Commands and automatic integration

Call the setup module once during startup:

```lua
require('config.lib_image').setup()
```

The repository does this from
[`lua/shared/nvim_load.lua`](../lua/shared/nvim_load.lua). The setup and
autocommands are defined in
[`lua/config/lib_image.lua`](../lua/config/lib_image.lua) and provide:

- `:PreviewImage [path-or-URI]` — floating preview.
- `:PreviewImage! [path-or-URI]` — fullscreen preview in a new tab.
- `:PreviewImage? [path-or-URI]` — reusable preview window.
- `:PreviewImageWindow [path-or-URI]` — explicit alias for the preview window.
- `:PreviewImageClose` and `:PreviewImageRedraw`.
- Automatic preview buffers for configured raster, SVG, PDF, and video
  extensions.
- Resize, scroll, buffer-lifecycle, and independent-Canola event handling.

The recommended Markdown `K` behavior is implemented buffer-locally when an
LSP attaches in
[`lua/lsp-servers/keymaps.lua`](../lua/lsp-servers/keymaps.lua): an image under
the cursor opens in a float, other Markdown elements use LSP hover, and native
`K` is restored after the last client detaches.

Oil and Oil-compatible Canola pass their preview window through
[`lua/config/oil_nvim.lua`](../lua/config/oil_nvim.lua). The separate `canola`
filetype uses the adapter in `config.lib_image`.

## Tests

Tests belong in the repository-level [`tests/lib/image/`](../tests/lib/image/)
directory. This mirrors the production module hierarchy while keeping test
helpers outside Neovim's runtime Lua namespace.

```sh
nvim --clean --headless \
  --cmd 'set runtimepath^=.' \
  --cmd 'set runtimepath^=~/.local/share/nvim/site' \
  -l tests/lib/image/spec.lua

nvim --clean --headless \
  --cmd 'set runtimepath^=.' \
  --cmd 'set runtimepath^=~/.local/share/nvim/site' \
  -l tests/lib/image/external_spec.lua
```

The unit suite covers configuration, Markdown parsing, commands, layouts,
adapters, and LSP keymaps. The external suite exercises installed converters
and the Sixel encoder.
