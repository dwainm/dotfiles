return {
	'tpope/vim-fugitive', -- :G command  for working with .git from the editor
    config=function()
		vim.keymap.set("n", "<leader>gg", vim.cmd.Git)
	end
}
