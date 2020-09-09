scriptencoding utf-8

unlet! g:skip_defaults_vim
source $VIMRUNTIME/defaults.vim

" pathogen
call pathogen#infect()

" global options
set nobackup				" do not keep backup files
set directory=~/.vim/swapfiles//	" keep the swapfiles in the same dir, but with their specific paths preserved
set history=50				" keep 50 lines of command line history
set autoindent				" always set autoindenting on
set statusline=%m%F%r%h%w\ %y\ [line:%04l\ col:%04v]\ [%p%%]\ [lines:%L] " overridden by airline
set laststatus=2
set ignorecase
set smartcase
set tags=./tags;
set modeline
set number
"set undofile		" persistent undo
set autoread		" auto reload modified files
set t_ut=		" disable the Background Color Erase that messes with some color schemes
set completeopt-=preview
set ttyfast
set foldmethod=manual
let loaded_matchparen=1 " disable the builtin matchparen.vim plugin which is killing Vim's responsiveness


" session options
set sessionoptions-=options
set sessionoptions-=folds

" simplify common tab operations
map <C-Up> :tabnew<CR>
"map <C-Down> :tabclose<CR>
map <C-Down> :q<CR>
map <C-Left> gT
map <C-Right> gt

" self-cleaning augroup, to avoid problems when sourcing ~/.vimrc multiple times
" https://www.reddit.com/r/vim/comments/4p4ogb/augroup_autocmd_need_some_clarification/d4i14it/
augroup defgroup
	autocmd!
augroup END

" Drupal PHP files with strange extensions
autocmd defgroup BufNewFile,BufRead *.module set filetype=php
autocmd defgroup BufNewFile,BufRead *.engine set filetype=php

" Flex
autocmd defgroup BufNewFile,BufRead *.mxml set filetype=mxml
autocmd defgroup BufNewFile,BufRead *.as set filetype=actionscript

" Jenkins
autocmd defgroup BufNewFile,BufRead Jenkinsfile set filetype=groovy

" Nekthuth
let g:nekthuth_sbcl = '/usr/bin/sbcl'
" execute form
autocmd defgroup FileType lisp map <C-J> :NekthuthSexp<CR>
autocmd defgroup FileType lisp map <C-E> :NekthuthTopSexp<CR>
" Can prefix with number
autocmd defgroup FileType lisp map <C-K> :NekthuthMacroExpand<CR>
" Close and re-open the nekthuth
autocmd defgroup FileType lisp map <C-I> :NekthuthClose<CR>:NekthuthOpen<CR>:redraw!<CR>
" Close it
autocmd defgroup FileType lisp map <C-W> :NekthuthClose<CR>
" Get word underneath cursor
autocmd defgroup FileType lisp map <C-H> :Clhelp <C-R><C-W><CR>
" Interrupt the interpretor
autocmd defgroup FileType lisp map <C-C> :NekthuthInterrupt<CR>
" Find the source location of the symbol
autocmd defgroup FileType lisp map <C-]> :NekthuthSourceLocation<CR>

" taglist
map <F4> :TlistToggle<CR>
let g:Tlist_WinWidth = 50

" htmldjango
autocmd defgroup FileType htmldjango setlocal shiftwidth=4 softtabstop=4 expandtab

" html
autocmd defgroup FileType html setlocal shiftwidth=4 softtabstop=4 expandtab

" Jinja
autocmd defgroup FileType jinja setlocal shiftwidth=4 softtabstop=4 expandtab

" Perl
autocmd defgroup FileType perl setlocal shiftwidth=4 softtabstop=4 expandtab

" js
autocmd defgroup FileType javascript setlocal shiftwidth=4 softtabstop=4 expandtab

" Ruby
autocmd defgroup FileType ruby setlocal shiftwidth=2 softtabstop=2 expandtab

" YAML
autocmd defgroup FileType yaml setlocal shiftwidth=2 softtabstop=2 expandtab

" Nim
autocmd defgroup FileType nim call s:NimConfigure()
function s:NimConfigure()
	setlocal shiftwidth=2 softtabstop=2 expandtab textwidth=80
	" inspired by https://github.com/vivien/vim-linux-coding-style
	highlight default link NimError ErrorMsg
	"syn match NimError /\%>80v[^()\{\}\[\]<>]\+/ " virtual column 81 and more
	" Highlight trailing whitespace, unless we're in insert mode and the
	" cursor's placed right after the whitespace. This prevents us from having
	" to put up with whitespace being highlighted in the middle of typing
	" something
	autocmd defgroup InsertEnter * match NimError /\s\+\%#\@<!$/
	autocmd defgroup InsertLeave * match NimError /\s\+$/
endfunction
autocmd defgroup BufRead,BufNewFile *.nimble set filetype=nim

" Linux coding style
let g:linuxsty_patterns = ['/usr/src/', '/src/77_DLD/CODE/00_github/w_scan2']

" color scheme
set background=dark
colorscheme solarized

" vim-slime
"let g:slime_target = 'tmux'
let g:slime_target = 'screen'

" gitgutter
autocmd defgroup VimEnter * highlight clear SignColumn

" haskellmode-vim
let g:haddock_browser='/usr/bin/firefox'

" Go
autocmd defgroup BufWritePre *.go Fmt

" Syntastic
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
let g:ale_python_flake8_options = '--ignore=E,W,F403,F405 --select=F,C'
let g:ale_python_mypy_options = '--py2'
let g:ale_c_clang_options = '-std=c11 -Wall -Wextra -fexceptions -DNDEBUG'
set statusline+=%{ALEGetStatusLine()}
let g:ale_statusline_format = ['⨉ %d', '⚠ %d', '⬥ ok']
let g:ale_echo_msg_format = '%linter%: %s'
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

" Smarty
autocmd defgroup BufRead,BufNewFile *.tpl set filetype=smarty

" Gnuplot
autocmd defgroup BufRead,BufNewFile *.gnuplot set filetype=gnuplot

" Vala
autocmd defgroup BufRead,BufNewFile *.vala,*.vapi,*.vala.in set filetype=vala efm=%f:%l.%c-%[%^:]%#:\ %t%[%^:]%#:\ %m shiftwidth=4 softtabstop=4 expandtab smarttab

" Genie
autocmd defgroup BufRead,BufNewFile *.gs set filetype=genie shiftwidth=4 softtabstop=4 expandtab smarttab

"" YouCompleteMe
"let g:ycm_enable_diagnostic_signs = 0
"let g:ycm_global_ycm_extra_conf = '/usr/share/vim/vimfiles/third_party/ycmd/examples/.ycm_extra_conf.py'
"let g:ycm_confirm_extra_conf = 0
"let g:ycm_autoclose_preview_window_after_completion = 1
"let b:ycm_largefile = 1
"let g:ycm_add_preview_to_completeopt = 0

" neocomplete
let g:neocomplete#enable_at_startup = 1
" enable omni completion.
autocmd defgroup FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd defgroup FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd defgroup FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd defgroup FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd defgroup FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" VUE
autocmd defgroup BufRead,BufNewFile *.vue set filetype=xml

" airline
let g:airline_theme = 'solarized'
let g:airline_solarized_bg = 'dark'
let g:airline_powerline_fonts = 1
" add the buffer number next to the file name
if exists('+autochdir') && &autochdir == 1
	let g:airline_section_c = airline#section#create(['%<', 'path', ' ', 'readonly', '%<', 'b%n'])
else
	let g:airline_section_c = airline#section#create(['%<', 'file', ' ', 'readonly', '%<', 'b%n'])
endif
" remove unused modes
let g:airline_enable_fugitive=0
let g:airline_enable_syntastic=0
" make Esc happen without waiting for timeoutlen
if ! has('gui_running')
  set ttimeoutlen=10
  augroup FastEscape
    autocmd!
    au InsertEnter * set timeoutlen=0
    au InsertLeave * set timeoutlen=1000
  augroup END
endif

" HTML indentation - https://www.reddit.com/r/vim/comments/7h2zx4/help_with_html_indentation/dqnp1jp/
let g:html_indent_script1 = 'inc'
let g:html_indent_style1 = 'inc'
let g:html_indent_inctags = 'html,body,head,tbody,p,li,dd,dt,h1,h2,h3,h4,h5,h6,blockquote,section'

" some Python code using tabs
autocmd defgroup FileType python call s:PythonTabConfigure()
function s:PythonTabConfigure()
	let l:dirs = [ '/CODE/00_github/portage/' ]
	let l:path = expand('%:p')
	for l:d in l:dirs
		if l:path =~ l:d
			setlocal noexpandtab
			setlocal tabstop=4
			break
		endif
	endfor
endfunction

