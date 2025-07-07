return {
	{
		"williamboman/mason.nvim",
		lazy = false,
		build = ":MasonUpdate",
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗"
					}
				}
			})
		end
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		dependencies = {
			"williamboman/mason.nvim"
		},
		config = function()
			require("mason-lspconfig").setup({
				auto_install = true,
				ensure_installed = {
					"lua_ls",
					"ts_ls",
					"html",
					"ruby_lsp",
					"rubocop",
					"phpactor",
					"tailwindcss"
				}
			})
		end
	},
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local capabilities = require('cmp_nvim_lsp').default_capabilities()

			local lspconfig = require("lspconfig")

			lspconfig.tailwindcss.setup({
				capabilities = capabilities
			})

			lspconfig.ts_ls.setup({
				capabilities = capabilities
			})

			lspconfig.solargraph.setup({
				capabilities = capabilities
			})

			lspconfig.html.setup({
				capabilities = capabilities
			})

			lspconfig.lua_ls.setup({
				capabilities = capabilities
			})

			lspconfig.phpactor.setup({
				on_attach = on_attach,
				capabilities = capabilities,
				init_options = {
					["language_server_phpstan.enabled"] = false,
					["language_server_psalm.enabled"] = false,
					["indexer.include_patterns"] = {
						"~/www/wordpress" -- Add your WordPress directory here
					},
				}
			})

			lspconfig.cssmodules_ls.setup({
				capabilities = capabilities
			})

			-- Block migration-related modal popups only
			vim.lsp.handlers["window/showMessageRequest"] = function(err, result, ctx, config)
				if result and result.message and result.message:match("Migrations are pending") then
					-- For migration prompts, always return "Cancel" action
					if result.actions then
						for _, action in ipairs(result.actions) do
							if action.title and action.title:match("Cancel") then
								return action
							end
						end
						-- If no Cancel found, return the last action (usually Cancel)
						return result.actions[#result.actions]
					end
					return { title = "Cancel" }
				end
				-- Pass through other message requests normally
				return vim.lsp.handlers["window/showMessageRequest"](err, result, ctx, config)
			end

			lspconfig.ruby_lsp.setup({
				capabilities = capabilities,
				filetypes = { "ruby" },
				root_dir = require('lspconfig.util').root_pattern("Gemfile", ".git"),
				on_attach = function(client, bufnr)
					-- Disable command execution to prevent auto-running migrations
					client.server_capabilities.executeCommandProvider = false
				end
			})


			-- LSP Keymaps
			vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
			vim.keymap.set("n", "<leader>td", vim.lsp.buf.definition, {})
			-- Telescope references is: "<leader>tr". It bring up refenrences in a betterway
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {})
			vim.keymap.set("n", "<leader>fo", vim.lsp.buf.format, {})
		end,
	},
}
