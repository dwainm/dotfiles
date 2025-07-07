require("set")
require("config.lazy")
require("remap")
require("snippets")
vim.cmd('colorscheme rose-pine')


---------------------
--- Custom Macros ---
---------------------
vim.api.nvim_create_autocmd("FileType",{
	pattern = {"markdown", "md"},
	callback= function()
		local esc = vim.api.nvim_replace_termcodes("<Esc>",true, true, true)
		vim.fn.setreg("l", "c[]()".. esc .."F[p".. esc .. "f(aurl".. esc )
	end,
})
