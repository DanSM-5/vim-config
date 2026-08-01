local png = require('lib.image.png')
local process = require('lib.image.process')
local source_util = require('lib.image.source')

local M = {}

local video_extensions = {
  apng = true,
  avi = true,
  gif = true,
  m4v = true,
  mkv = true,
  mov = true,
  mp4 = true,
  mpeg = true,
  mpg = true,
  webm = true,
  wmv = true,
}

local office_extensions = {
  doc = true,
  docx = true,
  odp = true,
  ods = true,
  odt = true,
  ppt = true,
  pptx = true,
  xls = true,
  xlsx = true,
}

local function result_error(name, result)
  local detail = vim.trim(result.stderr or '')
  if detail == '' then
    detail = ('exit code %d'):format(result.code or -1)
  end
  return name .. ' failed: ' .. detail
end

local function normalized(data, source)
  local width, height = png.dimensions(data)
  if not width or not height then
    return nil, 'Converter did not produce a valid PNG image'
  end
  return {
    data = data,
    width = width,
    height = height,
    name = source.name or source.path or source.uri or 'image',
  }
end

---@param source LibImageSource
---@param config LibImageConfig
---@param callback fun(image: table?, err: string?)
---@return { cancel: fun() }
function M.normalize(source, config, callback)
  local controller = { cancelled = false, current = nil, temporary_input = nil, temporary_dir = nil }

  local function cleanup()
    process.unlink(controller.temporary_input)
    controller.temporary_input = nil
    if controller.temporary_dir then
      local scan = vim.uv.fs_scandir(controller.temporary_dir)
      if scan then
        while true do
          local name = vim.uv.fs_scandir_next(scan)
          if not name then
            break
          end
          process.unlink(vim.fs.joinpath(controller.temporary_dir, name))
        end
      end
      pcall(vim.uv.fs_rmdir, controller.temporary_dir)
      controller.temporary_dir = nil
    end
  end

  local function finish(image, err)
    cleanup()
    if not controller.cancelled then
      callback(image, err)
    end
  end

  local function accept(data)
    local image, err = normalized(data, source)
    finish(image, err)
  end

  local function run(argv, opts, cb)
    controller.current = process.run(argv, opts, function(result)
      controller.current = nil
      if not controller.cancelled then
        cb(result)
      end
    end)
  end

  local function ghostscript(path, previous_error)
    if vim.fn.executable(config.conversion.ghostscript) ~= 1 then
      finish(nil, previous_error .. ('; `%s` was not found in PATH'):format(config.conversion.ghostscript))
      return
    end
    run({
      config.conversion.ghostscript,
      '-q',
      '-dSAFER',
      '-dBATCH',
      '-dNOPAUSE',
      '-dFirstPage=1',
      '-dLastPage=1',
      '-sDEVICE=pngalpha',
      '-r144',
      '-sOutputFile=-',
      path,
    }, { text = false, timeout = config.conversion.timeout }, function(result)
      if result.code ~= 0 or not result.stdout or not png.is_png(result.stdout) then
        finish(nil, previous_error .. '; ' .. result_error('Ghostscript', result))
      else
        accept(result.stdout)
      end
    end)
  end

  local function libreoffice(path, previous_error)
    if vim.fn.executable(config.conversion.libreoffice) ~= 1 then
      finish(nil, previous_error .. ('; `%s` was not found in PATH'):format(config.conversion.libreoffice))
      return
    end
    local directory = process.tempname('-lib-image')
    local ok, mkdir_err = vim.uv.fs_mkdir(directory, 448)
    if not ok then
      finish(nil, previous_error .. '; unable to create conversion directory: ' .. tostring(mkdir_err))
      return
    end
    controller.temporary_dir = directory
    run({
      config.conversion.libreoffice,
      '--headless',
      '--convert-to',
      'pdf',
      '--outdir',
      directory,
      path,
    }, { text = false, timeout = config.conversion.timeout }, function(result)
      local pdf_path = vim.fs.joinpath(directory, vim.fn.fnamemodify(path, ':t:r') .. '.pdf')
      if result.code ~= 0 or not vim.uv.fs_stat(pdf_path) then
        finish(nil, previous_error .. '; ' .. result_error('LibreOffice', result))
        return
      end
      ghostscript(pdf_path, previous_error)
    end)
  end

  local function fallback(path, mcat_error)
    local ext = source_util.extension(source.name or path) or source_util.extension(path)
    if video_extensions[ext] then
      if vim.fn.executable(config.conversion.ffmpeg) ~= 1 then
        finish(nil, mcat_error .. ('; `%s` was not found in PATH'):format(config.conversion.ffmpeg))
        return
      end
      local function ffmpeg(seek)
        local argv = { config.conversion.ffmpeg, '-v', 'error' }
        if seek > 0 then
          vim.list_extend(argv, { '-ss', tostring(seek) })
        end
        vim.list_extend(argv, {
          '-i',
          path,
          '-frames:v',
          '1',
          '-f',
          'image2pipe',
          '-vcodec',
          'png',
          '-',
        })
        run(argv, { text = false, timeout = config.conversion.timeout }, function(result)
          if result.code == 0 and result.stdout and png.is_png(result.stdout) then
            accept(result.stdout)
          elseif seek > 0 then
            -- A seek past the end of a very short clip exits successfully but
            -- produces no frame. Fall back to its first frame.
            ffmpeg(0)
          else
            finish(nil, mcat_error .. '; ' .. result_error('FFmpeg', result))
          end
        end)
      end
      ffmpeg(config.conversion.video_seek)
    elseif ext == 'pdf' then
      ghostscript(path, mcat_error)
    elseif office_extensions[ext] then
      libreoffice(path, mcat_error)
    else
      finish(nil, mcat_error)
    end
  end

  local function mcat(path)
    if vim.fn.executable(config.conversion.mcat) ~= 1 then
      fallback(path, ('`%s` was not found in PATH'):format(config.conversion.mcat))
      return
    end
    run({ config.conversion.mcat, '--silent', '--output', 'image', path }, {
      text = false,
      timeout = config.conversion.timeout,
    }, function(result)
      if result.code ~= 0 or not result.stdout or not png.is_png(result.stdout) then
        fallback(path, result_error('mcat', result))
      else
        accept(result.stdout)
      end
    end)
  end

  local function consume_path(path)
    local stat = vim.uv.fs_stat(path)
    if not stat or stat.type ~= 'file' then
      vim.schedule(function()
        finish(nil, 'Not a regular file: ' .. path)
      end)
      return
    end
    if stat.size > config.conversion.max_input_bytes then
      vim.schedule(function()
        finish(nil, ('Input exceeds configured limit (%d bytes): %s'):format(config.conversion.max_input_bytes, path))
      end)
      return
    end
    local ext = source_util.extension(source.name or path) or source_util.extension(path)
    if ext == 'png' then
      process.read_file(path, config.conversion.max_input_bytes, function(data, err)
        if err or not data then
          finish(nil, err)
        elseif png.is_png(data) then
          accept(data)
        else
          mcat(path)
        end
      end)
    else
      mcat(path)
    end
  end

  if source.data then
    if #source.data > config.conversion.max_input_bytes then
      vim.schedule(function()
        finish(nil, ('Input exceeds configured limit (%d bytes)'):format(config.conversion.max_input_bytes))
      end)
    elseif png.is_png(source.data) then
      vim.schedule(function()
        accept(source.data)
      end)
    else
      local suffix = source_util.extension(source.name or '')
      controller.temporary_input = process.tempname(suffix and ('.' .. suffix) or '')
      local ok, err = process.write_file(controller.temporary_input, source.data)
      if not ok then
        vim.schedule(function()
          finish(nil, 'Unable to stage image data: ' .. tostring(err))
        end)
      else
        consume_path(controller.temporary_input)
      end
    end
  elseif source.path then
    consume_path(source.path)
  else
    vim.schedule(function()
      finish(nil, 'Resolved image source has neither `path` nor `data`')
    end)
  end

  function controller.cancel()
    controller.cancelled = true
    if controller.current then
      pcall(controller.current.kill, controller.current, 15)
      controller.current = nil
    end
    cleanup()
  end

  return controller
end

return M
