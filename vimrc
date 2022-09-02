" Set syntax on
if has("syntax")
  syntax on
endif

" Use hljk to move between windows
map <C-H> <C-W>h<C-W>_
map <C-L> <C-W>l<C-W>_
map <C-J> <C-W>j<C-W>_
map <C-K> <C-W>k<C-W>_

" Use my own colorscheme
colorscheme phil

" Source a global configuration file if available
if filereadable("/etc/vim/vimrc.local")
  source /etc/vim/vimrc.local
endif

" Disable vi compatibility
set nocompatible

" Word wrap, making sure we don't break in the middle of words
set wrap
set linebreak

" Turn on line numbers
set number

" Show the mode we are currently in
set showmode

" Make backspace behave properly
set backspace=indent,eol,start

" Disable modelines
set modelines=0

" Show command in statusline
set showcmd

" Show matching brackets
set showmatch

" Enable mouse usage
set mouse=a

" Set incremental search
set incsearch

" Set wildcard mode: list all matches, complete longest full match
set wildmode=list:longest,full

" Enable titlebar
set title

" Enable search highlighting
set hlsearch

" Enable backup files
set backup
set backupdir=$HOME/.vim/.vimbackup
set directory=$HOME/.vim/.vimswap
set viewdir=$HOME/.vim/.vimviews

" Undo stuff
set undofile
set undolevels=1000
set undoreload=10000
set undodir=$HOME/.vim/.vimundo

" Duh
syntax enable

" Make our internal Vim contents directories
silent execute '!mkdir -p $HOME/.vim/.vimbackup'
silent execute '!mkdir -p $HOME/.vim/.vimswap'
silent execute '!mkdir -p $HOME/.vim/.vimviews'
silent execute '!mkdir -p $HOME/.vim/.vimundo'

" Set command line info at bottom of screen 
if has ('cmdline_info')
  set ruler
  set showcmd
endif

" Set characters to wrap 
set whichwrap=b,s,h,l,<,>,[,]

" Set scrolling boundaries
set scrolljump=5
set scrolloff=3

" Set folding options
set foldenable
set foldmethod=indent
set foldlevel=99

" General autocmd settings
autocmd BufWinLeave * silent! mkview
autocmd BufWinEnter * silent! loadview
autocmd FileType * let b:comment = "#"

" Set sandbox files as scheme
autocmd BufNewFile,BufRead *.sb set filetype=scheme
autocmd FileType scheme set ts=2 sw=2 expandtab smarttab

" We likes our arm assembly
autocmd BufNewFile,BufRead *.s let asmsytnax='armasm'|let filetype_inc='armasm'
autocmd BufNewFile,BufRead *.asm let asmsytnax='nasm'
autocmd FileType asm set ts=4 sw=4 expandtab smarttab autoindent
autocmd FileType nasm set ts=4 sw=4 expandtab smarttab autoindent
autocmd FileType asm let b:comment = ";"
autocmd FileType nasm let b:comment = ";"

" C-like settings
autocmd BufNewFile,BufRead *.m set filetype=objc
autocmd FileType c,cpp,objc set ts=4 sw=4 expandtab smarttab cindent
autocmd FileType c set formatoptions+=ro
autocmd FileType c let b:comment = '\/\/'

" Python settings
autocmd FileType python set ts=4 sw=4 expandtab smarttab autoindent
autocmd FileType python set omnifunc=pythoncomplete#Complete

" JavaScript settings
autocmd FileType javascript set ts=4 sw=4 expandtab smarttab cindent
autocmd FileType javascript let b:comment = '\/\/'
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS

" HTML settings
autocmd FileType html set ts=4 sw=4 expandtab smarttab
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags

" Shell settings
autocmd FileType sh set ts=4 sw=4 expandtab smarttab

" Makefile settings
autocmd FileType make set noexpandtab sw=8

" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')

" Declare the list of plugins.
Plug 'scrooloose/nerdtree'
Plug 'Shirk/vim-gas'
Plug 'compnerd/arm64asm-vim'
Plug 'b4winckler/vim-objc'
Plug 'fatih/vim-go'
Plug 'msanders/cocoa.vim'
Plug 'rust-lang/rust.vim'
Plug 'keith/swift.vim'
Plug 'tmsvg/pear-tree'
Plug 'ycm-core/YouCompleteMe'
" List ends here. Plugins become visible to Vim after this call.
call plug#end()

"
" YouCompleteMe options
"
" Don't ask for extraconf
let g:ycm_confirm_extra_conf = 0

" Include filetype in extra conf data
let g:ycm_extra_conf_vim_data = [ '&filetype' ]

" Turn off the preview window
let g:ycm_autoclose_preview_window_after_completion = 1

" Turn off the preview window
let g:ycm_autoclose_preview_window_after_insertion = 1

" Turn off annoying YCM diagnostic highlighting
let g:ycm_enable_diagnostic_highlighting = 0

" Shortcut for goto
nnoremap <C-]> :YcmCompleter GoTo<CR>

"
autocmd CompleteDone * pclose

" Get rid of the preview window
set completeopt-=preview

" Configure NERDTree and other shortcuts
let mapleader = " "
nmap <leader>t :NERDTree<cr>
nmap <leader>nc :NERDTreeClose
nmap <silent> <leader>/ :nohlsearch<CR>
nmap <leader>h :tabprevious<cr>
nmap <leader>l :tabnext<cr>
nmap <leader>o :tabnew<cr>
nmap <leader>c :tabclose<cr>

" TODO: Comment stuff
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

" TODO: WTF does all this do
nnoremap ; : 

cmap w!! w !sudo tee % >/dev/null

func AddComment()
  return ':s/^\(\s*\)/\1' . b:comment . "/\r:nohl\r"
endfunc

func RemoveComment()
  return ':s/^\(\s*\)/' . b:comment . "/\\1/\r:nohl\r"
endfunc
nmap - <C-_><C-_>
vmap - <C-_><C-_>
vnoremap <C-c> "+y
