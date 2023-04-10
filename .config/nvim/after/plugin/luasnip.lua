require("luasnip.loaders.from_vscode").lazy_load({paths = "~/snippets/vscode"})

ls = require("luasnip")
-- load snippets from config path
-- press <Tab> to expand or jump in a snippet. These can also be mapped separately
vim.keymap.set({ "i", "s" }, "<c-k>", function()
	if ls.expand_or_jumpable() then
		ls.expand_or_jump()
	end
end, { silent = true })

-- -1 for jumping backwards.
vim.keymap.set({ "i", "s" }, "<c-j>", function()
  if ls.jumpable(-1) then
    ls.jump(-1)
  end
end, { silent = true })
--
-- vim.keymap.set("x", "<leader>Y", "\"+Y")
-- -1 for jumping backwards.
-- inoremap <silent> <S-Tab> <cmd>lua require'luasnip'.jump(-1)<Cr>

-- snoremap <silent> <Tab> <cmd>lua require('luasnip').jump(1)<Cr>
-- snoremap <silent> <S-Tab> <cmd>lua require('luasnip').jump(-1)<Cr>

-- " For changing choices in choiceNodes (not strictly necessary for a basic setup).
-- imap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
-- smap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
