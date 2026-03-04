" ==============================================================================
" BASE SETTINGS
" ==============================================================================
set nocompatible            " Disable compatibility with vi
set encoding=utf-8          " Standard encoding
syntax on                   " Enable syntax highlighting
set number                  " Show line numbers
"set relativenumber          " Show relative line numbers (great for jumping)
set mouse=a                 " Enable mouse support in all modes
set clipboard=unnamedplus   " Use system clipboard (great for Arch Linux)
set cursorline              " Highlight the current line
set showmatch               " Highlight matching braces/parentheses

" Search Settings
set ignorecase              " Ignore case when searching
set smartcase               " ...unless you type a capital letter
set incsearch               " Show search matches as you type
set hlsearch                " Highlight all search matches

" Tab & Indentation Settings (Default to 4 spaces, good for Python/C)
set tabstop=4
set shiftwidth=4
set expandtab
set smartindent
set autoindent

" Filetype specific overrides (e.g., 2 spaces for web dev)
autocmd FileType html,css,javascript,json setlocal shiftwidth=2 tabstop=2

" ==============================================================================
" PLUGIN MANAGEMENT (via vim-plug)
" ==============================================================================
" Install vim-plug automatically if not present
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" 1. File Explorer
Plug 'preservim/nerdtree'

" 2. Autocomplete & Intellisense (Requires Node.js installed on your system)
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" 3. Syntax Highlighting Pack (Supports C, Python, JS, HTML, SQL, etc.)
Plug 'sheerun/vim-polyglot'

" 4. Status Bar
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" 5. Fuzzy Finder (Requires fzf installed on your system)
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" 6. Git Integration
Plug 'tpope/vim-fugitive'

" 7. Theme
Plug 'tomasr/molokai'

call plug#end()

" ==============================================================================
" PLUGIN CONFIGURATION & KEYMAPS
" ==============================================================================
" Set Leader Key to Space
let mapleader = " "

" --- Theme Setup ---
colorscheme molokai
let g:molokai_original = 1  " Matches the original Sublime Text Monokai colors
set background=dark

" --- NERDTree ---
" Toggle NERDTree with Ctrl+n
nnoremap <C-n> :NERDTreeToggle<CR>
" Find current file in NERDTree
nnoremap <leader>nf :NERDTreeFind<CR>

" --- FZF (Fuzzy Finder) ---
" Search files with Ctrl+p
nnoremap <C-p> :Files<CR>
" Search inside files (requires ripgrep)
nnoremap <leader>rg :Rg<CR>

" --- CoC (Conquer of Completion) ---
" Use Tab to navigate completion list
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
" Use Enter to confirm completion
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Rename symbol
nmap <leader>rn <Plug>(coc-rename)

" Show documentation on hover (Shift+K)
nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction