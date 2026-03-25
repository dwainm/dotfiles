-- Neovim keymap for frictionless blog post creation
-- Add this to your neovim config (e.g., ~/.config/nvim/lua/blog.lua)
-- Then require('blog') in your init.lua

local M = {}

local blog_path = vim.fn.expand('~/dwain.maralack.com/src/content/blog/')
local drafts_path = vim.fn.expand('~/dwain.maralack.com/src/content/drafts/')

-- Convert title to slug: lowercase, spaces to hyphens, strip punctuation
local function slugify(title)
  return title
    :lower()
    :gsub('%s+', '-')        -- spaces to hyphens
    :gsub('[^%w%-]', '')     -- remove non-alphanumeric (except hyphens)
    :gsub('%-+', '-')        -- collapse multiple hyphens
    :gsub('^%-', '')         -- trim leading hyphen
    :gsub('%-$', '')         -- trim trailing hyphen
end

-- Create a new blog post
function M.new_post()
  local title = vim.fn.input('Post title: ')
  if title == '' then
    print('Cancelled')
    return
  end

  local slug = slugify(title)
  local filepath = drafts_path .. slug .. '.md'

  -- Create drafts directory if it doesn't exist
  vim.fn.mkdir(drafts_path, 'p')

  -- Check if file exists
  if vim.fn.filereadable(filepath) == 1 then
    print('File already exists: ' .. filepath)
    return
  end

  -- Get today's date
  local date = os.date('%Y-%m-%d')

  -- Build frontmatter content
  local content = table.concat({
    '---',
    'title: "' .. title .. '"',
    'pubDate: ' .. date,
    'draft: true',
    'description: ""',
    'tags: []',
    '---',
    '',
    ''
  }, '\n')

  -- Write to file first
  local file = io.open(filepath, 'w')
  if file then
    file:write(content)
    file:close()
    print('Created: ' .. filepath)
  else
    print('Failed to create file: ' .. filepath)
    return
  end

  -- Now open the existing file
  vim.cmd('edit ' .. filepath)

  -- Move cursor to last line and enter insert mode
  vim.cmd('normal! G')
  vim.cmd('startinsert')
end

-- Fuzzy find drafts
function M.find_drafts()
  local fzf = require('fzf-lua')
  fzf.files({
    cwd = drafts_path,
    prompt = 'Drafts> ',
    previewer = 'builtin',
  })
end

-- Publish the current blog post (moves from drafts to blog)
function M.publish_post()
  local filepath = vim.fn.expand('%:p')
  local filename = vim.fn.expand('%:t')
  local blog_dir = vim.fn.expand('~/dwain.maralack.com')

  -- Check if file is in drafts folder
  local drafts_pattern = vim.fn.expand('~/dwain.maralack.com/src/content/drafts')
  local is_draft = filepath:find(drafts_pattern, 1, true) ~= nil

  if not is_draft then
    print('Not a draft - already published or not in drafts folder')
    return
  end

  local confirm = vim.fn.input('Publish "' .. filename .. '"? (y/n): ')
  if confirm ~= 'y' and confirm ~= 'Y' then
    print(' Cancelled')
    return
  end

  -- Save the current file first
  vim.cmd('write')

  -- Update frontmatter: pubDate to today and mark as not draft
  local today = os.date('%Y-%m-%d')
  vim.cmd('silent! %s/^pubDate:.*$/pubDate: ' .. today .. '/')
  vim.cmd('silent! %s/^draft:.*$/draft: false/')
  vim.cmd('write')

  -- Get title from frontmatter for commit message
  local lines = vim.api.nvim_buf_get_lines(0, 0, 10, false)
  local title = filename:gsub('%.md$', ''):gsub('-', ' ')
  for _, line in ipairs(lines) do
    local match = line:match('^title:%s*(.+)$')
    if match then
      title = match
      break
    end
  end

  -- Move file from drafts to blog
  local new_filepath = blog_path .. filename
  local move_cmd = string.format('mv %s %s', filepath, new_filepath)
  local move_result = os.execute(move_cmd)

  if move_result ~= 0 then
    print(' Failed to move file to blog folder')
    return
  end

  -- Switch buffer to new location
  vim.cmd('edit ' .. new_filepath)

  -- Git add, commit, and push
  local cmd = string.format(
    'cd %s && git add %s && git commit -m "Publish: %s" && git push',
    blog_dir,
    new_filepath,
    title:gsub('"', '\\"')
  )

  vim.fn.jobstart(cmd, {
    on_exit = function(_, code)
      if code == 0 then
        vim.schedule(function()
          print(' Published: ' .. title)
        end)
      else
        vim.schedule(function()
          print(' Publish failed (exit code ' .. code .. ')')
        end)
      end
    end,
  })
end

-- Set up the keymaps
function M.setup()
  -- Register which-key group
  local wk = require('which-key')
  wk.register({
    ['<leader>b'] = {
      name = 'blog',
      b = { name = 'blog menu' },
    },
  })

  -- Blog menu under <leader>bb
  vim.keymap.set('n', '<leader>bbn', M.new_post, { desc = 'New blog post' })
  vim.keymap.set('n', '<leader>bbd', M.find_drafts, { desc = 'Find drafts' })
  vim.keymap.set('n', '<leader>bbp', M.publish_post, { desc = 'Publish blog post' })
end

return M

-- Usage:
-- 1. Copy this file to ~/.config/nvim/lua/blog.lua
-- 2. In your init.lua, add:
--    require('blog').setup()
-- 3. Press <leader>bb to see blog menu, then n/d/p
