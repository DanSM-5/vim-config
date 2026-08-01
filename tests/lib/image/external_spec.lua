-- Optional integration smoke test for the real external converter/renderer.
-- It expects `mcat` and `chafa` in PATH.

local image = require('lib.image')
local converter = require('lib.image.converter')
local sixel = require('lib.image.backends.sixel')
local tiny_png =
  vim.base64.decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=')
local config = image.get_config()
local capabilities = image.capabilities()
local fixture_root = vim.env.LIB_IMAGE_TEST_FIXTURE_ROOT or vim.fn.getcwd()

assert(capabilities.executables.chafa, '`chafa` is required for the Sixel smoke test')
assert(capabilities.executables.mcat, '`mcat` is required for the conversion smoke test')

local encoded
local encode_error
sixel.encode(tiny_png, { width = 8, height = 4 }, 10, 20, config, function(output, err)
  encoded, encode_error = output, err
end)
assert(
  vim.wait(10000, function()
    return encoded ~= nil or encode_error ~= nil
  end, 10),
  'Sixel encoding timed out'
)
assert(encoded and #encoded > 0, encode_error or 'Sixel encoding returned no data')

local gif = vim.fs.joinpath(fixture_root, 'plugged', 'vim-smoothie', 'demo.gif')
if vim.uv.fs_stat(gif) then
  local converted
  local conversion_error
  converter.normalize({ path = gif, name = gif }, config, function(output, err)
    converted, conversion_error = output, err
  end)
  assert(
    vim.wait(30000, function()
      return converted ~= nil or conversion_error ~= nil
    end, 10),
    'mcat conversion timed out'
  )
  assert(converted and converted.width > 0 and converted.height > 0, conversion_error or 'mcat returned no image')
end

local readable = 'not-tested'
if vim.fn.has('win32') == 1 then
  local markdown = vim.fs.joinpath(fixture_root, 'README.md')
  local converted
  local conversion_error
  converter.normalize({ path = markdown, name = markdown }, config, function(output, err)
    converted, conversion_error = output, err
  end)
  assert(
    vim.wait(30000, function()
      return converted ~= nil or conversion_error ~= nil
    end, 10),
    'mcat readable-file conversion timed out'
  )
  assert(converted and converted.width > 0 and converted.height > 0, conversion_error or 'mcat returned no image')
  readable = 'ok'
end

local pdf_fallback = 'not-tested'
if vim.env.LIB_IMAGE_TEST_PDF then
  local fallback_config = vim.deepcopy(config)
  fallback_config.conversion.mcat = '__lib_image_missing_mcat__'
  local converted
  local conversion_error
  converter.normalize(
    { path = vim.env.LIB_IMAGE_TEST_PDF, name = vim.env.LIB_IMAGE_TEST_PDF },
    fallback_config,
    function(output, err)
      converted, conversion_error = output, err
    end
  )
  assert(
    vim.wait(30000, function()
      return converted ~= nil or conversion_error ~= nil
    end, 10),
    'Ghostscript PDF fallback timed out'
  )
  assert(
    converted and converted.width > 0 and converted.height > 0,
    conversion_error or 'Ghostscript returned no image'
  )
  pdf_fallback = 'ok'
end

print(
  ('lib.image external: Sixel=%d bytes, mcat=ok, readable=%s, pdf-fallback=%s'):format(#encoded, readable, pdf_fallback)
)
vim.cmd('qa!')
