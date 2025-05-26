call plug#begin('~/.vim/plugged')

Plug 'airblade/vim-gitgutter'
Plug 'ap/vim-css-color'
Plug 'dense-analysis/ale'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'sainnhe/gruvbox-material'
Plug 'scrooloose/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'ycm-core/YouCompleteMe', { 'do': './install.py' }

call plug#end()

set nocompatible          " Be iMproved
set ttyfast               " Terminal acceleration

syntax on                 " Syntax highlighting
filetype plugin on        " Enable filetype plugins
filetype indent on

if has('termguicolors')   " Color scheme
  set termguicolors
endif
set background=dark
let g:gruvbox_material_background='hard'
let g:gruvbox_material_better_performance=1
colorscheme gruvbox-material
hi SpellBad cterm=underline

set autoread              " Automatically reload files
set wildmenu              " Better command completion
set updatetime=100        " More frequent updates

set laststatus=2          " Always show statusbar
set number                " Show line numbers
set cursorline            " Highlight the current line
set showmatch             " Highlight matching bracket pairs
set scrolloff=1           " Always show at least one line above/below the cursor
set spell                 " Spell checking

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
set textwidth=120         " Also enables auto wrap

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

" Airline
let g:airline_powerline_fonts = 1

" fzf
nnoremap <C-p> :Files<CR>

" NERDTree
nnoremap <C-n> :NERDTreeToggle<CR>

" YCM/ALE

" Jump to definition and documentation
nnoremap <F3> :YcmCompleter GoTo<CR>
nnoremap <F4> :YcmCompleter GetDoc<CR>

" Otherwise it stays open
let g:ycm_autoclose_preview_window_after_completion = 1

" Hack to make YCM use any conda environment
if $CONDA_PREFIX != ""
    let g:ycm_python_interpreter_path = $CONDA_PREFIX . '/bin/python'
else
    let g:ycm_python_interpreter_path = '/home/elin/miniconda3/bin/python'
endif
let g:ycm_extra_conf_vim_data = ['g:ycm_python_interpreter_path']
let g:ycm_global_ycm_extra_conf = '~/.vim/ycm_global_extra_conf.py'
let g:ale_python_ruff_executable ='/home/elin/miniconda3/bin/ruff'

" Error highlight
let g:ale_virtualtext_cursor = 'disabled'
highlight ALEError cterm = underline
highlight ALEWarning cterm = underline

" Decides what `ALEFix` defaults to
let g:ale_fixers = {
            \ '*': ['remove_trailing_lines', 'trim_whitespace'],
            \ 'python': ['ruff', 'ruff_format']
            \ }

" Delete whitespace errors on save
:autocmd BufWritePre * ALEFix remove_trailing_lines trim_whitespace

" Python auto-formatting
nnoremap <leader>f :ALEFix<CR>
