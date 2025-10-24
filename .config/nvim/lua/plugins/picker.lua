return {
  {
    "ibhagwan/fzf-lua",
    keys = {
      -- Remove default sg/sG mappings
      { "<leader>sg", false },
      { "<leader>sG", false },

      -- Submenu for grep with options
      { "<leader>sgg", LazyVim.pick("live_grep", { root = false }), desc = "Grep (CWD)" },
      {
        "<leader>sgr",
        function()
          require("fzf-lua").live_grep({
            cwd = vim.fn.getcwd(),
            rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --type ruby -e"
          })
        end,
        desc = "Grep Ruby Files"
      },
      {
        "<leader>sgj",
        function()
          require("fzf-lua").live_grep({
            cwd = vim.fn.getcwd(),
            rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --type js -e"
          })
        end,
        desc = "Grep JavaScript Files"
      },
      {
        "<leader>sgc",
        function()
          require("fzf-lua").live_grep({
            cwd = vim.fn.getcwd(),
            rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --type css -e"
          })
        end,
        desc = "Grep CSS Files"
      },
      { "<leader>sgR", LazyVim.pick("live_grep"), desc = "Grep (Root Dir)" },
    },
  },
}
