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
nnoremap("<C-h>","<C-w>h")
nnoremap("<C-l>","<C-w>l")

--Move selection/current line up or donw [in all modes]
nnoremap("[e", ":m .-2<CR>")
nnoremap("]e", ":m .+1<CR>")
vnoremap ("[e",":m '<-2<CR>gv")
vnoremap ("]e",":m '>+1<CR>gv")

--jump to errors
nnoremap("]r", ":ALENext<CR>k")
nnoremap("[r", ":ALEPrevious<CR>")
map("<leader>at", ":ALEToggle<CR>")

-- Allignemnt
xmap("ga" , "<Plug>(EasyAlign)")
nmap("ga","<Plug>(EasyAlign)")

-- Telescope
nnoremap("<leader>ff","<cmd>Telescope find_files<cr>")
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
nnoremap("<leader>n",":Explore<CR>")

--Clear line
nnoremap("<Leader>dl","0D")
