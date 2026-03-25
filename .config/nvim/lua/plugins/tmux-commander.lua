return {
  -- Local development version
  dir = vim.fn.expand("~/projects/tmux-commander.nvim"),
  name = "tmux-commander",
  dependencies = {
    "folke/snacks.nvim",
  },
  keys = {
    -- User-defined command keymaps
    {
      "<leader>td",
      function()
        require("tmux-commander").run_prompt("ssh-add -l >/dev/null || ssh-add && kamal deploy")
      end,
      desc = "Tmux: Deploy with Kamal",
    },
    {
      "<leader>tt",
      function()
        require("tmux-commander").run_prompt("bin/rails test")
      end,
      desc = "Tmux: Run Rails tests",
    },
    {
      "<leader>tC",
      function()
        require("tmux-commander").run_prompt("bin/rails console")
      end,
      desc = "Tmux: Rails console",
    },
    {
      "<leader>tc",
      function()
        require("tmux-commander").run_prompt()
      end,
      desc = "Tmux: Run custom command",
    },

    -- Built-in utilities
    {
      "<leader>ta",
      function()
        require("tmux-commander").adopt()
      end,
      desc = "Tmux: Adopt running command",
    },
    {
      "<leader>th",
      function()
        require("tmux-commander").show_history()
      end,
      desc = "Tmux: Command history",
    },
    {
      "<leader>tr",
      function()
        require("tmux-commander").repeat_last()
      end,
      desc = "Tmux: Repeat last command",
    },
    {
      "<leader>ti",
      function()
        require("tmux-commander").inspect()
      end,
      desc = "Tmux: Jump to runner window",
    },
    {
      "<leader>tk",
      function()
        require("tmux-commander").kill()
      end,
      desc = "Tmux: Kill running command",
    },
    {
      "<leader>tl",
      function()
        require("tmux-commander").list_windows()
      end,
      desc = "Tmux: List runner windows",
    },
  },
}
