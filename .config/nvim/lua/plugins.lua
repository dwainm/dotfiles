-- Only required if you have packer configured as `opt`
vim.cmd.packadd('packer.nvim')

return require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'

	use 'rose-pine/neovim'
	use {
		'nvim-telescope/telescope.nvim', tag = '0.1.0',
		requires = { {'nvim-lua/plenary.nvim'} }
	}

	use 'junegunn/vim-easy-align'

	use 'tpope/vim-commentary'

	use 'tpope/vim-surround'

	use 'ludovicchabant/vim-gutentags'

	use 'nvim-treesitter/nvim-treesitter'

	use 'nvim-lua/plenary.nvim'

	use 'theprimeagen/harpoon'

	use 'mbbill/undotree'

	use 'tpope/vim-fugitive'

	use {
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v1.x',
		requires = {
			-- LSP Support
			{'neovim/nvim-lspconfig'},             -- Required

			-- Autocompletion
			{'hrsh7th/nvim-cmp'},         -- Required
			{'hrsh7th/cmp-nvim-lsp'},     -- Required

			-- Snippets
			{
				'L3MON4D3/LuaSnip',             -- Required
				run = "make install_jsregexp"
			}
		}
	}
end)