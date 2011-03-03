" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2006 Nov 16
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set nobackup		" keep a backup file
endif
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" In many terminal emulators the mouse works just fine, thus enable it.
set mouse=a

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END
  
  " Drupal PHP files with strange extensions
  augroup drupal
   autocmd BufNewFile,BufRead *.module set filetype=php
   autocmd BufNewFile,BufRead *.engine set filetype=php
  augroup END

  " flex
  au BufNewFile,BufRead *.mxml set filetype=mxml
  au BufNewFile,BufRead *.as set filetype=actionscript

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
	 	\ | wincmd p | diffthis

colorscheme evening

map <C-Up> :tabnew<CR>
"map <C-Down> :tabclose<CR>
map <C-Down> :q<CR>
map <C-Left> gT
map <C-Right> gt

set statusline=%m%F%r%h%w\ %y\ [line:%04l\ col:%04v]\ [%p%%]\ [lines:%L]
set laststatus=2
set shiftwidth=1
set ic
set scs
set tags=./tags;


" python settings
"autocmd BufRead *.py setlocal shiftwidth=4
"autocmd BufRead *.py setlocal tabstop=4
"autocmd BufRead *.py setlocal softtabstop=4
"autocmd BufRead *.py setlocal expandtab

" htmldjango
au FileType htmldjango setlocal shiftwidth=4
au FileType htmldjango setlocal tabstop=4
au FileType htmldjango setlocal softtabstop=4
au FileType htmldjango setlocal expandtab

" perl
au FileType perl setlocal shiftwidth=4
au FileType perl setlocal tabstop=4
au FileType perl setlocal softtabstop=4
au FileType perl setlocal expandtab

" ==Nekthuth==
let g:nekthuth_sbcl = "/usr/bin/sbcl"
" execute form
au FileType lisp map <C-J> :NekthuthSexp<CR>
au FileType lisp map <C-E> :NekthuthTopSexp<CR>

" Can prefix with number
au FileType lisp map <C-K> :NekthuthMacroExpand<CR>

" Close and re-open the nekthuth
au FileType lisp map <C-I> :NekthuthClose<CR>:NekthuthOpen<CR>:redraw!<CR>
" Close it
au FileType lisp map <C-W> :NekthuthClose<CR>

" Get word underneath cursor
au FileType lisp map <C-H> :Clhelp <C-R><C-W><CR>
" Interrupt the interpretor
au FileType lisp map <C-C> :NekthuthInterrupt<CR>

" Find the source location of the symbol
au FileType lisp map <C-]> :NekthuthSourceLocation<CR>


" ==taglist==
map <F4> :TlistToggle<CR>
let Tlist_WinWidth = 50

" ==persistent undo==
"set undofile

" ==auto reload modified files==
set autoread

