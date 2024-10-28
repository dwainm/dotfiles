return {
'mbbill/undotree', -- visually see the history with times, amazing if you have unlimitted undo
config=function()
	vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
end
}
