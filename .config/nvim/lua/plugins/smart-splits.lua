return {
    "mrjones2014/smart-splits.nvim",
    lazy=false,
    config = function()
        require("smart-splits").setup({
            at_edge = function(context)
                local dmap = {
                    left = "west",
                    down = "south",
                    up = "north",
                    right = "east",
                }

                if context.mux.current_pane_at_edge(context.direction) then
                    local layout = vim.fn.system('yabai -m query --spaces --space | jq -r .type'):gsub("^%s*(.-)%s*$", "%1")
                    
                    if layout == "stack" and (context.direction == "up" or context.direction == "down") then
                        -- Changed the cycling command for consistency
                        local cycle_target = context.direction == "up" and "first" or "last"
                        local stack_command = "yabai -m window --focus stack." .. 
                            (context.direction == "up" and "next" or "prev") ..
                            " || yabai -m window --focus stack." .. cycle_target
                        vim.fn.system(stack_command)
                    else
                        local ydirection = dmap[context.direction]
                        local command = "yabai -m window --focus " .. ydirection
                        if ydirection == "west" or ydirection == "east" then
                            command = command .. " || yabai -m display --focus " .. ydirection
                        end
                        vim.fn.system(command)
                    end
                end
            end,
        })
    end,
}
