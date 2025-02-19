return {
	'akinsho/bufferline.nvim',
	version = "*",
	dependencies = 'nvim-tree/nvim-web-devicons',
	event = "BufReadPre",
	config=function() require("bufferline").setup{} end
}
