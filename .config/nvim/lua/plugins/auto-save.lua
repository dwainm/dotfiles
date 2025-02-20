return {
	'okuuva/auto-save.nvim',
	version = '^1.0.0', -- see https://devhints.io/semver, alternatively use '*' to use the latest tagged release
	cmd = "ASToggle", -- optional for lazy loading on command
	event = { "InsertLeave", "TextChanged" }, -- optional for lazy loading on trigger events
	config = function()
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("lsp", { clear = true }),
			callback = function(args)
				-- 2
				vim.api.nvim_create_autocmd("BufWritePre", {
					-- 3
					buffer = args.buf,
					callback = function()
						-- 4 + 5
						vim.lsp.buf.format {async = false, id = args.data.client_id }
					end,
				})
			end
		})
	end
	opts = {
	-- your config goes here
	-- or just leave it empty :)
	},
}

