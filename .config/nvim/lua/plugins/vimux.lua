return {
  "preservim/vimux",
  keys = {
    { "<leader>rr", function() vim.fn.VimuxPromptCommand() end, desc = "Vimux: Run command" },
    { "<leader>rl", function() vim.fn.VimuxRunLastCommand() end, desc = "Vimux: Run last" },
    {
      "<leader>rp",
      function()
        -- Open runner pane if it doesn't exist
        if not vim.g.VimuxRunnerIndex then
          vim.fn.VimuxOpenRunner()
        end
        -- Toggle zoom on current pane (editor)
        vim.fn.system("tmux resize-pane -Z")
      end,
      desc = "Vimux: Toggle zoom current pane",
    },
    { "<leader>rz", function() vim.fn.VimuxZoomRunner() end, desc = "Vimux: Zoom runner pane" },
    { "<leader>ri", function() vim.fn.VimuxInspectRunner() end, desc = "Vimux: Inspect/enter pane" },
    { "<leader>rx", function() vim.fn.VimuxInterruptRunner() end, desc = "Vimux: Interrupt (Ctrl-C)" },
    { "<leader>rk", function() vim.fn.VimuxClearTerminalScreen() end, desc = "Vimux: Clear screen" },
  },
}
