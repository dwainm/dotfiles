-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Safari reload
vim.keymap.set("n", "<leader><F5>", function()
  local script = [[
    tell application "Safari"
      set theURL to URL of current tab of window 1
      set URL of current tab of window 1 to theURL
    end tell
  ]]
  local result = vim.fn.system("osascript -e " .. vim.fn.shellescape(script))
  if vim.v.shell_error == 0 then
    vim.notify("Safari reloaded", vim.log.levels.INFO)
  else
    vim.notify("Failed to reload Safari: " .. result, vim.log.levels.ERROR)
  end
end, { desc = "Reload Safari" })
