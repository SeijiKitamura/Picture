if !1 | finish | endif

if has('vim_starting')
    if &compatible
     set nocompatible               " Be iMproved
    endif

    set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#begin(expand('~/.vim/bundle/'))
 NeoBundleFetch 'Shougo/neobundle.vim'
 NeoBundle 'scrooloose/nerdtree'
 NeoBundle 'Shougo/neocomplcache'
 NeoBundle 'Shougo/neosnippet-snippets'
 NeoBundle 'Shougo/unite.vim'
 NeoBundle 'ujihisa/unite-colorscheme'
 NeoBundle 'thinca/vim-quickrun'
 NeoBundle 'croaker/mustang-vim'
 NeoBundle 'davidoc/taskpaper.vim'
 NeoBundle 'itchyny/lightline.vim'
 NeoBundle 'altercation/vim-colors-solarized'
 NeoBundle 'w0ng/vim-hybrid'
 NeoBundle 'slim-template/vim-slim'
 NeoBundle 'bronson/vim-trailing-whitespace'

call neobundle#end()
NeoBundleCheck

syntax enable
filetype plugin indent on


""""""""""""""""""""""""""""""
" 各種オプションの設定
"""""""""""""""""""""""""""""""
set tags=~/.tags
set noswapfile
set ruler
set cmdheight=2
set laststatus=2
set statusline=%<%f\%m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%l,%c%V%8P
set title
set wildmenu
set showcmd
set backupdir=$HOME/.vimbackup
set browsedir=buffer
set smartcase
set hlsearch
set expandtab
set incsearch
set listchars=tab:>\ ,extends:<
set number
set showmatch
set autoindent
set smartindent
set tabstop=2
set shiftwidth=2
set smarttab
set whichwrap=b,s,h,l,<,>,[,]
set ignorecase
set smartcase
set backspace=indent,eol,start
set cursorline
set cursorcolumn
set nowritebackup
set nobackup
"set background=dark
nmap <silent> <Esc><Esc> :nohlsearch<CR>
colorscheme evening
highlight LineNr ctermfg=darkyellow
highlight CursorColumn ctermbg=Blue

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <S-Left>  <C-w><<CR>
nnoremap <S-Right> <C-w>><CR>
nnoremap <S-Up>    <C-w>-<CR>
nnoremap <S-Down>  <C-w>+<CR>
autocmd VimEnter * execute 'NERDTree'
autocmd BufNewFile,BufRead *.slim setlocal filetype=slim

