vim.g.mapleader = " "

vim.api.nvim_set_keymap('', '<Space>', '<Nop>', { noremap = true, silent = true })

local nnoremap  = function(lhs, rhs, opt )
	if ( type(opt) ~= 'table') then
		opt = {}
	end
	opt['noremap'] = true
	opt['silent'] = true
	vim.api.nvim_set_keymap('n', lhs, rhs, opt)
end

local vnoremap  = function(lhs, rhs, opt)
	if ( type(opt) ~= 'table') then
		opt = {}
	end
	opt['noremap'] = true
	opt['silent'] = true
	vim.api.nvim_set_keymap('v', lhs, rhs, opt)
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

-- Quick Fix navitation
nnoremap("]q",":cnext<cr>")
nnoremap("[q",":cprev<cr>")

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
nnoremap("<leader>ff","<cmd>Telescope find_files theme=dropdown<cr>")
nnoremap("<leader>fG",":Telescope grep_string theme=dropdown<cr>")
vnoremap("<leader>fG","zy<cmd>exec 'Telescope grep_string default_text=' . escape(@z, ' ')<cr>")
nnoremap("<leader>fg","<cmd>Telescope live_grep theme=dropdown<cr>")
nnoremap("<leader>fb","<cmd>Telescope buffers theme=dropdown<cr>")
nnoremap("<leader>fh","<cmd>Telescope help_tags<cr>")
nnoremap("<leader>fr","<cmd>Telescope resume<cr>")

-- Oil 
nnoremap("-", ":Oil --float <CR>",  { desc = "Open parent directory" })

--Map Ctrl + S to save in any mode
nnoremap("<silent><C-s>",":update<CR>")
vnoremap("<silent><C-s>","<C-C>:update<CR>")
inoremap("<silent><C-s>","<C-O>:update<CR>")

--quit quickly | without saving
nnoremap("<leader>q",":q<CR>j", {nowait=true})
vnoremap("<leader>q",":q<CR>j", {nowait=true})
nnoremap("<leader>qa", "<ESC>:qa!<CR>")

--Easily edit files in the same directory
nnoremap("<leader>e",":e <C-R>=expand('%:p:h') . '/'<CR>")

--Open Explorer
nnoremap("<leader>n",":NvimTreeToggle<CR>")

--Clear line
nnoremap("<Leader>cl","0D")

--Keeup page up and page down in the middele of the page
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")

-- ALlow you to paste without overwriting the register
vim.keymap.set("x", "<leader>p", "\"_dP")

-- Lf file manager
vim.g.lf_map_keys = 0
nnoremap("<leader>fm",':Lf<CR>')

-- Paste from system clipboard
vim.keymap.set("x", "<leader>P", "\"+p")

-- Select recently pasted text
nnoremap("gp","`[v`]")

-- Allow you to yank to the system clipboard
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>yw", "viw\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("x", "<leader>Y", "\"+Y")

-- Just don't use this.
vim.keymap.set("n", "Q", "<nop>")

-- Relpace the current word
nnoremap("<leader>sr",[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Source VIMRC
nnoremap("<leader>so",[[:source $MYVIMRC <CR>:source ~/.config/nvim/lua/remap.lua<CR> :source ~/.config/nvim/lua/plugins.lua <CR> :echom "NVIMRC sourced"<CR>]])
