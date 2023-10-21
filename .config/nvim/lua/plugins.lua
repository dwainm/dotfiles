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

	use 'ludovicchabant/vim-gutentags'

	use 'nvim-treesitter/nvim-treesitter'

	use 'nvim-lua/plenary.nvim'

	use 'theprimeagen/harpoon'

	use 'mbbill/undotree'

	use 'tpope/vim-fugitive'

	use 'tpope/vim-commentary'

	use 'tpope/vim-surround'

	use 'tpope/vim-repeat'

	use 'tpope/vim-rhubarb'

	use 'christoomey/vim-tmux-navigator'

	use 'jgdavey/tslime.vim'

	use	'vimwiki/vimwiki'

	use {
		'ptzz/lf.vim',
		requires = {
			{'voldikss/vim-floaterm'},
		}
	}

	use {
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v1.x',
		requires = {
			-- LSP Support
			{'neovim/nvim-lspconfig'},				-- Required
			{'williamboman/mason.nvim'},			-- Optional
			{'williamboman/mason-lspconfig.nvim'},	-- Optional

			-- Autocompletion
			{'hrsh7th/nvim-cmp'},       -- Required
			{'hrsh7th/cmp-nvim-lsp'},   -- Required

			-- Snippets
			{
				'L3MON4D3/LuaSnip',     -- Requiredb?
			}
		}
	}

	use { 'saadparwaiz1/cmp_luasnip' }

	use { 'jose-elias-alvarez/null-ls.nvim'}

	use({
		'Wansmer/treesj',
		requires = { 'nvim-treesitter' },
		config = function() 
			vim.keymap.set('n', '<leader>m', require('treesj').toggle)
			require('treesj').setup({
			-- (<space>m - toggle, <space>j - join, <space>s - split)
			use_default_keymaps = true,

			-- Node with syntax error will not be formatted
			check_syntax_error = true,

			-- If line after join will be longer than max value,
			-- node will not be formatted
			max_join_length = 120,

			-- hold|start|end:
			-- hold - cursor follows the node/place on which it was called
			-- start - cursor jumps to the first symbol of the node being formatted
			-- end - cursor jumps to the last symbol of the node being formatted
			cursor_behavior = 'hold',

			-- Notify about possible problems or not
			notify = true,
			langs = langs,

			-- Use `dot` for repeat action
			dot_repeat = true,
		}) end,

	})
end)
