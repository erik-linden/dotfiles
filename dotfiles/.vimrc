call plug#begin('~/.vim/plugged')

Plug 'ycm-core/YouCompleteMe', { 'do': './install.py' }
Plug 'dense-analysis/ale'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'airblade/vim-gitgutter'
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-surround'
Plug 'morhetz/gruvbox'

call plug#end()

set nocompatible          " Be iMproved
set ttyfast               " Terminal acceleration

syntax on                 " Syntax highlighting
filetype plugin on        " Enable filetype plugins
filetype indent on

set t_Co=256              " More colors
set background=dark       " Color scheme
colorscheme gruvbox
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

" Fix something: https://stackoverflow.com/questions/62148994/strange-character-since-last-update-42m-in-vim
let &t_TI = ""
let &t_TE = ""

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
    let g:ale_python_pylint_executable = $CONDA_PREFIX . '/bin/pylint'
else
    let g:ycm_python_interpreter_path = '/home/tobii.intra/elin/miniconda3/bin/python'
endif
let g:ycm_extra_conf_vim_data = ['g:ycm_python_interpreter_path']
let g:ycm_global_ycm_extra_conf = '~/.vim/ycm_global_extra_conf.py'
let g:ale_python_autopep8_executable = '/home/tobii.intra/elin/miniconda3/bin/autopep8'
let g:ale_python_black_executable = '/home/tobii.intra/elin/miniconda3/bin/black'
let g:ale_python_flake8_executable ='/home/tobii.intra/elin/miniconda3/bin/flake8'

" Error highlight
let g:ale_set_highlights = 1
highlight ALEError cterm=underline
highlight ALEWarning cterm=underline

" Python syntax checking
let g:ale_python_autopep8_options = '--max-line-length=120'
let g:ale_python_black_options = '--line-length=120'
let g:ale_python_flake8_options = '--max-line-length=120, --extend-ignore=E203,W503'
let g:ale_python_pylint_options = '
            \ --init-hook="import sys; sys.path.insert(0,\"' . getcwd()  . '\")"
            \ --max-line-length=120
            \ -d bad-continuation
            \ -d bad-whitespace
            \ -d missing-docstring
            \ -d too-few-public-methods
            \ -d too-many-instance-attributes
            \ -d too-many-locals
            \ -d too-many-statements'

" Decides what `ALEFix` defaults to
let g:ale_fixers = {
            \ '*': ['remove_trailing_lines', 'trim_whitespace'],
            \ 'python': ['black']
            \ }

" Delete whitespace errors on save
:autocmd BufWritePost * ALEFix remove_trailing_lines trim_whitespace

" Python auto-formatting
nnoremap <leader>f :ALEFix<CR>

" Setup Powerline
" vim always uses the system interpreter, so we fiddle with the path
python3 import sys, os
python3 sys.path.insert(0, os.path.expanduser('~/miniconda3/lib/python3.10/site-packages/'))
python3 from powerline.vim import setup as powerline_setup
python3 powerline_setup()
python3 del powerline_setup
python3 del sys.path[0]
