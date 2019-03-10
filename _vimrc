" VIMRC for windows
" => put it into C:\Users\USER folder
" Plugins: download from github and put into plugin directory
" ***************
"
set nocompatible              " required
filetype off                  " required

" set layout for gvim
set lines=60 columns=140
set guifont=DejaVu_Sans_Mono_for_Powerline:h9:cDEFAULT
set linespace=0
" fix enter not working
set bs=2

" set leader key to space instead of backslash
" now you can define map <leader>x command
let mapleader = " "
autocmd BufReadPost * tab ball

" show powerline on single buffer
set laststatus=2

"make your code look pretty
let python_highlight_all=1
syntax on


filetype indent on
set autoindent
set number
syntax on
set ignorecase
set hlsearch
set linebreak
set incsearch

colorscheme desert

" sane text files
set fileformat=unix
set encoding=utf-8

" always use system clipboard
" set clipboard=unnamedplus
" set clipboard=
set clipboard=unnamed
" map y "+y 


" sane editing
set tabstop=4
set shiftwidth=4
set softtabstop=4

" set all typed tabs with spaces "
set expandtab

"set background=dark
set background=light

" fix visual selection background color
" see all options: so $VIMRUNTIME/syntax/hitest.vim
" https://jonasjacek.github.io/colors/
" ctermfg= ctermbg= cterm=bold
hi Visual ctermbg=120 guibg=Blue
hi Comment ctermfg=246 guifg=Grey58
hi LineNr ctermfg=249 guifg=Grey70
hi SpecialKey ctermfg=Blue guifg=Blue
" things like for / in in Python
hi Statement ctermfg=Blue cterm=bold guifg=Blue gui=bold
" things in brackets in python
hi Constant ctermfg=28  guifg=Green4
hi Directory ctermbg=123 guibg=DarkSlateGray1
" things like print etc in python
hi Identifier ctermfg=4 guifg=Blue
" things like Visual/identiier, count(*) in sql etc
hi Type ctermfg=Blue guifg=Blue gui=none
" things like system variables etc / where in sql
hi Special ctermfg=4  guifg=Blue
" others
hi Question ctermfg=172 guifg = Orange3
" import / from ... in Pyhton
hi PreProc ctermfg=Blue guifg=Blue
" others
hi Search ctermfg=White ctermbg=63 guifg=White guibg=RoyalBlue1
" hi StatusLine ctermbg=DarkGrey
" hi StatusLineNC ctermbg=DarkGrey
" hi VertSplit ctermbg=DarkGrey

hi DiffAdd    ctermfg=Black ctermbg=40 guifg=Black guibg=Green3
hi DiffChange ctermfg=240 ctermbg=51 guifg=Grey35 guibg=Cyan1
hi DiffDelete cterm=none ctermfg=240 ctermbg=51 guifg=Grey35 guibg=Cyan1
hi DiffText   cterm=bold ctermfg=White ctermbg=Blue guifg=White guibg=Blue

" hi DiffAdd ctermfg=White
" hi DiffChange ctermfg=White
" hi DiffDelete ctermbg=Grey

hi IncSearch  ctermfg=White guifg=White

" Syntastic error colors
" hi SpellBad cterm=bold ctermbg=172 ctermfg=Black
" hi SpellCap ctermfg=Yellow ctermbg=Blue

" colors for gvim - optino for bold/normal: gui=normal/bold cterm=normal/bold
hi Normal guifg=Black guibg=White
hi Nontext guifg=Black guibg=White
hi Cursor         guifg=White           guibg=Grey50


" always have nerdtree open on all tabs by default
" Command to Toogle :NERDTreeTabsToggle
:let g:nerdtree_tabs_open_on_console_startup = 0

" NerdCommenter - always add space after comment sign
let NERDSpaceDelims=1

" NerdCommenter - change default character from /* * to #
let g:NERDCustomDelimiters = { '': { 'left': '#'} }

" LATER - neeed for syntastic plugin "
" set statusline+=%#warningmsg#
" set statusline+=%{SyntasticStatuslineFlag()}p<p<
" set statusline+=%*

" let g:syntastic_always_populate_loc_list = 1
" let g:syntastic_auto_loc_list = 1
" let g:syntastic_check_on_open = 1
" let g:syntastic_check_on_wq = 0
" let g:syntastic_loc_list_height=5
"
" let g:syntastic_python_checkers = ['pylint']
" let g:syntastic_python_checkers = ['flake8']

" let g:syntastic_php_checkers = ['php']
" let g:syntastic_php_checkers = ['php', 'phpcs']
" let g:syntastic_php_checkers = ['php', 'phpcs', 'phpmd']
" let g:syntastic_php_phpcs_args = '--standard=psr2'
" let g:syntastic_php_phpcs_args = '--standard=~/.phpcsruleset.xml'
" How to run it on command line to auto-fix:
" phpcbs xxx.php -s --standard=~/.phpcsruleset.xml
" phpcbf xxx.php -s --standard=~/.phpcsruleset.xml
" let g:syntastic_php_phpmd_post_args = 'cleancode,codesize,controversial,design,unusedcode'
" let g:syntastic_php_phpmd_post_args = '~/.phpmdruleset.xml'

" let g:ctrlp_show_hidden =1

" Update time for vim-gitgutter
" set updatetime=100

" to make sure to always prompt limit:
" map <leader>st <leader>sT 

" open splits always on the right/bottom
set splitright
set splitbelow

" map ctrl-arrowkey to switch windows with multiple windows
nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l

nmap <silent> [D <C-w>h
nmap <silent> [B <C-w>j
nmap <silent> [A <C-w>k
nmap <silent> [C <C-w>l

nmap <silent> <C-Left> <C-w>h
nmap <silent> <C-Down> <C-w>j
nmap <silent> <C-Up> <C-w>k
nmap <silent> <C-Right> <C-w>l

" map for loc-list -> move to previous / next error
" nmap <silent> <leader><Up> :lprevious<CR>
" nmap <silent> <leader><Down> :lnext<CR>

" set timeout limit for ESC and escape sequences
set timeoutlen=1000 ttimeoutlen=10

" map Tab / Shift-Tab to indent / undindent selected lines
vmap <TAB> >gv
vmap <S-TAB> <gv

" map ctrl-t to change tab
nmap <C-t> :tabn<CR>

" enable mouse for scrolling, but not for visual selection?
" to copy/paste move to insert mode first! makes sense!
set mouse=nv

" map ö to : and ä to ^ (beginning of line) / other things
nmap ö :
nmap ä ^
nnoremap § ~h " map toggle lower/upper case
vnoremap § ~
nmap <leader><enter> O<esc> " to add a new line and exit insert - no need
" map - to ` for going to exact location of marks
" ma = define, 'a = beginning of line -a = exact mark
nmap - `

" map scrolling buffer up/down
nnoremap <silent> <S-Up> <C-y>
nnoremap <silent> <S-Down> <C-e>

" leave cursor at end of yanked text
" vmap y y`]
vmap y ygv<Esc>

" MAP FUNCTION KEYS

map <F2> :vsp $MYVIMRC<CR> " edit vimrc
" map <F2> :vsp ~/.vimrc<CR> 
" reload vimrc with leader f2
map <leader><F2> :so $HOME/_vimrc<CR> 
" omni completion while in sql
imap <F6> <c-x><c-o>
" map to move to new tab
nmap <F7> <C-w>T
map <F12> :q<CR>
map <leader><F12> :qa<CR>

"nmap <silent> <leader>/ :nohls<CR> " disable highlight until next time opened
" nnoremap <esc><esc> :silent! nohls<cr>
nnoremap <silent> <esc><esc> :let @/=""<cr>

"fix esc arrow to enter characters
nnoremap <silent> <ESC><ESC>OA k
nnoremap <silent> <ESC><ESC>OB j
nnoremap <silent> <ESC><ESC>OC l
nnoremap <silent> <ESC><ESC>OD h

" fix capital W to get error after :
:command! WQ wq
:command! Wq wq
:command! W w
:command! Q q

" process to get xxxx=values(xxx) in mysql for update on duplicate key
" 1) leader slc = list column -> paste
" 2) each item leader sv to convert to item=values(item)
:command! ValuesSql :normal f r<CR><ESC>kywEi=VALUES(<ESC>pa)<ESC>j^
nnoremap <leader>sv :ValuesSql<CR>

function! CommentHeader()
    let a:hash_line = '# ' . repeat('=', 79)
    normal! 0i# 
    normal! k
    :put =a:hash_line
    normal! j
    :put =a:hash_line
    normal! k
endfunction

function! UncommentHeader()
    normal! 0xxjddkkdd
endfunction

map <leader>4 :call CommentHeader()<CR>
map <leader>5 :call UncommentHeader()<CR>

