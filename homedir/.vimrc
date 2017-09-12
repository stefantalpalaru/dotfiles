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

unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

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
command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
	 	\ | wincmd p | diffthis

" pathogen
call pathogen#infect()

map <C-Up> :tabnew<CR>
"map <C-Down> :tabclose<CR>
map <C-Down> :q<CR>
map <C-Left> gT
map <C-Right> gt

set statusline=%m%F%r%h%w\ %y\ [line:%04l\ col:%04v]\ [%p%%]\ [lines:%L]
set laststatus=2
"set shiftwidth=4
"set tabstop=4
"set softtabstop=4
"set expandtab
set ic
set scs
set tags=./tags;

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

set modeline
set number

" ==session options==
set ssop-=options
set ssop-=folds

" htmldjango
au FileType htmldjango setlocal shiftwidth=4
au FileType htmldjango setlocal tabstop=4
au FileType htmldjango setlocal softtabstop=4
au FileType htmldjango setlocal expandtab

" jinja
au FileType jinja setlocal shiftwidth=4
au FileType jinja setlocal tabstop=4
au FileType jinja setlocal softtabstop=4
au FileType jinja setlocal expandtab

" perl
au FileType perl setlocal shiftwidth=4
au FileType perl setlocal tabstop=4
au FileType perl setlocal softtabstop=4
au FileType perl setlocal expandtab

" js
au FileType javascript setlocal shiftwidth=4
au FileType javascript setlocal tabstop=4
au FileType javascript setlocal softtabstop=4
au FileType javascript setlocal expandtab

" nim
autocmd FileType nim call s:NimConfigure()
function s:NimConfigure()
    setlocal shiftwidth=2
    setlocal tabstop=8
    setlocal softtabstop=2
    setlocal expandtab
    setlocal textwidth=80
    " inspired by https://github.com/vivien/vim-linux-coding-style
    highlight default link NimError ErrorMsg
    syn match NimError /\%>80v[^()\{\}\[\]<>]\+/ " virtual column 81 and more
    " Highlight trailing whitespace, unless we're in insert mode and the
    " cursor's placed right after the whitespace. This prevents us from having
    " to put up with whitespace being highlighted in the middle of typing
    " something
    autocmd InsertEnter * match NimError /\s\+\%#\@<!$/
    autocmd InsertLeave * match NimError /\s\+$/
endfunction

" color scheme
"colorscheme evening
set background=dark
colorscheme solarized

" disable the Background Color Erase that messes with some color schemes
set t_ut=

" vim-slime
"let g:slime_target = "tmux"
let g:slime_target = "screen"

" gitgutter
au VimEnter * highlight clear SignColumn

" haskellmode-vim
let g:haddock_browser="/usr/bin/firefox"

" go
autocmd FileType go autocmd BufWritePre <buffer> Fmt

" syntastic
"let g:syntastic_mode_map = { 'mode': 'active',
			"\ 'active_filetypes': [],
			"\ 'passive_filetypes': [] }
"let g:syntastic_python_checkers = ['flake8']
"let g:syntastic_python_flake8_args = '--ignore=E,W,F403,F405 --select=F,C'
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*

" ALE
let g:ale_linters = {
\   'python': ['flake8'],
\   'c': ['clang'],
\}
let g:ale_python_flake8_args = '--ignore=E,W,F403,F405 --select=F,C'
let g:ale_c_clang_options = '-std=c11 -Wall -Wextra -fexceptions -DNDEBUG'
set statusline+=%{ALEGetStatusLine()}
let g:ale_statusline_format = ['⨉ %d', '⚠ %d', '⬥ ok']
let g:ale_echo_msg_format = '%linter%: %s'
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

" smarty
au BufRead,BufNewFile *.tpl set filetype=smarty

" gnuplot
au BufRead,BufNewFile *.gnuplot set filetype=gnuplot

" vala
au BufRead,BufNewFile *.vala,*.vapi,*.vala.in set filetype=vala efm=%f:%l.%c-%[%^:]%#:\ %t%[%^:]%#:\ %m shiftwidth=4 tabstop=4 softtabstop=4 expandtab smarttab

" genie
au BufRead,BufNewFile *.gs set filetype=genie shiftwidth=4 tabstop=4 softtabstop=4 expandtab smarttab

"" youcompleteme
"let g:ycm_enable_diagnostic_signs = 0
"let g:ycm_global_ycm_extra_conf = '/usr/share/vim/vimfiles/third_party/ycmd/examples/.ycm_extra_conf.py'
"let g:ycm_confirm_extra_conf = 0
"let g:ycm_autoclose_preview_window_after_completion = 1
"let b:ycm_largefile = 1

" neocomplete
let g:neocomplete#enable_at_startup = 1
" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" VUE
au BufRead,BufNewFile *.vue set filetype=xml

" airline
let g:airline_theme = 'solarized'
let g:airline_solarized_bg = 'dark'
let g:airline_powerline_fonts = 1

