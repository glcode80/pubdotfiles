" vimrc - Mapping tipps
" ***************
"
" Check diffs and update vimrc
" cd /home/moon/pubdotfiles/ && git pull && cd /home/moon/
" vimdiff /home/moon/.vimrc /home/moon/pubdotfiles/.vimrc
" cp /home/moon/pubdotfiles/.vimrc /home/moon/.vimrc
"
" map -> mode before it: nmap, imap, vmap (normal, insert, visual)
" noremap -> mode before it -> only use normal commands (don't use commands
" mapped before)

set nocompatible              " required
filetype off                  " required

" Install Vundle: git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
"									
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
" Plugin 'gmarik/Vundle.vim'
Plugin 'VundleVim/Vundle.vim' 
" Plugin 'glcode80/Vundle.vim'

" Add all your plugins here (note older versions of Vundle used Bundle instead of Plugin)
Plugin 'tmhedberg/SimpylFold'
Plugin 'vim-scripts/indentpython.vim'
" for youcompleteme -> follow detailed install instructions in install file
Bundle 'Valloric/YouCompleteMe'
Plugin 'scrooloose/syntastic'
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
Plugin 'tpope/vim-repeat'
Plugin 'kien/ctrlp.vim'
" Bundle 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}
Plugin 'itchyny/lightline.vim'


" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" Lightline - count number of chars / lines selected
function! LightlineSelectedChars()
    if mode() ==# 'v' || mode() ==# 'V' || mode() ==# "\<C-v>"
        if line("v") == line(".")
            let l:char_count = abs(line("v") - line(".")) * col("$") + abs(col("v") - col(".")) + 1
            return printf('%d chars', l:char_count)
        else
            let l:line_count = abs(line("v") - line(".")) + 1
            return printf('%d lines', l:line_count)
        endif
    else
        return ''
    endif
endfunction

" Lightline Function to get the name of the active virtual environment
function! LightlineVirtualEnv()
  let l:venv = $VIRTUAL_ENV
  return l:venv != '' ? fnamemodify(l:venv, ':t') : ''
endfunction

" Lightline - Add path, if not in same directory
function! LightlineFilename()
  return expand('%:F') !=# '' ? expand('%:F') : '[No Name]'
endfunction

" Lightline Config
" attention: 'right': goes from right to left!
" get settings with :h g:lightline.component
let g:lightline = {
      \ 'colorscheme': 'powerline',
      \ 'separator': { 'left': '', 'right': '' },
      \ 'subseparator': { 'left': '', 'right': '' },
      \ 'component_function': {
      \   'filename': 'LightlineFilename',
      \   'charcount': 'LightlineSelectedChars',
      \   'virtualenv': 'LightlineVirtualEnv',
      \ },
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'readonly', 'filename', 'modified' ],
      \             [ 'charcount' ],
      \             ],
      \   'right': [ [ 'lineinfo' ],
      \              [ 'percent' ],
      \              [ 'fileformat', 'fileencoding', 'filetype' ],
      \              [ 'virtualenv' ],
      \              ]
      \ },
      \ }


" Flagging unnecesary whitespace
" au BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

" set leader key to space instead of backslash
" now you can define map <leader>x command
let mapleader = " "

" show powerline on single buffer
set laststatus=2

" Customize auto complete
" ***=>  USE CTRL-SPACE TO TRIGGER COMPLETION <= ***
" *** Auto triggered only with . -> etc
" let g:ycm_filetype_blacklist = {'sql':1}
map <leader>g  :YcmCompleter GoToDefinitionElseDeclaration<CR>
let g:ycm_autoclose_preview_window_after_completion=1
let g:ycm_key_list_select_completion = ['<TAB>']
inoremap <Down> <C-R>=pumvisible() ? "\<lt>C-y>\<lt>Down>" : "\<lt>Down>"<CR>
let g:ycm_key_list_previous_completion = ['<S-TAB>']
inoremap <Up> <C-R>=pumvisible() ? "\<lt>C-y>\<lt>Up>" : "\<lt>Up>"<CR>
let g:ycm_key_list_stop_completion = ['<C-y>']
let g:ycm_key_invoke_completion = '<C-Space>'

" UltiSnips Trigger C-j / C-k -> toggle tab/s-tab like normal
" let g:UltiSnipsExpandTrigger="<C-j>"
"
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
set incsearch

" vim 9 default colorscheme
" colorscheme desert
" colorscheme default

" all desert colorscheme settings hardcoded directly here
hi Normal	guifg=White guibg=grey20
hi Cursor	guibg=indianred guifg=khaki
hi VertSplit	guibg=#c2bfa5 guifg=grey50 gui=none
hi Folded	guibg=grey30 guifg=gold
hi FoldColumn	guibg=grey30 guifg=tan
hi IncSearch	guifg=slategrey guibg=khaki
hi ModeMsg	guifg=goldenrod
hi MoreMsg	guifg=SeaGreen
hi NonText	guifg=LightBlue guibg=grey30
hi Question	guifg=springgreen
hi Search	guibg=grey30 guifg=#dfffdf
hi SpecialKey	guifg=yellowgreen
hi StatusLine	guibg=#c2bfa5 guifg=black gui=none
hi StatusLineNC	guibg=#c2bfa5 guifg=grey50 gui=none
hi Title	guifg=indianred
hi Visual	gui=none guifg=khaki guibg=olivedrab
hi WarningMsg	guifg=salmon
hi MatchParen guibg=grey30 guifg=#dfffdf
hi Comment	guifg=SkyBlue
hi Constant	guifg=#ffa0a0
hi Identifier	guifg=palegreen
hi Statement	guifg=khaki
hi PreProc	guifg=indianred
hi Type		guifg=darkkhaki
hi Special	guifg=navajowhite
hi Ignore	guifg=grey40
hi Todo		guifg=orangered guibg=yellow2
hi SpecialKey	ctermfg=darkgreen
hi NonText	cterm=bold ctermfg=darkblue
hi Directory	ctermfg=darkcyan
hi ErrorMsg	cterm=bold ctermfg=7 ctermbg=1
hi IncSearch	cterm=NONE ctermfg=yellow ctermbg=green
hi Search	cterm=NONE ctermfg=grey ctermbg=blue
hi MoreMsg	ctermfg=darkgreen
hi ModeMsg	cterm=NONE ctermfg=brown
hi LineNr	ctermfg=3
hi Question	ctermfg=green
hi StatusLine	cterm=bold,reverse
hi StatusLineNC cterm=reverse
hi VertSplit	cterm=reverse
hi Title	ctermfg=5
hi Visual	cterm=reverse
hi VisualNOS	cterm=bold,underline
hi WarningMsg	ctermfg=1
hi WildMenu	ctermfg=0 ctermbg=3
hi Folded	ctermfg=darkgrey ctermbg=NONE
hi FoldColumn	ctermfg=darkgrey ctermbg=NONE
hi DiffAdd	ctermbg=4
hi DiffChange	ctermbg=5
hi DiffDelete	cterm=bold ctermfg=4 ctermbg=6
hi DiffText	cterm=bold ctermbg=1
hi Comment	ctermfg=darkcyan
hi Constant	ctermfg=brown
hi Special	ctermfg=5
hi Identifier	ctermfg=6
hi Statement	ctermfg=3
hi PreProc	ctermfg=5
hi Todo		ctermfg=red ctermbg=NONE
hi Type		ctermfg=2
hi Underlined	cterm=underline ctermfg=5
hi Ignore	cterm=bold ctermfg=7
hi Ignore	ctermfg=darkgrey
hi Error	cterm=bold ctermfg=7 ctermbg=1

" sane text files
set fileformat=unix
set encoding=utf-8

" always use system clipboard
set clipboard=unnamedplus

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
hi Constant ctermfg=28  guifg=Green4 "28 /172
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

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_loc_list_height=5
"
" let g:syntastic_python_checkers = ['pylint']
let g:syntastic_python_checkers = ['flake8']
let g:syntastic_python_flake8_args='--config=/home/moon/.flake8'

let g:syntastic_php_checkers = ['php']
" let g:syntastic_php_checkers = ['php', 'phpcs']
" let g:syntastic_php_checkers = ['php', 'phpcs', 'phpmd']
" let g:syntastic_php_phpcs_args = '--standard=psr2'
let g:syntastic_php_phpcs_args = '--standard=~/.phpcsruleset.xml'
" How to run it on command line to auto-fix:
" phpcbs xxx.php -s --standard=~/.phpcsruleset.xml
" phpcbf xxx.php -s --standard=~/.phpcsruleset.xml
" let g:syntastic_php_phpmd_post_args = 'cleancode,codesize,controversial,design,unusedcode'
let g:syntastic_php_phpmd_post_args = '~/.phpmdruleset.xml'

" let g:ctrlp_show_hidden =1

" Update time for vim-gitgutter
" set updatetime=100

" dbext connection profiles
source ~/.dbextprofiles.vim

" to make sure to always prompt limit:
" map <leader>st <leader>sT

" open splits always on the right/bottom
set splitright
set splitbelow

" map ctrl-arrowkey to switch windows with multiple windows
" -> following ones not mapped anymore (newly mapped to scrolling)
" nmap <C-h> <C-w>h
" nmap <C-j> <C-w>j
" nmap <C-k> <C-w>k
" nmap <C-l> <C-w>l

nmap <silent> [D <C-w>h
nmap <silent> [B <C-w>j
nmap <silent> [A <C-w>k
nmap <silent> [C <C-w>l

nnoremap <silent> <ESC>[D  <C-w>h
nnoremap <silent> <ESC>[B  <C-w>j
nnoremap <silent> <ESC>[A  <C-w>k
nnoremap <silent> <ESC>[C  <C-w>l

nmap <silent> <C-Left> <C-w>h
nmap <silent> <C-Down> <C-w>j
nmap <silent> <C-Up> <C-w>k
nmap <silent> <C-Right> <C-w>l

" map for loc-list -> move to previous / next error
nmap <silent> <leader><Up> :lprevious<CR>
nmap <silent> <leader><Down> :lnext<CR>

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
map <C-j> 2<C-e>
map <C-k> 2<C-y>
map <C-h> 5<C-e>
map <C-l> 5<C-y>

" leave cursor at end of yanked text
" vmap y y`]
vmap y ygv<Esc>

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
" leader-F10 -> run in terminal mode (return result to new buffer)
" visual mode (can select multiple lines) - run in terminal mode
nnoremap <F10> :exec '!'.getline('.')
nnoremap <leader><F10> :w<cr>v :terminal bash<cr>
vnoremap <F10> <ESC>:w<cr>gv :terminal bash<cr>
vnoremap <leader><F10> <ESC>:w<cr>gv :terminal bash<cr>
" map F11 to run complete script in bash
" leader-F11 -> run in termainl mode (return result to new buffer)
nnoremap <F11> :w<cr>:exec '!bash' shellescape(@%, 1)<cr>
nnoremap <leader><F11> :w<cr>ggVG :terminal bash<cr>
vnoremap <F11> <ESC>:w<cr>:exec '!bash' shellescape(@%, 1)<cr>
vnoremap <leader><F11> <ESC>:w<cr>ggVG :terminal bash<cr>

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
"
" map ZZ to zz -> do not close automatically by mistake
nmap ZZ zz
vmap ZZ zz

" write file with root ownership when not logged in as root
command! Wsudo :execute ':silent w !sudo tee % > /dev/null' | :edit!

" process to get xxxx=values(xxx) in mysql for update on duplicate key
" 1) leader slc = list column -> paste
" 2) each item leader sv to convert to item=values(item)
:command! ValuesSql :normal f r<CR><ESC>kywEi=VALUES(<ESC>pa)<ESC>j^
nnoremap <leader>sv :ValuesSql<CR>

" escape word with apostroph around word and comma (=mh) at end and join all lines (=mhj)
:command! EscapeWord :execute "%normal yss'A" | %s/'$/',/ | execute "normal <ESC><ESC>"
:command! EscapeWordJoin :execute "%normal yss'A" | %s/\n/,/ | execute "normal $x<ESC><ESC>"
nnoremap <leader>mh :EscapeWord<CR>
nnoremap <leader>mhj :EscapeWordJoin<CR>

" URL decode all strings and add newlines to make it easy to read
:command! UrlDecode :execute "%s/^http/\rhttp/ge" | %s/?/\r?\r/ge | %s/&/\r&\r/ge | %s/=/=\r  /ge | %s/%\(\x\x\)/\=iconv(nr2char('0x' ..  submatch(1)), 'utf-8', 'latin1')/ge | %s/,/,\r  /ge | execute "normal <ESC><ESC>"
nnoremap <leader>mu :UrlDecode<CR><CR>gg

command! Insbash :normal i#!/bin/bash<CR><ESC>

" command! Inspython :normal i#!/usr/bin/env python3<CR><ESC>
" command! Inspython :execute "normal i#!/usr/bin/env python3\n# ".expand('%:p')."\n"<CR><ESC>
" command! Inspython :execute "normal! i#!/usr/bin/env python3\r# ".expand('%:p')."\r\<Esc>"
" command! Inspython :execute 'normal! i#!/'.expand('%:p:h').'/venv/bin/python3\r\<Esc>'

function! InsertPythonShebang()
  " Get the value of the VIRTUAL_ENV environment variable
  let l:venv = $VIRTUAL_ENV
  " Check if the virtual environment variable is empty
  if empty(l:venv)
    " If no virtual environment is active, use the default Python shebang
    call execute('normal! i#!/usr/bin/env python3' . "\n")

  else
    " If a virtual environment is active, use its Python interpreter
    let l:python_path = l:venv . '/bin/python3'
    call execute('normal! i#!' . l:python_path . "\n")
  endif
endfunction

" Create a Vim command that calls the InsertPythonShebang function
command! Inspython call InsertPythonShebang()


command! Inshtml :normal i<!doctype html><head><meta charset="utf-8"><title></title></head><body><CR></body></html><CR><ESC>
command! JSON %!python -m json.tool
command! Jsonfold set filetype=json | syntax on | set foldmethod=syntax

function! CommentHeader()
    let hash_line = '# ' . repeat('=', 79)
    normal! 0i#
    normal! k
    :put =hash_line
    normal! j
    :put =hash_line
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
nnoremap <leader>gs :Gstatus<cr>8gg
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
