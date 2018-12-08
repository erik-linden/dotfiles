set nocompatible          " Be iMproved
set ttyfast               " Terminal acceleration

syntax on                 " Syntax highlighting
filetype plugin on        " Enable filetype plugins
filetype indent on

set t_Co=256              " More colors
set background=dark       " Color scheme
colorscheme gruvbox

set autoread              " Automatically reload files
set wildmenu              " Better command completion

set laststatus=2          " Always show statusbar
set number                " Show line numbers
set cursorline            " Highlight the current line
set showmatch             " Highlight matching bracket pairs

set ignorecase            " Ignore case when searching
set smartcase             " Case-sensitive if caps in query
set hlsearch              " Highlight search results
set incsearch             " Like searching in a browser

set tabstop=4             " 4 whitespaces for tab presentation
set shiftwidth=4          " Shift lines by 4 spaces
set smarttab              " Set tabs for a shiftab logic
set expandtab             " Expand tabs into spaces
set autoindent            " Auto indent when moving to next line
set nojoinspaces          " Auto format puts one space between sentences

set mouse=a               " Enable mouse support
set clipboard=unnamedplus " Use system clipboard

set nobackup              " Disable backups
set nowritebackup
set noswapfile

set splitbelow            " More natural split opening
set splitright

" Comma as leader
let mapleader = ","

" Save with <leader>w
nmap <leader>w :w<CR>

" Additional escape mapping
inoremap jj <Esc>
inoremap jk <Esc>

" Map 0 to first non-blank character
map 0 ^

" Map <Space> to search and Ctrl-<Space> to backwards search
map <Space> /
map <C-Space> ?

" Disable highlighting when <leader><CR> is pressed
map <silent> <leader><CR> :noh<CR>

" Jump between splits
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Remove trailing whitespaces on save
autocmd BufWritePre * :%s/\s\+$//e

" Setup Powerline
python3 from powerline.vim import setup as powerline_setup
python3 powerline_setup()
python3 del powerline_setup
