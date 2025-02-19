return {
	'echasnovski/mini.nvim', 
	version = '*',
	config = function()
		-- setup all mini plugins here
		require('mini.ai').setup()
		require('mini.pairs').setup()
	end,
}
