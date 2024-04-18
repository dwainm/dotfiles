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

	use({
	"Pocco81/auto-save.nvim",
	config = function()
		 require("auto-save").setup {
				enabled = true, -- start auto-save when the plugin is loaded (i.e. when your package manager loads it)
				execution_message = {
					message = function() -- message to print on save
						return ("AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"))
					end,
					dim = 0.18, -- dim the color of `message`
					cleaning_interval = 1250, -- (milliseconds) automatically clean MsgArea after displaying `message`. See :h MsgArea
				},
				trigger_events = {"InsertLeave", "TextChanged"}, -- vim events that trigger auto-save. See :h events
				-- function that determines whether to save the current buffer or not
				-- return true: if buffer is ok to be saved
				-- return false: if it's not ok to be saved
				condition = function(buf)
					local fn = vim.fn
					local utils = require("auto-save.utils.data")

					if
						fn.getbufvar(buf, "&modifiable") == 1 and
						utils.not_in(fn.getbufvar(buf, "&filetype"), {}) then
						return true -- met condition(s), can save
					end
					return false -- can't save
				end,
				write_all_buffers = false, -- write all buffers when the current one meets `condition`
				debounce_delay = 135, -- saves the file at most every `debounce_delay` milliseconds
				callbacks = { -- functions to be executed at different intervals
					enabling = nil, -- ran when enabling auto-save
					disabling = nil, -- ran when disabling auto-save
					before_asserting_save = nil, -- ran before checking `condition`
					before_saving = nil, -- ran before doing the actual save
					after_saving = nil -- ran after doing the actual save
				}
}
	end,
	})

	use {'akinsho/bufferline.nvim', tag = "*", requires = 'nvim-tree/nvim-web-devicons'}

	use {
		'pwntester/octo.nvim',
		requires = {
			'nvim-lua/plenary.nvim',
			'nvim-telescope/telescope.nvim',
			'nvim-tree/nvim-web-devicons',
		},
		config = function ()
			require"octo".setup()
		end
	}

end)
