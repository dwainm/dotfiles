return {
  "rcarriga/nvim-dap-ui",
  dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
  keys = {
    { "<leader>du", function() require("dapui").toggle() end, desc = "DAP UI toggle" },
    {
      "<leader>de",
      function() require("dapui").eval(nil, { enter = true }) end,
      mode = { "n", "v" },
      desc = "DAP Eval/Add to Watches",
    },
    {
      "Q",
      function() require("dapui").eval() end,
      mode = { "n", "v" },
      desc = "DAP Peek",
    },
    {
      "<leader>dn",
      function()
        require("neotest").run.run({ strategy = "dap" })
      end,
      desc = "Debug nearest test",
    },
  },
  config = function()
    local dapui = require("dapui")
    local dap = require("dap")

    -- More minimal UI setup
    dapui.setup({
      expand_lines = true,
      controls = { enabled = false }, -- no extra play/step buttons
      floating = { border = "rounded" },
      render = {
        max_type_length = 60,
        max_value_lines = 200,
      },
      -- Only one layout: just the "scopes" (variables) list at the bottom
      layouts = {
        {
          elements = {
            { id = "scopes", size = 1.0 }, -- 100% of this panel is scopes
          },
          size = 15,
          position = "bottom",
        },
      },
    })

    -- Open the UI as soon as we are debugging
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end

    -- Custom breakpoint signs
    vim.fn.sign_define("DapBreakpoint", {
      text = "⚪",
      texthl = "DapBreakpointSymbol",
      linehl = "DapBreakpoint",
      numhl = "DapBreakpoint",
    })

    vim.fn.sign_define("DapStopped", {
      text = "🔴",
      texthl = "yellow",
      linehl = "DapBreakpoint",
      numhl = "DapBreakpoint",
    })

    vim.fn.sign_define("DapBreakpointRejected", {
      text = "⭕",
      texthl = "DapStoppedSymbol",
      linehl = "DapBreakpoint",
      numhl = "DapBreakpoint",
    })
  end,
}
