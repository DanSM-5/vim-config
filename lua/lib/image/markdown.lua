local M = {}

local reference_cache = {}

local function node_text(node, source)
  return vim.treesitter.get_node_text(node, source) or ''
end

local function find_named_child(node, wanted)
  for child in node:iter_children() do
    if child:named() and child:type() == wanted then
      return child
    end
  end
  return nil
end

local function find_containing(node, column)
  local start_row, start_col, end_row, end_col = node:range()
  local contains = start_row == 0 and end_row == 0 and column >= start_col and column < end_col
  if contains and (node:type() == 'image' or node:type() == 'html_tag') then
    return node
  end
  for child in node:iter_children() do
    local found = find_containing(child, column)
    if found then
      return found
    end
  end
  return nil
end

local function normalize_label(label)
  label = label:gsub('^%[', ''):gsub('%]$', '')
  return vim.trim(label):gsub('%s+', ' '):lower()
end

local function clean_destination(destination)
  destination = vim.trim(destination)
  if destination:sub(1, 1) == '<' and destination:sub(-1) == '>' then
    destination = destination:sub(2, -2)
  end
  return destination
end

local function collect_reference_nodes(node, source, result)
  if node:type() == 'link_reference_definition' then
    local label = find_named_child(node, 'link_label')
    local destination = find_named_child(node, 'link_destination')
    if label and destination then
      result[normalize_label(node_text(label, source))] = clean_destination(node_text(destination, source))
    end
    return
  end
  for child in node:iter_children() do
    if child:named() then
      collect_reference_nodes(child, source, result)
    end
  end
end

local function references(bufnr)
  local changedtick = vim.api.nvim_buf_get_changedtick(bufnr)
  local cached = reference_cache[bufnr]
  if cached and cached.changedtick == changedtick then
    return cached.values
  end
  if not cached then
    pcall(vim.api.nvim_buf_attach, bufnr, false, {
      on_detach = function()
        reference_cache[bufnr] = nil
      end,
    })
  end
  local source = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n') .. '\n'
  local values = {}
  local ok, parser = pcall(vim.treesitter.get_string_parser, source, 'markdown')
  if ok and parser then
    local trees = parser:parse()
    if trees[1] then
      collect_reference_nodes(trees[1]:root(), source, values)
    end
  end
  reference_cache[bufnr] = { changedtick = changedtick, values = values }
  return values
end

local function html_unescape(value)
  local entities = {
    amp = '&',
    apos = "'",
    gt = '>',
    lt = '<',
    quot = '"',
  }
  return (
    value:gsub('&(#?[%w]+);', function(entity)
      local named = entities[entity]
      if named then
        return named
      end
      local decimal = entity:match('^#(%d+)$')
      local hexadecimal = entity:match('^#[xX]([%da-fA-F]+)$')
      local codepoint = decimal and tonumber(decimal, 10) or hexadecimal and tonumber(hexadecimal, 16)
      if codepoint and codepoint > 0 and codepoint <= 0x10ffff then
        local ok, character = pcall(vim.fn.nr2char, codepoint)
        if ok then
          return character
        end
      end
      return '&' .. entity .. ';'
    end)
  )
end

local function walk_html(node, source, state)
  if node:type() == 'start_tag' then
    local tag_name = find_named_child(node, 'tag_name')
    if tag_name and node_text(tag_name, source):lower() == 'img' then
      state.is_image = true
      for child in node:iter_children() do
        if child:named() and child:type() == 'attribute' then
          local name = find_named_child(child, 'attribute_name')
          if name and node_text(name, source):lower() == 'src' then
            local value = find_named_child(child, 'quoted_attribute_value')
              or find_named_child(child, 'attribute_value')
            if value then
              local text = node_text(value, source):gsub('^(["\'])', ''):gsub('(["\'])$', '')
              state.src = html_unescape(text)
              return
            end
          end
        end
      end
    end
  end
  for child in node:iter_children() do
    if child:named() and not state.src then
      walk_html(child, source, state)
    end
  end
end

local function html_src(tag)
  local ok, parser = pcall(vim.treesitter.get_string_parser, tag, 'html')
  if ok and parser then
    local trees = parser:parse()
    if trees[1] then
      local state = {}
      walk_html(trees[1]:root(), tag, state)
      if state.is_image and state.src then
        return state.src
      end
    end
  end

  if not tag:lower():match('^<%s*img[%s/>]') then
    return nil
  end
  local value = tag:match('[sS][rR][cC]%s*=%s*"([^"]*)"')
    or tag:match("[sS][rR][cC]%s*=%s*'([^']*)'")
    or tag:match('[sS][rR][cC]%s*=%s*([^%s>]+)')
  return value and html_unescape(value) or nil
end

local function image_target(node, line, bufnr, config)
  local destination = find_named_child(node, 'link_destination')
  if destination then
    return clean_destination(node_text(destination, line)), 'markdown_image'
  end
  if not config.markdown.reference_links then
    return nil
  end
  local label = find_named_child(node, 'link_label')
  local description = find_named_child(node, 'image_description')
  local key = label and normalize_label(node_text(label, line)) or ''
  if key == '' and description then
    key = normalize_label(node_text(description, line))
  end
  return references(bufnr)[key], 'markdown_image'
end

---Resolve only a real Markdown image node under the cursor.
---@param bufnr? integer
---@param row? integer 1-indexed row
---@param column? integer 0-indexed byte column
---@param config? LibImageConfig
---@return LibImageResolvedCursor?
function M.at_cursor(bufnr, row, column, config)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  config = config or require('lib.image.config').get(bufnr)
  if not vim.tbl_contains(config.markdown.filetypes, vim.bo[bufnr].filetype) then
    return nil
  end
  if not row or column == nil then
    local cursor = vim.api.nvim_win_get_cursor(0)
    row, column = cursor[1], cursor[2]
  end
  local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ''
  local ok, parser = pcall(vim.treesitter.get_string_parser, line, 'markdown_inline')
  if not ok or not parser then
    return nil
  end
  local trees = parser:parse()
  if not trees[1] then
    return nil
  end
  local node = find_containing(trees[1]:root(), column)
  if not node then
    return nil
  end

  local target, kind
  if node:type() == 'image' then
    target, kind = image_target(node, line, bufnr, config)
  elseif config.markdown.html then
    target, kind = html_src(node_text(node, line)), 'html_image'
  end
  if not target or target == '' then
    return nil
  end
  local start_row, start_col, end_row, end_col = node:range()
  return {
    target = target,
    kind = kind,
    range = { row - 1 + start_row, start_col, row - 1 + end_row, end_col },
  }
end

---Return a generic path/URI token for explicit commands.
---@return LibImageResolvedCursor?
function M.generic_at_cursor()
  local target = vim.fn.expand('<cfile>')
  target = target:gsub('^[<([{"\']+', ''):gsub('[>)]},;"\']+$', '')
  if target == '' then
    return nil
  end
  return { target = target, kind = 'cursor_path' }
end

return M
