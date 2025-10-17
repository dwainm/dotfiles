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

-----------
-- Git
-----------
-- Remove uneeded keys
local maps = { "gb", "gB", "gd", "gf", "gl", "gL", "gs", "gS", "gY" }
for _, m in ipairs(maps) do
  vim.keymap.del("n", "<leader>" .. m)
end

-- Replace with gitsigns (buffer-local, no picker)
local gs = require("gitsigns") -- Cache for efficiency
vim.keymap.set("n", "<leader>gb", function()
  gs.blame_line({ full = true })
end, { desc = "Git Blame Line" }) -- blame current line
vim.keymap.set("n", "<leader>gd", gs.preview_hunk, { desc = "Git Diff Hunk" }) -- preview hunk diff
vim.keymap.set({ "n", "v" }, "<leader>gs", gs.stage_hunk, { desc = "Git Stage Hunk" }) -- stage hunk
vim.keymap.set("n", "<leader>gS", gs.stage_buffer, { desc = "Git Stage Buffer" }) -- stage buffer
vim.keymap.set({ "n", "v" }, "<leader>gr", gs.reset_hunk, { desc = "Git Reset Hunk" }) -- reset hunk
