" Vim color file
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last Change:	2001 Jul 23

" This is the default color scheme.  It doesn't define the Normal
" highlighting, it uses whatever the colors used to be.

" Set 'background' back to the default.  The value can't always be estimated
" and is then guessed.
hi clear Normal
set bg&

" Remove all existing highlighting and set the defaults.
hi clear

" Load the syntax highlighting defaults, if it's enabled.
if exists("syntax_on")
  syntax reset
endif

let colors_name = "phil"

hi Comment    	cterm=NONE ctermfg=DarkBlue    gui=NONE 	guifg=red2
hi Constant   	cterm=NONE ctermfg=DarkRed     gui=NONE 	guifg=green3
hi Identifier 	cterm=NONE ctermfg=DarkBlue    gui=NONE 	guifg=cyan4
hi PreProc    	cterm=NONE ctermfg=DarkMagenta gui=NONE 	guifg=magenta3
hi Special    	cterm=NONE ctermfg=DarkMagenta gui=NONE 	guifg=deeppink
hi Statement  	cterm=NONE ctermfg=Brown       gui=bold 	guifg=blue
hi Type	      	cterm=NONE ctermfg=DarkGreen   gui=bold 	guifg=blue
hi Directory  	cterm=NONE ctermfg=4	       			guifg=Blue
hi CursorLineNr cterm=NONE ctermfg=Brown       			guifg=Brown
hi LineNr 	cterm=NONE ctermfg=Brown       			guifg=Brown

" vim: sw=2
