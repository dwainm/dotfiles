return {
  'Wansmer/sibling-swap.nvim',
	dependencies = 'nvim-treesitter',
	config=function() require('sibling-swap').setup({--[[ your config ]]}) end,
}

