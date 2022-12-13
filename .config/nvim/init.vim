""
" Leader
"
let mapleader=' '
"No one les should be able to use space.
nnoremap <SPACE> <nop>

"
" Vim-Plug
"
if empty(glob('~/.config/nvim/autoload/plug.vim'))
	silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	autocmd VimEnter * PlugInstall
endif

call plug#begin('~/.config/nvim/plugged')
Plug '907th/vim-auto-save', { 'for': 'vimwiki' }
Plug 'Chiel92/vim-autoformat'
Plug 'dkarter/bullets.vim'
Plug 'honza/vim-snippets'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }
Plug 'junegunn/vim-easy-align'
Plug 'kshenoy/vim-signature'
Plug 'mileszs/ack.vim'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vimwiki/vimwiki'
Plug 'w0rp/ale'
Plug 'fatih/vim-go'
Plug 'ludovicchabant/vim-gutentags'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'neovim/nvim-lspconfig'
Plug 'glepnir/lspsaga.nvim', { 'branch': 'main' }
call plug#end()

"
" Settings
"
set encoding=utf-8
set spell spelllang=en_us
set number
set ruler
set hidden
set showcmd "show character count
set background=dark
filetype plugin on "enabled filetype plugins and indent
filetype indent on
syntax enable
highlight Normal ctermbg=black
hi clear SpellBad
hi SpellBad cterm=undercurl

"Undo history between sessions
if v:version >= 703
	set undofile
	set undodir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
endif
set undofile
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
" If we backup temporary files often automated editing tools like the crontab editor get confused
set backupskip=/tmp/*,/private/tmp/*"
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
"column 100 and make it obvious where 100 characters is.
set colorcolumn=+1
hi ColorColumn ctermbg=lightgrey guibg=lightgrey
set cc=100
"Tabs, Spaces  and Indentation
set autoindent
set sts=0 sw=4 ts=4
set list
set listchars=tab:\ \ ,extends:›,precedes:‹,nbsp:·,trail:·
set tabstop=4  "four spaces will make up for one tab
set noexpandtab  "tell vim to keep tabs instead of inserting spaces
retab            "let vim handle your case
autocmd BufWinEnter,BufReadPre * setlocal conceallevel=2 concealcursor=nv
autocmd BufWinEnter,BufReadPre * syn match LeadingSpace /\(^ *\)\@<= / containedin=ALL conceal cchar=·

set backspace=indent,eol,start "insert mode backspacing over everything

augroup qf
    autocmd!
    autocmd FileType qf set nobuflisted
augroup END

"Split navigation
set splitbelow                                "open new horizontal splits below
set splitright                                "open new vertical splits rigth

"
" Mappings
"

"Exit insert mode Normal Mode( [t]o [n]ormal )
imap tn <Esc>

"Move up and down logical lines when text is wrapped
nnoremap j gj
nnoremap k gk

"Buffer navigation
nmap [b :bprevious<CR>
nmap ]b :bnext<CR>

" Yank

nnoremap Y oY
"Quicker window movement <C-{j|k|l|H}>
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

"Move selection/current line up or donw [in all modes]
nnoremap [e :m .-2<CR>
nnoremap ]e :m .+1<CR>
vnoremap [e :m '<-2<CR>gv
vnoremap ]e :m '>+1<CR>gv

"jump to errors
nnoremap ]r :ALENext<CR>
nnoremap [r :ALEPrevious<CR>
map <leader>at :ALEToggle<CR>

" Allignemnt
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" Telescope
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

"Map Ctrl + S to save in any mode
noremap <silent> <C-s>          :update<CR>
vnoremap <silent> <C-s>         <C-C>:update<CR>
inoremap <silent> <C-s>         <C-O>:update<CR>

"quit quickly | without saving
nnoremap <leader>q :q<CR>j
nnoremap <leader>qa <ESC>:qa!<CR>

"Easily edit files in the same directory
nnoremap <leader>e :e <C-R>=expand('%:p:h') . '/'<CR>

"Open Explorer
nnoremap <leader>n :Explore<CR>

"Clear line
nnoremap <Leader>dl 0D

"
" /END MAPPINGS
"

"
"Airline
"
set laststatus=2
let g:airline#extensions#bufferline#enabled = 0
let g:airline_section_z = ''
let g:airline_section_y = ''
let g:airline_section_c = '%F'
let g:airline_theme='papercolor'
let g:airline_detect_spell=0
let g:airline#extensions#tabline#formatter = 'short_path'

"
" SEARCH
"

set hlsearch
nnoremap <Leader>cs :nohlsearch<cr>
nnoremap <silent> [q :cprev<cr>
nnoremap <silent> ]q :cnext<cr>
set ignorecase
set smartcase
set incsearch

"Ack grepping using ag
cnoreabbrev Ack Ack!
nnoremap <Leader>g :Ack!<Space>
"" END SEARCH


"Remove all trailing spaes on save
autocmd FileType c,html,css,js,php autocmd BufWritePre <buffer> %s/\s\+$//e

"VIM wiki
autocmd BufWinEnter *.wiki set cc=1000 "Wiki should not be bothered column on the right
nnoremap <silent> <leader>sl ?==<cr>2jV}k:sort!<cr>:nohls<cr>
nnoremap <silent> <leader>ll I-<space>[<space>]<space><esc>
vnoremap <silent> <leader>ll <C-v>I-<space>[<space>]<space><esc>
nnoremap <silent> <leader>li I-<space><esc>
let g:vimwiki_url_maxsave=0
nnoremap <leader>rn vip:RenumberSelection<CR>
let g:vimwiki_list = [{'syntax': 'markdown', 'ext': '.md'},{'path': '~/Documents/Automattic/','syntax': 'markdown', 'ext': '.md'}]

"Copy/Pasting
set clipboard+=unnamedplus

"Netrw - Vims default directory viewer
let g:netrw_men=0

"ALE
let g:ale_open_list = 0
let g:ale_php_phpcs_standard='WordPress'

"AutoSave plugin
let g:auto_save = 1  " enable AutoSave on Vim startupc
let g:auto_save_no_updatetime = 1  " do not change the 'updatetime' option
let g:auto_save_in_insert_mode = 0  " do not save while in insert mode

"
" FUNCTIONS
"

" ZSH in VIM
function! Setshell()
   if filereadable("/usr/local/bin/zsh")
       set shell=/usr/local/bin/zsh
   endif
endfunction
call Setshell()

" Prompt user to enter URL and optional TARGET.
" Inserts an markdown link: a line after the cursor like
"   [title](URL)
" where 'Page title' is determined from the html source read from URL.
" Requires wget (or similar) tool to get source.
nnoremap <leader>al :call AddLink()<CR>
function! AddLink()
	let url = input('URL to add? ')
	if empty(url)
		return
	endif
	let html = system('curl -s ' . shellescape(url))
	let regex = '\c.*head.*<title[^>]*>\_s*\zs.\{-}\ze\_s*<\/title>'
	let title = substitute(matchstr(html, regex), "\n", ' ', 'g')
	let title = system( 'echo ' . shellescape(title) . ' | textutil -convert txt -format html -stdin -stdout')
	if empty(title)
		let title = 'Unknown'
	endif
	put ='[' . title . '](' . url . ')'
endfunction
