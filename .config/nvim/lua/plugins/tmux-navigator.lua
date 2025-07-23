return {
  'christoomey/vim-tmux-navigator',
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown", 
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = {
    { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
    { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
    { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
    { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
    { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
  },
  init = function()
    -- Configure vim-tmux-navigator to wrap to aerospace
    vim.g.tmux_navigator_no_wrap = 0
    vim.g.tmux_navigator_save_on_switch = 2
    
    -- Custom function to handle edge detection
    vim.g.tmux_navigator_no_mappings = 0
  end,
}