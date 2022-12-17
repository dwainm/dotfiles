-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	 use 'wbthomason/packer.nvim'
	
	 use 'Chiel92/vim-autoformat'

	 use 'dkarter/bullets.vim'

	 use 'honza/vim-snippets'

	 use {
		 'nvim-telescope/telescope.nvim', tag = '0.1.0',
		 requires = { {'nvim-lua/plenary.nvim'} }
	 }

	 use 'junegunn/vim-easy-align'

	 use 'tpope/vim-commentary'

	 use 'tpope/vim-surround'

	 use 'vim-airline/vim-airline'

	 use 'vim-airline/vim-airline-themes'

	 use 'ludovicchabant/vim-gutentags'

	 use 'neovim/nvim-lspconfig'

	 use {
		 'glepnir/lspsaga.nvim', branch = 'main',
	 }

	 use 'nvim-treesitter/nvim-treesitter'
end)
