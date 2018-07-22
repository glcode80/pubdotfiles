" vimrc - Mapping tipps
" ***************
"
" map -> mode before it: nmap, imap, vmap (normal, insert, visual)
" noremap -> mode before it -> only use normal commands (don't use commands
" mapped before)

set nocompatible              " required
filetype off                  " required

" Install Vundle: git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
"									
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" Add all your plugins here (note older versions of Vundle used Bundle instead of Plugin)
Plugin 'tmhedberg/SimpylFold'
Plugin 'vim-scripts/indentpython.vim'
" for youcompleteme -> follow detailed install instructions online!
" Bundle 'Valloric/YouCompleteMe'
Plugin 'scrooloose/syntastic'
Plugin 'nvie/vim-flake8'
Plugin 'scrooloose/nerdtree'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'scrooloose/nerdcommenter'
" Plugin 'vim-scripts/dbext.vim'
Plugin 'glcode80/dbext'
" Tagbar install ctags: sudo apt install exuberant-ctags
" Tagbar toggle: TagbarToggle
Plugin 'majutsushi/tagbar'
Plugin 'easymotion/vim-easymotion'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
" cs"' = change, ds" = delete
" yss" = full line, ysiw" = one word, ys2w" = two words, ...
" <b> = tag -> remove with cst"
" visual, then S<b> to add around top/bottom
" ) = no space ( = space
Plugin 'tpope/vim-repeat'

Bundle 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}


" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required


" Flagging unnecesary whitespace
" au BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

" set leader key to space instead of backslash
" now you can define map <leader>x command
let mapleader = " "

" Customize auto complete
" let g:ycm_filetype_blacklist = {'sql':1}
" map <leader>g  :YcmCompleter GoToDefinitionElseDeclaration<CR>
" let g:ycm_autoclose_preview_window_after_completion=1
" let g:ycm_key_list_select_completion = ['<TAB>']
" inoremap <Down> <C-R>=pumvisible() ? "\<lt>C-y>\<lt>Down>" : "\<lt>Down>"<CR>
" let g:ycm_key_list_previous_completion = ['<S-TAB>']
" inoremap <Up> <C-R>=pumvisible() ? "\<lt>C-y>\<lt>Up>" : "\<lt>Up>"<CR>
" let g:ycm_key_list_stop_completion = ['<C-y>']
" let g:ycm_key_invoke_completion = '<C-Space>'

" customize easymotion
" let g:EasyMotion_do_mapping = 0 " Disable default mappings
hi link EasyMotionTarget Statement
hi link EasyMotionTarget2First Statement
hi link EasyMotionTarget2Second Statement
hi link EasyMotionShade Comment
let g:EasyMotion_keys='hkluzopnmqwertxcvbasdgjf'
nmap <leader> <Plug>(easymotion-prefix)
let g:EasyMotion_smartcase = 1

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


colorscheme desert

" sane text files
set fileformat=unix
set encoding=utf-8

" always use system clipboard
set clipboard=unnamedplus

" sane editing
set tabstop=4
set shiftwidth=2
set softtabstop=2

" set all typed tabs with spaces "
set expandtab

"set background=dark
set background=light

" fix visual selection background color
" see all options: so $VIMRUNTIME/syntax/hitest.vim
" https://jonasjacek.github.io/colors/
" ctermfg= ctermbg= cterm=bold
hi Visual ctermbg=120
hi Comment ctermfg=246
hi LineNr ctermfg=249
hi SpecialKey ctermfg=Blue
" things like for / in in Python
hi Statement ctermfg=Blue cterm=bold
" things in brackets in python
hi Constant ctermfg=28  "28 /172
hi Directory ctermbg=123
" things like print etc in python
hi Identifier ctermfg=4 " cterm=bold
" things like Visual/identiier, count(*) in sql etc
hi Type ctermfg=Blue  " cterm=bold
" things like system variables etc / where in sql
hi Special ctermfg=4  " 4 cterm=bold
" others
hi Question ctermfg=172 "172
" import / from ... in Pyhton
hi PreProc ctermfg=Blue
" others
hi Search ctermfg=White ctermbg=63
" hi StatusLine ctermbg=DarkGrey
" hi StatusLineNC ctermbg=DarkGrey
" hi VertSplit ctermbg=DarkGrey
hi DiffAdd ctermfg=White
hi DiffChange ctermfg=White
hi DiffDelete ctermbg=Grey
hi IncSearch ctermfg=White

" colors for gvim
hi Normal guifg=Black guibg=White
hi Nontext guifg=Black guibg=White

" always have nerdtree open on all tabs by default
" Command to Toogle :NERDTreeTabsToggle
:let g:nerdtree_tabs_open_on_console_startup = 0

" NerdCommenter - always add space after comment sign
let NERDSpaceDelims=1

" LATER - neeed for syntastic plugin "
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}p<p<
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" dbext connection profiles
"NEW: saved in dbextprofiles.vim -> import here!
source ~/.dbextprofiles.vim

"to make sure to always prompt limit:
map <leader>st <leader>sT 

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

" MAP FUNCTION KEYS

" map <F2> :vsp $MYVIMRC<CR> " edit vimrc
map <F2> :vsp ~/.vimrc<CR> 
" reload vimrc with leader f2
map <leader><F2> :so ~/.vimrc<CR> 
map <F3> :sp ~/cmd_vim.sql<CR>
map <F4> :sp ~/cmd_linux.sql<CR>
" omni completion while in sql
imap <F6> <c-x><c-o>
" map to move to new tab
nmap <F7> <C-w>T
nmap <F8> :NERDTreeTabsToggle<CR>
nmap <leader><F8> :TagbarToggle<CR> 
" map F9 to start Python script / leader-F9 to get output in window
nnoremap <F9> :w<cr>:exec '!python3' shellescape(@%, 1)<cr>
vnoremap <F9> :w<cr>:exec '!python3' shellescape(@%, 1)<cr>
nnoremap <silent> <leader><F9> :call SaveAndExecutePythonBuffer()<CR>
vnoremap <silent> <leader><F9> :<C-u>call SaveAndExecutePythonBuffer()<CR>
" map F10 to execute current line in shell!
nmap <F10> :exec '!'.getline('.')
map <F12> :q<CR>
map <leader><F12> :qa<CR>

"nmap <silent> <leader>/ :nohls<CR> " disable highlight until next time opened
nnoremap <esc><esc> :silent! nohls<cr>

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
:command! ValuesSql :normal f a<CR><ESC>kywEi=VALUES(<ESC>pa)<ESC>j^
nnoremap <leader>sv :ValuesSql<CR>

command! Inspython :normal i#!/usr/bin/env python3<CR><ESC>
command! Inshtml :normal i<!doctype html><head><meta charset="utf-8"><title></title></head><body><CR></body></html><CR><ESC>
command! JSON %!python -m json.tool

function! CommentHeader()
    let a:hash_line = '#' . repeat('=', 79)
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

"Map to quickly copy/paste via mouse (insert mode) -> do this +i
nmap <leader>i :NERDTreeClose<cr>:set invnumber<cr>

"** Fugitive mappings
nnoremap <leader>gp :Gpull<cr>
"Gstatus -> - to add/remove, cc to commit, o for open
nnoremap <leader>gs :Gstatus<cr>
"Gwrite = add current file to list to be commited (no need to add in gstatus)
nnoremap <leader>gw :Gwrite<cr>
"Gcommit -> wq to execute
nnoremap <leader>gc :Gcommit<cr>
nnoremap <leader>gP :Gpush origin master<cr>
"Gdiff -> :diffput / :diffget to adjust /:diffupdate
nnoremap <leader>gd :Gdiff<cr>
"Gread = back to last version in repo
nnoremap <leader>gr :Gread<cr>
" Gblame -> open with o
nnoremap <leader>gb :Gblame<cr>
nnoremap <leader>gB :Gbrowse<cr>
" nnoremap <leader>gm :Gremove<cr>



function! SaveAndExecutePythonBuffer()
    " save and reload current file
    silent execute "update | edit"
    " get file path of current file
    let s:current_buffer_file_path = expand("%")
    let s:output_buffer_name = "Python"
    let s:output_buffer_filetype = "output"
    " reuse existing buffer window if it exists otherwise create a new one
    if !exists("s:buf_nr") || !bufexists(s:buf_nr)
        silent execute 'botright new ' . s:output_buffer_name
        let s:buf_nr = bufnr('%')
    elseif bufwinnr(s:buf_nr) == -1
        silent execute 'botright new'
        silent execute s:buf_nr . 'buffer'
    elseif bufwinnr(s:buf_nr) != bufwinnr('%')
        silent execute bufwinnr(s:buf_nr) . 'wincmd w'
    endif
    silent execute "setlocal filetype=" . s:output_buffer_filetype
    setlocal bufhidden=delete
    setlocal buftype=nofile
    setlocal noswapfile
    setlocal nobuflisted
    setlocal winfixheight
    " setlocal cursorline " make it easy to distinguish
    " setlocal nonumber
    setlocal number
    setlocal norelativenumber
    setlocal showbreak=""
    " clear the buffer
    setlocal noreadonly
    setlocal modifiable
    %delete _
    " add the console output
    silent execute ".!python3 " . shellescape(s:current_buffer_file_path, 1)

    " resize window to content length
    " Note: This is annoying because if you print a lot of lines then your code buffer is forced to a height of one line every time you run this function.
    "       However without this line the buffer starts off as a default size and if you resize the buffer then it keeps that custom size after repeated runs of this function.
    "       But if you close the output buffer then it returns to using the default size when its recreated
    "execute 'resize' . line('$')

    " make the buffer non modifiable
    " setlocal readonly
    " setlocal nomodifiable
endfunction

