vim.g.mapleader = " "

local nnoremap  = function(lhs, rhs)
	vim.api.nvim_set_keymap('n', lhs, rhs, { noremap = true, silent = true })
end

local vnoremap  = function(lhs, rhs)
	vim.api.nvim_set_keymap('n', lhs, rhs, { noremap = true, silent = true })
end

local inoremap  = function(lhs, rhs)
	vim.api.nvim_set_keymap('i', lhs, rhs, { noremap = true, silent = true })
end

local imap  = function(lhs, rhs)
	vim.api.nvim_set_keymap('i', lhs, rhs,{})
end

local nmap  = function(lhs, rhs)
	vim.api.nvim_set_keymap('n', lhs, rhs,{})
end

local xmap  = function(lhs, rhs)
	vim.api.nvim_set_keymap('x', lhs, rhs,{})
end

local map  = function(lhs, rhs)
	vim.api.nvim_set_keymap('', lhs, rhs,{})
end


--Exit insert mode Normal Mode( [t]o [n]ormal )
imap("tn","<Esc>")

--Move up and down logical lines when text is wrapped
nnoremap("j", "gj")
nnoremap("k", "gk")

--Buffer navigation
nmap ("[b",":bprevious<CR>")
nmap ("]b",":bnext<CR>")

-- Yank
nnoremap("Y", "0Y")

--Quicker window movement <C-{j|k|l|H}>
nnoremap("<C-j>","<C-w>j")
nnoremap("<C-k>","<C-w>k")
nnoremap("<C-l>","<C-w>l")

-- Set cursor at the beginning of line when bringing lines up.
vim.keymap.set("n", "J", "mzJ`z")

--Move selection/current line up or donw [in all modes]
vim.keymap.set("v", "U", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")

nnoremap("<C-h>","<C-w>h")
-- Allignemnt
xmap("ga" , "<Plug>(EasyAlign)")
nmap("ga","<Plug>(EasyAlign)")

-- LSP errors
nnoremap("]r","<cmd>lua vim.diagnostic.goto_next()<CR>")
nnoremap("[r","<cmd>lua vim.diagnostic.goto_prev()<CR>")

-- Telescope
nnoremap("<leader>ff","<cmd>Telescope find_files<cr>")
nnoremap("<leader>fG",":Telescope grep_string<cr>")
nnoremap("<leader>fg","<cmd>Telescope live_grep<cr>")
nnoremap("<leader>fb","<cmd>Telescope buffers<cr>")
nnoremap("<leader>fh","<cmd>Telescope help_tags<cr>")

--Map Ctrl + S to save in any mode
nnoremap("<silent><C-s>",":update<CR>")
vnoremap("<silent><C-s>","<C-C>:update<CR>")
inoremap("<silent><C-s>","<C-O>:update<CR>")

--quit quickly | without saving
nnoremap("<leader>q",":q<CR>j")
nnoremap("<leader>qa", "<ESC>:qa!<CR>")

--Easily edit files in the same directory
nnoremap("<leader>e",":e <C-R>=expand('%:p:h') . '/'<CR>")

--Open Explorer
nnoremap("<leader>n",":NvimTreeToggle<CR>")

--Clear line
nnoremap("<Leader>dl","0D")

--Keeup page up and page down in the middele of the page
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")

-- ALlow you to paste without overwriting the register
vim.keymap.set("x", "<leader>p", "\"_dP")

-- Paste from system clipboard
vim.keymap.set("x", "<leader>P", "\"+p")

-- Allow you to yank to the system clipboard
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>yw", "viw\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("x", "<leader>Y", "\"+Y")

-- Just don't use this.
vim.keymap.set("n", "Q", "<nop>")

-- Relpace the current word.
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
