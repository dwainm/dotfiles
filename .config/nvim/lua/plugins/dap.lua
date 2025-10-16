return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "suketa/nvim-dap-ruby",
      "preservim/vimux", -- Required for running commands in tmux pane during debug sessions
    },
    keys = {
    { "<F5>", function() require("dap").continue() end, desc = "DAP: Continue/Start" },
    { "<F6>", function() require("dap").step_over() end, desc = "DAP: Step over" },
    { "<F7>", function() require("dap").step_into() end, desc = "DAP: Step into" },
    { "<F8>", function() require("dap").step_out() end, desc = "DAP: Step out" },
    { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "DAP: Toggle breakpoint" },
    {
      "<leader>dr",
      function()
        require("dap").repl.toggle()
        -- Focus the REPL window after opening
        vim.defer_fn(function()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "dap-repl" then
              vim.api.nvim_set_current_win(win)
              break
            end
          end
        end, 50)
      end,
      desc = "DAP: REPL toggle",
    },
    { "<leader>dl", function() require("dap").run_last() end, desc = "DAP: Run last" },
  },
  config = function()
    -- nvim-dap-ruby will automatically configure Ruby adapters and configurations
    require("dap-ruby").setup()

    -- Add custom Rails server config that starts bin/dev in tmux
    local dap = require("dap")
    table.insert(dap.configurations.ruby, {
      type = "ruby",
      name = "Start bin/dev in tmux & attach debugger",
      request = "attach",
      localfs = true,
      port = 38698,
      preLaunchTask = function()
        -- Open Vimux pane if it doesn't exist
        if not vim.g.VimuxRunnerIndex then
          vim.fn.VimuxOpenRunner()
        end
        -- Send bin/dev to tmux pane
        vim.fn.VimuxRunCommand("bin/dev")
        vim.notify("Started bin/dev in tmux, waiting for debugger on port 38698...", vim.log.levels.INFO)
        -- Wait a bit for server to start
        vim.wait(2000)
      end,
    })
  end,
  },
}
