" Setup Powerline
python from powerline.vim import setup as powerline_setup
python powerline_setup()
python del powerline_setup

syntax on
filetype indent plugin on

set nocompatible         " Be iMproved
set laststatus=2         " Always show statusbar
set t_Co=256             " More colors

set number               " Show line numbers
set ttyfast              " Terminal acceleration

set tabstop=4            " 4 whitespaces for tab presentation
set shiftwidth=4         " Shift lines by 4 spaces
set smarttab             " Set tabs for a shiftab logic
set expandtab            " Expand tabs into spaces
set autoindent           " Auto indent when moving to next line

set showmatch            " Highlight matching bracket pairs
set clipboard=unnamed    " Use system clipboard

" Additional escape mapping
inoremap jj <Esc>
inoremap jk <Esc>

" Jump between splits
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" More natural split opening
set splitbelow
set splitright
