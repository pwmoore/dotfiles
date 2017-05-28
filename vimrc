" All system-wide defaults are set in $VIMRUNTIME/debian.vim (usually just
" /usr/share/vim/vimcurrent/debian.vim) and sourced by the call to :runtime
" you can find below.  If you wish to change any of those settings, you should
" do it in this file (/etc/vim/vimrc), since debian.vim will be overwritten
" everytime an upgrade of the vim packages is performed.  It is recommended to
" make changes after sourcing debian.vim since it alters the value of the
" 'compatible' option.

" This line should not be removed as it ensures that various options are
" properly set to work with the Vim-related packages available in Debian.
runtime! debian.vim

" Uncomment the next line to make Vim more Vi-compatible
" NOTE: debian.vim sets 'nocompatible'.  Setting 'compatible' changes numerous
" options, so any other options should be set AFTER setting 'compatible'.
"set compatible

" Vim5 and later versions support syntax highlighting. Uncommenting the next
" line enables syntax highlighting by default.
if has("syntax")
  syntax on
endif

" If using a dark background within the editing area and syntax highlighting
" turn on this option as well
"set background=dark

" Uncomment the following to have Vim jump to the last position when
" reopening a file
"if has("autocmd")
"  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
"endif

" Uncomment the following to have Vim load indentation rules and plugins
" according to the detected filetype.
"if has("autocmd")
"  filetype plugin indent on
"endif

" The following are commented out as they cause vim to behave a lot
" differently from regular Vi. They are highly recommended though.
"set showcmd		" Show (partial) command in status line.
"set showmatch		" Show matching brackets.
"set ignorecase		" Do case insensitive matching
"set smartcase		" Do smart case matching
"set incsearch		" Incremental search
"set autowrite		" Automatically save before commands like :next and :make
"set hidden             " Hide buffers when they are abandoned
"set mouse=a		" Enable mouse usage (all modes)

" Source a global configuration file if available
if filereadable("/etc/vim/vimrc.local")
  source /etc/vim/vimrc.local
endif

set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call plug#begin()
Plug 'VundleVim/Vundle.vim'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/syntastic'
Plug 'Valloric/YouCompleteMe'
Plug 'SirVer/ultisnips'
Plug 'Shirk/vim-gas'
Plug 'vim-scripts/taglist.vim'
Plug 'ervandew/supertab'
Plug 'Shougo/unite.vim'
Plug 'compnerd/arm64asm-vim'
Plug 'tomtom/tcomment_vim'
Plug 'craigemery/vim-autotag'
Plug 'b4winckler/vim-objc'
Plug 'fatih/vim-go'
Plug 'msanders/cocoa.vim'
call plug#end()

if has("autocmd")
  filetype indent on
  filetype plugin on
endif

set wrap
set showmode
set showcmd
set showmatch
set smartcase
set incsearch
set mouse=a
set history=100
set wildmode=list:longest,full
set shortmess+=r
set title
set hlsearch
set number

set backup
set undofile 
set undolevels=1000
set undoreload=10000
set undodir=$HOME/.vim/.vimundo//
set backupdir=$HOME/.vim/.vimbackup//
set directory=$HOME/.vim/.vimswap//
set viewdir=$HOME/.vim/.vimviews//

silent execute '!mkdir -p $HOME/.vim/.vimbackup'
silent execute '!mkdir -p $HOME/.vim/.vimswap'
silent execute '!mkdir -p $HOME/.vim/.vimviews'
silent execute '!mkdir -p $HOME/.vim/.vimundo'
au BufWinLeave * silent! mkview
au BufWinEnter * silent! loadview

set tabpagemax=15
set showmode
if has ('cmdline_info')
  set ruler
  set showcmd
endif

set backspace=indent,eol,start
set linespace=0
set nu
set showmatch
set whichwrap=b,s,h,l,<,>,[,]
set scrolljump=5
set scrolloff=3
set foldenable
set foldmethod=indent
set foldlevel=99

let asmsyntax="nasm"

autocmd BufNewFile,BufRead *.sb set filetype=scheme
autocmd BufNewFile,BufRead *.m set filetype=objc
autocmd BufNewFile,BufRead *.s let asmsytnax='armasm'|let filetype_inc='armasm'
autocmd BufNewFile,BufRead *.asm let asmsytnax='nasm'
autocmd BufNewFile,BufRead *.py set ts=4 sw=4 expandtab smarttab autoindent
autocmd FileType * set noexpandtab
autocmd FileType c,cpp,objc set ts=4 sw=4 expandtab smarttab cindent
autocmd FileType javascript set ts=4 sw=4 expandtab smarttab cindent
autocmd FileType python set ts=4 sw=4 expandtab smarttab autoindent
autocmd FileType asm set ts=4 sw=4 expandtab smarttab autoindent
autocmd FileType nasm set ts=4 sw=4 expandtab smarttab autoindent
autocmd FileType c set formatoptions+=ro
autocmd FileType html set ts=4 sw=4 expandtab smarttab
autocmd FileType sh set ts=4 sw=4 expandtab smarttab
autocmd FileType make set noexpandtab sw=8
autocmd FileType scheme set ts=2 sw=2 expandtab smarttab
autocmd FileType ruby set ts=4 sw=4 expandtab smarttab autoindent

autocmd FileType * let b:comment = "#"
autocmd FileType asm let b:comment = ";"
autocmd FileType nasm let b:comment = ";"
autocmd FileType vim let b:comment = "\""
autocmd FileType c let b:comment = '\/\/'
autocmd FileType javascript let b:comment = '\/\/'

autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType ruby set omnifunc=rubycomplete#Complete
autocmd FileType ruby let g:rubycomplete_buffer_loading=1
autocmd FileType ruby let g:rubycomplete_classes_in_global=1

let g:go_highlight_functions = 1  
let g:go_highlight_methods = 1  
let g:go_highlight_structs = 1  
let g:go_highlight_operators = 1  
let g:go_highlight_build_constraints = 1 

set wmh=0
map <C-H> <C-W>h<C-W>_
map <C-L> <C-W>l<C-W>_
map <C-J> <C-W>j<C-W>_
map <C-K> <C-W>k<C-W>_

nmap - <C-_><C-_>
vmap - <C-_><C-_>

let mapleader = ","
nmap <leader>ne :NERDTree<cr>
nmap <leader>nc :NERDTreeClose
nmap <silent> <leader>/ :nohlsearch<CR>
nmap <leader>h :tabprevious<cr>
nmap <leader>l :tabnext<cr>
nmap <leader>o :tabnew<cr>
nmap <leader>c :tabclose<cr>

function! ConditionalPairMap(open, close)
	let line = getline('.')
	let col = col('.')
	if col < col('$') || stridx(line, a:close, col + 1) != -1
		return a:open
	else
		return a:open . a:close . repeat("\<left>", len(a:close))
	endif
endf
inoremap <expr> ( ConditionalPairMap('(', ')')
inoremap <expr> { ConditionalPairMap('{', '}')
inoremap <expr> [ ConditionalPairMap('[', ']')
"inoremap <expr> " ConditionalPairMap('"', '"')
"inoremap "	""<Left>
inoremap {<CR>	{<CR>}<Esc>O

nnoremap ; : 

cmap w!! w !sudo tee % >/dev/null

func AddComment()
  return ':s/^\(\s*\)/\1' . b:comment . "/\r:nohl\r"
endfunc

func RemoveComment()
  return ':s/^\(\s*\)/' . b:comment . "/\\1/\r:nohl\r"
endfunc

if has("unix")
  let s:uname = system("uname -s")
  if s:uname == "Darwin"
    hi Normal ctermbg=16
    colorscheme phil 
  else
    colorscheme default
endif
endif
vnoremap <C-c> "+y
"set background=dark
" let g:ycm_global_ycm_extra_conf = "~/projects/dev/darwin_extra_conf.py" 
let g:ycm_confirm_extra_conf = 0
let g:ycm_extra_conf_vim_data = [ '&filetype' ]
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_collect_identifiers_from_tags_files = 1

nnoremap <C-]> :YcmCompleter GoTo<CR>

autocmd CompleteDone * pclose
set completeopt-=preview
colorscheme phil
