call plug#begin('~/.vim/plugged')

Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }
Plug 'w0rp/ale'
Plug 'nvie/vim-flake8'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'Chiel92/vim-autoformat'
Plug 'airblade/vim-gitgutter'
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-surround'
Plug 'flazz/vim-colorschemes'

call plug#end()

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
set updatetime=100        " More frequent updates

set laststatus=2          " Always show statusbar
set number                " Show line numbers
set cursorline            " Highlight the current line
set showmatch             " Highlight matching bracket pairs
set scrolloff=1           " Always show at least one line above/below the cursor

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

" fzf
map <C-p> :Files<CR>

" NERDTree
map <C-n> :NERDTreeToggle<CR>

" YouCompleteMe
let g:ycm_autoclose_preview_window_after_completion = 1

" Remove trailing whitespaces on save
let g:ale_fixers = {'*': ['remove_trailing_lines', 'trim_whitespace']}
let g:ale_fix_on_save = 1

" Python syntax checking
let g:ale_linters = {'python': ['flake8']}
let g:ale_python_flake8_options = '--max-line-length=119'

" Python autopep8
noremap <F3> :Autoformat<CR>
let g:formatdef_autopep8 = "'autopep8 - --max-line-length 119 --range '.a:firstline.' '.a:lastline"
let g:formatters_python = ['autopep8']

" Setup Powerline
python3 from powerline.vim import setup as powerline_setup
python3 powerline_setup()
python3 del powerline_setup
