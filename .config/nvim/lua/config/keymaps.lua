-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Yank entire line from beginning
vim.keymap.set("n", "Y", "0yy", { desc = "Yank entire line" })

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
-- LazyGit on <leader>g
vim.keymap.set("n", "<leader>g", "<cmd>LazyGit<cr>", { desc = "LazyGit" })

-- Other git commands on <leader>G
local gs = require("gitsigns") -- Cache for efficiency
vim.keymap.set("n", "<leader>Gb", function()
  gs.blame_line({ full = true })
end, { desc = "Blame Line" })
vim.keymap.set("n", "<leader>Gd", gs.preview_hunk, { desc = "Diff Hunk" })
vim.keymap.set({ "n", "v" }, "<leader>Gs", gs.stage_hunk, { desc = "Stage Hunk" })
vim.keymap.set("n", "<leader>GS", gs.stage_buffer, { desc = "Stage Buffer" })
vim.keymap.set({ "n", "v" }, "<leader>Gr", gs.reset_hunk, { desc = "Reset Hunk" })
