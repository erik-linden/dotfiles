call plug#begin('~/.vim/plugged')

Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }
Plug 'w0rp/ale'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
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
nnoremap <leader>w :w<CR>

" Additional escape mapping
inoremap jj <Esc>
inoremap jk <Esc>

" Map 0 to the first non-blank character and + to the last
nnoremap 0 ^
nnoremap + $

" Map <Space> to search and Ctrl-<Space> to backwards search
nnoremap <Space> /
nnoremap <C-Space> ?

" Disable highlighting when <leader><CR> is pressed
nnoremap <silent> <leader><CR> :noh<CR>

" Jump between splits
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" fzf
nnoremap <C-p> :Files<CR>

" NERDTree
nnoremap <C-n> :NERDTreeToggle<CR>

" Jump to definition and documentation
nnoremap <F3> :YcmCompleter GoTo<CR>
nnoremap <F4> :YcmCompleter GetDoc<CR>

" Otherwise it stays open
let g:ycm_autoclose_preview_window_after_completion = 1

" Hack to make YCM use any conda environment
if $CONDA_PREFIX != ""
    let g:ycm_python_interpreter_path = $CONDA_PREFIX . '/bin/python'
else
    let g:ycm_python_interpreter_path = ''
endif
let g:ycm_extra_conf_vim_data = ['g:ycm_python_interpreter_path']
let g:ycm_global_ycm_extra_conf = '~/.vim/ycm_global_extra_conf.py'

" Python syntax checking
let g:ale_python_flake8_options = '--max-line-length=119'
let g:ale_python_pylint_options = '
            \ --max-line-length=119
            \ -d missing-docstring
            \ -d too-many-instance-attributes
            \ -d too-many-locals
            \ -d too-many-statements
            \ -d ungrouped-imports'

" Decides what `ALEFix` defaults to
let g:ale_fixers = { 'python': ['autopep8'] }

" Delete whitespace errors on save
:autocmd BufWritePost * ALEFix remove_trailing_lines trim_whitespace

" Python auto-formatting
nnoremap <leader>f :ALEFix<CR>
nnoremap <leader>o :ALEFix isort<CR>

let g:ale_python_autopep8_options = '--max-line-length=119'
let g:ale_python_isort_options =  '-w=119'

" Setup Powerline
" vim always uses the system interpreter, so we fiddle with the path
python3 import sys, os
python3 sys.path.insert(0, os.path.expanduser('~/miniconda3/lib/python3.6/site-packages/'))
python3 from powerline.vim import setup as powerline_setup
python3 powerline_setup()
python3 del powerline_setup
