return {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    config = function()
        require("smart-splits").setup({
            at_edge = function(context)
                local dmap = {
                    left = "left",
                    down = "down",
                    up = "up",
                    right = "right",
                }

                if context.mux.current_pane_at_edge(context.direction) then
                    local direction = dmap[context.direction]
                    local command = "aerospace focus " .. direction
                    vim.fn.system(command)
                end
            end,
        })
    end,
    keys = {
        { "<c-h>", function() require("smart-splits").move_cursor_left() end, desc = "Move to left split" },
        { "<c-j>", function() require("smart-splits").move_cursor_down() end, desc = "Move to below split" },
        { "<c-k>", function() require("smart-splits").move_cursor_up() end, desc = "Move to above split" },
        { "<c-l>", function() require("smart-splits").move_cursor_right() end, desc = "Move to right split" },
    },
}
