-- Run with:
-- XDG_STATE_HOME=/tmp/lib-image-state XDG_CACHE_HOME=/tmp/lib-image-cache \
-- nvim --clean --headless --cmd 'set rtp^=.' \
--   --cmd 'set rtp^=$HOME/.local/share/nvim/site' -l tests/lib/image/spec.lua

local assertions = 0

local function equal(actual, expected, message)
  assertions = assertions + 1
  if not vim.deep_equal(actual, expected) then
    error(
      (message or 'values differ') .. '\nexpected: ' .. vim.inspect(expected) .. '\nactual:   ' .. vim.inspect(actual),
      2
    )
  end
end

local function truthy(value, message)
  assertions = assertions + 1
  if not value then
    error(message or 'expected a truthy value', 2)
  end
end

local function wait_for(predicate, message)
  truthy(vim.wait(10000, predicate, 10), message or 'timed out')
end

local function listed_unnamed_buffers()
  local result = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted and vim.api.nvim_buf_get_name(bufnr) == '' then
      table.insert(result, bufnr)
    end
  end
  return result
end

local image = require('lib.image')
local process = require('lib.image.process')
vim.cmd('filetype on')
local tiny_png =
  vim.base64.decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=')

-- Internal, global, and buffer-local configuration precedence. Lists replace.
vim.g.lib_image_config = nil
vim.b.lib_image_config = nil
image.restore()
image.config({ backend = 'internal', layout = { close_keys = { 'x' } } })
vim.g.lib_image_config = { backend = 'global', notify = false }
vim.b.lib_image_config = { backend = 'buffer' }
local effective = image.get_config()
equal(effective.backend, 'buffer', 'buffer-local config must have highest priority')
equal(effective.notify, false, 'global config must override internal config')
equal(effective.layout.close_keys, { 'x' }, 'configuration lists must replace defaults')
image.restore()
effective = image.get_config()
equal(effective.backend, 'buffer', 'restore must not mutate b:lib_image_config')
equal(effective.layout.close_keys, { 'q', '<Esc>' }, 'restore must reset only the internal table')
truthy(vim.g.lib_image_config ~= nil and vim.b.lib_image_config ~= nil, 'restore must retain g:/b: overrides')
vim.g.lib_image_config = nil
vim.b.lib_image_config = nil

-- Markdown inline images, reference images, and HTML <img> nodes.
local markdown_buf = vim.api.nvim_get_current_buf()
vim.bo[markdown_buf].filetype = 'markdown'
vim.api.nvim_buf_set_lines(markdown_buf, 0, -1, false, {
  'one ![A](img/a.png) two <img src="other/b.webp">',
  '',
  '[logo]: refs/c.svg "Logo"',
  '![x][logo]',
  '![space](<images/a b.png>)',
  '![remote](s3://bucket/image.png)',
})
local markdown = require('lib.image.markdown')
equal(markdown.at_cursor(markdown_buf, 1, 8).target, 'img/a.png', 'inline image destination')
equal(markdown.at_cursor(markdown_buf, 1, 35).target, 'other/b.webp', 'HTML image src')
equal(markdown.at_cursor(markdown_buf, 4, 3).target, 'refs/c.svg', 'reference image destination')
equal(markdown.at_cursor(markdown_buf, 5, 3).target, 'images/a b.png', 'angle-bracket destination')
equal(markdown.at_cursor(markdown_buf, 1, 1), nil, 'non-image Markdown text must remain unhandled')
local old_notify = vim.notify
vim.notify = function() end
local unsupported = image.preview_at_cursor({ bufnr = markdown_buf, row = 6, column = 3 })
vim.notify = old_notify
truthy(unsupported.handled, 'an image node must stay handled even when its URI scheme is unsupported')

-- The public capability check is conservative for auto preview and permissive
-- for an explicit PreviewImage request.
truthy(image.can_preview('example.png', { explicit = false }), 'PNG should auto-preview')
equal(image.can_preview('example.docx', { explicit = false }), false, 'Office files should not auto-preview')
truthy(image.can_preview('example.docx', { explicit = true }), 'explicit previews should reach mcat/fallbacks')
equal(image.can_preview('s3://bucket/example.png', { explicit = true }), false, 'S3 is intentionally unregistered')

-- Command parsing follows fzf.vim: the trailing ? is the command's first arg.
require('config.lib_image').setup()
local original_preview = image.preview
local command_calls = {}
image.preview = function(source, opts)
  table.insert(command_calls, { source = source, kind = opts.target.kind })
  return { handled = true }
end
vim.cmd('PreviewImage? virtual.png')
vim.cmd('PreviewImage! virtual.png')
vim.cmd('PreviewImageWindow virtual.png')
equal(command_calls, {
  { source = 'virtual.png', kind = 'preview' },
  { source = 'virtual.png', kind = 'tab' },
  { source = 'virtual.png', kind = 'preview' },
}, 'PreviewImage command layout parsing')
image.preview = original_preview

-- Owned splits and tabs reuse the blank buffer created by :new/:tabnew. They
-- must not leave a listed [No Name] buffer after replacing or closing it.
local layout_manager = require('lib.image.layout')
local unnamed_before = listed_unnamed_buffers()
local preview_layout = layout_manager.open(
  { kind = 'preview' },
  { name = 'tiny.png' },
  { width = 1, height = 1 },
  10,
  20,
  image.get_config()
)
equal(vim.bo[preview_layout.bufnr].buftype, 'nofile', 'preview layout must reuse a nofile buffer')
equal(vim.bo[preview_layout.bufnr].buflisted, false, 'preview layout buffer must be unlisted')
equal(listed_unnamed_buffers(), unnamed_before, 'preview layout must not leak an unnamed buffer while open')
layout_manager.close(preview_layout)
equal(listed_unnamed_buffers(), unnamed_before, 'preview layout must not leak an unnamed buffer after close')

local tab_layout = layout_manager.open(
  { kind = 'tab' },
  { name = 'tiny.png' },
  { width = 1, height = 1 },
  10,
  20,
  image.get_config()
)
equal(vim.bo[tab_layout.bufnr].buftype, 'nofile', 'tab layout must reuse a nofile buffer')
equal(vim.bo[tab_layout.bufnr].buflisted, false, 'tab layout buffer must be unlisted')
equal(listed_unnamed_buffers(), unnamed_before, 'tab layout must not leak an unnamed buffer while open')
layout_manager.close(tab_layout)
equal(listed_unnamed_buffers(), unnamed_before, 'tab layout must not leak an unnamed buffer after close')

-- Exercise the asynchronous session without emitting terminal escape data.
local draw_count = 0
image.register_backend('test', {
  name = 'test',
  available = function()
    return true
  end,
  encode = function(_, _, _, _, _, callback)
    vim.schedule(function()
      callback('encoded')
    end)
  end,
  draw = function()
    draw_count = draw_count + 1
    return true
  end,
  clear = function() end,
})
image.config({ backend = 'test' })
local result = image.preview({ data = tiny_png, mime = 'image/png', name = 'tiny.png' }, {
  bufnr = markdown_buf,
  target = { kind = 'window', winid = vim.api.nvim_get_current_win(), bufnr = markdown_buf },
})
truthy(result.handled, 'in-memory image source should be claimed')
wait_for(function()
  return image.status().phase == 'ready'
end, 'in-memory preview did not become ready')
equal(image.status().backend, 'test', 'custom backend selection')
truthy(draw_count > 0, 'ready session must draw its encoded image')
image.close()

-- BufReadCmd avoids loading binary bytes and honors runtime disabling.
local png_path = process.tempname('.PnG')
truthy(process.write_file(png_path, tiny_png), 'create temporary PNG fixture')
vim.cmd.edit({ args = { png_path }, bang = true })
wait_for(function()
  return image.status().phase == 'ready'
end, 'automatic PNG preview did not become ready')
equal(vim.bo.filetype, 'lib_image', 'automatic image buffer filetype')
equal(vim.bo.buftype, 'nofile', 'automatic image buffer should not contain binary file data')
equal(vim.b.lib_image_source, png_path, 'automatic image source marker')
local auto_buf = vim.api.nvim_get_current_buf()
image.preview(png_path, { bufnr = auto_buf, target = { kind = 'float' } })
wait_for(function()
  return image.status().phase == 'ready'
end, 'float requested from an automatic image buffer did not become ready')
truthy(image.status().bufnr ~= auto_buf, 'entering the owned float must not cancel its source request')
image.close()
vim.cmd.bdelete({ bang = true })
process.unlink(png_path)

local svg_path = process.tempname('.svg')
truthy(process.write_file(svg_path, '<svg xmlns="http://www.w3.org/2000/svg"></svg>\n'), 'create temporary SVG fixture')
vim.g.lib_image_config = { auto_preview = { enabled = false } }
vim.cmd.edit({ args = { svg_path }, bang = true })
equal(vim.bo.buftype, '', 'disabled auto-preview must perform a normal file read')
equal(vim.bo.binary, false, 'disabled auto-preview must retain normal text-buffer options')
equal(vim.bo.filetype, 'svg', 'disabled auto-preview must still run normal filetype detection')
equal(vim.api.nvim_buf_get_lines(0, 0, 1, false)[1], '<svg xmlns="http://www.w3.org/2000/svg"></svg>')
vim.g.lib_image_config = nil
vim.cmd.bdelete({ bang = true })
process.unlink(svg_path)

-- The Oil hook discovers a preview split created after disable_preview runs.
local oil_buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_win_set_buf(0, oil_buf)
vim.bo[oil_buf].filetype = 'oil'
local source_win = vim.api.nvim_get_current_win()
local oil_path = process.tempname('.png')
truthy(process.write_file(oil_path, tiny_png), 'create Oil fixture')
truthy(require('config.lib_image').oil_disable_preview(oil_path), 'Oil image should disable its text preview')
vim.cmd.new()
local preview_win = vim.api.nvim_get_current_win()
vim.wo[preview_win].previewwindow = true
vim.api.nvim_set_current_win(source_win)
wait_for(function()
  return image.status().phase == 'ready'
end, 'Oil preview did not become ready')
equal(image.status().winid, preview_win, 'Oil adapter must target the preview window, not the source window')
image.close()
if vim.api.nvim_win_is_valid(preview_win) then
  vim.api.nvim_win_close(preview_win, true)
end
process.unlink(oil_path)

-- LSP K is special only for Markdown and disappears after the final detach.
vim.bo[oil_buf].filetype = 'markdown'
local fake_client = {
  id = 999999,
  name = 'lib-image-test',
  supports_method = function()
    return false
  end,
}
require('lsp-servers.keymaps').set_lsp_keys(fake_client, oil_buf)
equal(vim.fn.maparg('K', 'n', false, true).desc, '[Lsp]: Preview Markdown image / hover')
vim.api.nvim_exec_autocmds('LspDetach', { buffer = oil_buf, data = { client_id = fake_client.id } })
wait_for(function()
  return vim.fn.maparg('K', 'n') == ''
end, 'native K was not restored after LSP detach')

image.close()
image.restore()
vim.g.lib_image_config = nil
vim.b.lib_image_config = nil
print(('lib.image: %d assertions passed'):format(assertions))
vim.cmd('qa!')
