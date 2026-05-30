local Kind = require("blink.cmp.types").CompletionItemKind

local source = {}

function source.new()
  local self = setmetatable({}, { __index = source })
  self.blog_path = vim.fn.expand("~/dwain.maralack.com/src/content/blog/")
  self._items = nil
  return self
end

function source:enabled()
  return vim.bo.filetype == "markdown"
end

function source:get_completions(context, callback)
  if not self:_inside_brackets(context) then
    callback({ items = {} })
    return
  end
  if not self._items then
    self._items = self:_load_posts()
  end
  callback({
    items = self._items,
    is_incomplete_forward = false,
    is_incomplete_backward = false,
  })
end

function source:_inside_brackets(context)
  local before_cursor = context.line:sub(1, context.cursor[2])
  local opens = select(2, before_cursor:gsub("%[", ""))
  local closes = select(2, before_cursor:gsub("%]", ""))
  return opens > closes
end

function source:_read_title(filepath)
  local lines = vim.fn.readfile(filepath, "", 10)
  for _, line in ipairs(lines) do
    local title = line:match('^title:%s*"([^"]+)"%s*$')
      or line:match("^title:%s*'([^']+)'%s*$")
      or line:match("^title:%s*(.+)$")
    if title then
      return title
    end
  end
  return nil
end

function source:_load_posts()
  local items = {}
  local files = vim.fn.glob(self.blog_path .. "*.md", false, true)
  if #files == 0 then
    return items
  end

  for _, filepath in ipairs(files) do
    local slug = vim.fn.fnamemodify(filepath, ":t:r")
    local title = self:_read_title(filepath) or slug
    table.insert(items, {
      label = title,
      filterText = title:lower(),
      insertText = string.format("[%s](/%s/)", title, slug),
      kind = Kind.Reference,
      detail = slug,
    })
  end

  table.sort(items, function(a, b)
    return a.label:lower() < b.label:lower()
  end)

  return items
end

return source
