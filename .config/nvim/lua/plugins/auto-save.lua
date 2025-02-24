return {
    'okuuva/auto-save.nvim',
    version = '^1.0.0',
    cmd = "ASToggle",
    event = { "InsertLeave", "TextChanged" },
    keys = {
        { "<leader>ts", ":ASToggle<CR>", desc = "Toggle auto-save" },
        { "<leader>fs", ":ASWrite<CR>", desc = "Force save buffer" },
        { "<leader>bs", ":ASToggleBuffer<CR>", desc = "Toggle auto-save for buffer" },
    },
    opts = {
        enabled = true,
        -- Add basic conditions for when to save
        condition = function(buf)
            if not vim.bo[buf].modifiable or vim.bo[buf].readonly then
                return false
            end
            return true
        end,
        events = { "InsertLeave", "TextChanged" },
        debounce_delay = 1000,
    },
	config = function ()
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("lsp", { clear = true }),
			callback = function(args)
				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = args.buf,
					callback = function()
						vim.lsp.buf.format { async = false, id = args.data.client_id }
					end,
				})
			end
		})
	end

}
