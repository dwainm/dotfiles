return {
	"mrjones2014/smart-splits.nvim",
	lazy=false,
	config = function()
				print('loading script')
		require("smart-splits").setup({
			at_edge = function(context)
				local dmap = {
					left = "west",
					down = "south",
					up = "north",
					right = "east",
				}
				
				if context.mux.current_pane_at_edge(context.direction) then
				-- print( 'is mux true')
					local ydirection = dmap[context.direction]
					local command = "yabai -m window --focus " .. ydirection

					if ydirection == "west" or ydirection == "east" then
						command = command .. " || yabai -m display --focus " .. ydirection
					end

					vim.fn.system(command)
				end
			end,
		})
	end,
}
