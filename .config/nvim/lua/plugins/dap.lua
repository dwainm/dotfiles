return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "suketa/nvim-dap-ruby",
    },
    keys = {
    { "<F5>", function() require("dap").continue() end, desc = "DAP: Continue/Start" },
    { "<F6>", function() require("dap").step_over() end, desc = "DAP: Step over" },
    { "<F7>", function() require("dap").step_into() end, desc = "DAP: Step into" },
    { "<F8>", function() require("dap").step_out() end, desc = "DAP: Step out" },
    { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "DAP: Toggle breakpoint" },
    { "<leader>dr", function() require("dap").repl.open() end, desc = "DAP: REPL open" },
    { "<leader>dl", function() require("dap").run_last() end, desc = "DAP: Run last" },
  },
  config = function()
    -- nvim-dap-ruby will automatically configure Ruby adapters and configurations
    require("dap-ruby").setup()
  end,
  },
}
