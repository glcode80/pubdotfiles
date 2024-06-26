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
Plugin 'VundleVim/Vundle.vim'
" Plugin 'glcode80/Vundle.vim'
Plugin 'tmhedberg/SimpylFold'
Plugin 'vim-scripts/indentpython.vim'
" for youcompleteme -> follow detailed install instructions in install file
Bundle 'Valloric/YouCompleteMe'
Plugin 'scrooloose/syntastic'
Plugin 'scrooloose/nerdtree'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'scrooloose/nerdcommenter'
" Plugin 'vim-scripts/dbext.vim'
" Plugin 'glcode80/dbext'
Plugin 'tpope/vim-dadbod'
Plugin 'kristijanhusak/vim-dadbod-completion'
Plugin 'easymotion/vim-easymotion'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-repeat'
Plugin 'kien/ctrlp.vim'
Plugin 'glcode80/vim-colors'
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

" Use vim-dadbod-completion for SQL files -> trigger with F6 / <C-x><C-o>
autocmd FileType sql setlocal omnifunc=vim_dadbod_completion#omni
inoremap <F6> <C-x><C-o>

" customize easymotion
" let g:EasyMotion_do_mapping = 0 " Disable default mappings
" hi link EasyMotionTarget Statement
" hi link EasyMotionTarget2First Statement
" hi link EasyMotionTarget2Second Statement
" hi link EasyMotionShade Comment
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

" Enalbe termguicolors by default (if issues: disable)
set termguicolors

" *** Color profiles - general settings ***
let g:one_allow_italics = 1
let g:jellybeans_use_term_italics = 1
let g:gruvbox_italic=1
let g:gruvbox_contrast_dark="medium"
let g:gruvbox_contrast_light="medium"
" let g:gruvbox_contrast_dark="soft"
" let g:gruvbox_contrast_light="soft"
" let g:gruvbox_contrast_dark="hard"
" let g:gruvbox_contrast_light="hard"
"
" *** Color profiles - live selection to fix profile as first ***
set background=light
" colorscheme mhputty
colorscheme one
" colorscheme solarized8
" colorscheme gruvbox

" set background=dark
" colorscheme one
" colorscheme jellybeans
" colorscheme molokai
" colorscheme gruvbox
" colorscheme spacecamp

" *** Set Lightline to same color profile (default: powerline) ***
let g:lightline = { 'colorscheme': 'one' }
" let g:lightline = { 'colorscheme': 'jellybeans' }
" let g:lightline = { 'colorscheme': 'molokai' }
" let g:lightline = { 'colorscheme': 'solarized' }
" let g:lightline = { 'colorscheme': 'powerline' }

" *** Colorscheme rotation among vim-colors schemes -> F5 rotates between them ***
" Define the colorschemes and corresponding background settings
let g:colorschemes = [
    \ {'background': 'light', 'colorscheme': 'one', 'colorscheme_lightline': 'one'},
    \ {'background': 'dark', 'colorscheme': 'one', 'colorscheme_lightline': 'powerline'},
    \ {'background': 'light', 'colorscheme': 'solarized8', 'colorscheme_lightline': 'solarized'},
    \ {'background': 'light', 'colorscheme': 'gruvbox', 'colorscheme_lightline': 'powerline'},
    \ {'background': 'dark', 'colorscheme': 'gruvbox', 'colorscheme_lightline': 'gruvbox'},
    \ {'background': 'dark', 'colorscheme': 'jellybeans', 'colorscheme_lightline': 'jellybeans'},
    \ {'background': 'dark', 'colorscheme': 'molokai', 'colorscheme_lightline': 'molokai'},
    \ {'background': 'dark', 'colorscheme': 'spacecamp', 'colorscheme_lightline': 'powerline'},
    \ ]

" Function to get the current colorscheme and background
function! GetCurrentSettings()
    let current_background = &background
    let current_colorscheme = execute('colorscheme')
    return {'background': current_background, 'colorscheme': substitute(current_colorscheme, '\n', '', 'g')}
endfunction

" Function to rotate the colorscheme
function! RotateColorscheme()
    " Get the current settings
    let current_settings = GetCurrentSettings()

    " Determine the current index in the colorscheme list
    let current_index = -1
    for i in range(len(g:colorschemes))
        if g:colorschemes[i].background == current_settings.background &&
                    \ g:colorschemes[i].colorscheme == current_settings.colorscheme
            let current_index = i
            break
        endif
    endfor

    " Calculate the index for the next colorscheme
    let next_index = (current_index + 1) % len(g:colorschemes)

    " Set the background and colorscheme
    let next_colorscheme = g:colorschemes[next_index]
    execute 'set background=' . next_colorscheme.background
    execute 'colorscheme ' . next_colorscheme.colorscheme
    
    " Set the lightline colorscheme
    let g:lightline = { 'colorscheme': next_colorscheme.colorscheme_lightline }
   
    " Trigger lightline update
    call lightline#init()
    call lightline#update()
    
    " Echo the selected colorscheme
    echom 'Colorscheme: ' . next_colorscheme.colorscheme . ' / ' . next_colorscheme.background
    " Echo the selected colorscheme
    redraw | echomsg 'Colorscheme: ' . next_colorscheme.colorscheme . ' / ' . next_colorscheme.background

endfunction

" Map the F5 key to the RotateColorscheme function
nnoremap <silent> <F5> :call RotateColorscheme()<CR>

" always have nerdtree open on all tabs by default
" Command to Toogle :NERDTreeTabsToggle
:let g:nerdtree_tabs_open_on_console_startup = 0

" NerdCommenter - always add space after comment sign
let NERDSpaceDelims=1

" NerdCommenter - change default character from /* * to #
let g:NERDCustomDelimiters = { '': { 'left': '#'} }

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
" let g:syntastic_php_phpcs_args = '--standard=~/.phpcsruleset.xml'
" How to run it on command line to auto-fix:
" phpcbs xxx.php -s --standard=~/.phpcsruleset.xml
" phpcbf xxx.php -s --standard=~/.phpcsruleset.xml
" let g:syntastic_php_phpmd_post_args = 'cleancode,codesize,controversial,design,unusedcode'
" let g:syntastic_php_phpmd_post_args = '~/.phpmdruleset.xml'

let g:ctrlp_show_hidden =1

" ignore venv directory / other custom directories
let g:ctrlp_custom_ignore = {
    \ 'dir': 'venv\|env\|\.cache\|\.vim\|\.wp-cli\|\.local\|neovim\|\.git\|__pycache__',
    \ }

" dbext connection profiles
" source ~/.dbextprofiles.vim

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

" set proper term in tmux for mouse moving lines
if exists('$TMUX')
  set ttymouse=xterm2
endif

" set proper mouse mode to work in windows terminal
set ttymouse=sgr

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
" F5 mapped to color theme rotation
" F6 mapped to omni completion while in sql
" map to move to new tab
" nmap <F7> <C-w>T
nmap <F8> :NERDTreeTabsToggle<CR>
" nmap <leader><F8> :TagbarToggle<CR>
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

" escape word with apostroph around word and comma (=mh) -> can join at end with J
function! EscapeWord(start, end)
  for i in range(a:start, a:end)
    execute i
    normal! ^i'
    normal! $A',
  endfor
endfunction
" Create a command to process the visually selected range
command! -range EscapeWordsRange call EscapeWord(<line1>, <line2>)
" Map the function to Leader-mh in visual mode
xnoremap <Leader>mh :'<,'>EscapeWordsRange<CR>

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
"Gdiff -> :diffput / :diffget to adjust /:diffupdate
nnoremap <leader>gd :Gdiff<cr>
"Gread = back to last version in repo
nnoremap <leader>gr :Gread<cr>
" Gblame -> open with o
" nnoremap <leader>gb :Gblame<cr>

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
endfunction

" ===============================================================================
" vim-dadbod functions -> execute query with ctrl-Q -> automatic limit applied
" -> can be between ; or for visual selection
" -> re-format to tsv / csv and copy (buffer unchanged) -> <leader>-csv / tsv
" simply type 'DB' to open mysql shell
" -> set connection/credentials in input file as per below
" -> can set  '-- DB: xxx' in first 10 lines of buffers to set custom connection
" ===============================================================================

augroup DadbodConfig
  autocmd!
  " Ensure the .dbout files open with a height of 30 lines, only if current height is less than 30
  autocmd BufReadPost,BufNewFile *.dbout if winheight(0) < 30 | execute 'resize 30' | endif
augroup END

" make modifiable and set cursorline when entering dadbod buffer
augroup dbout_settings
  autocmd!
  autocmd BufEnter *dbout* setlocal modifiable cursorline
augroup END


" import connection details
source ~/.vim_dadbod_profiles.vim

" Connection profiles for vim-dadbod
augroup DadbodDB
    autocmd!
    autocmd BufReadPost,BufNewFile * call s:set_dadbod_db()
augroup END

function! s:set_dadbod_db()
  " Set DB connection based on input buffer file and string in first 10
  " lines of buffer like ''-- DB: xxx'
  let l:line = getline(1, 10)
  let l:dbname = ''
  for l:current in l:line
    if l:current =~ '^-- DB:'
      let l:match = matchlist(l:current, '\v-- DB:\s*(\S+)')
      if len(l:match) > 1
        let l:dbname = l:match[1]
        break
      endif
    elseif l:current =~ '^// dbext:profile='
      let l:match = matchlist(l:current, '\v// dbext:profile=(\S+)')
      if len(l:match) > 1
        let l:dbname = substitute(l:match[1], '^=', '', '')
        break
      endif
    endif
  endfor

  if l:dbname != ''
    if has_key(g:db_buffer, l:dbname)
      let b:db = g:db_buffer[l:dbname]
      " echo "Dadbod DB set to " . b:db
    else
      " echo "Database '" . l:dbname . "' not found in g:db - using default connection"
      let b:db = g:db
    endif
  endif
endfunction

function! AddLimitToQuery(query)
    " Add 'limit x' to a query string -> by default we always limit the output results

    " Define the limit value
    let l:limit_clause = "LIMIT 1000"

    " Remove all initial whitespace and line break characters
    let l:query = substitute(a:query, '^\s*\n*', '', '')

    " Check if the string starts with SELECT or WITH
    if match(l:query, '^\c\(SELECT\|WITH\)') != -1
        " Check if any "LIMIT" is not present
        if match(a:query, '\cLIMIT') == -1
            " Check if there is a semicolon
            let l:semicolon_pos = match(a:query, ';')
            if l:semicolon_pos != -1
                " Insert the limit clause before the semicolon
                return strpart(a:query, 0, l:semicolon_pos) . "\n" . l:limit_clause . strpart(a:query, l:semicolon_pos)
            else
                " Append the limit clause to the query
                return a:query . "\n" . l:limit_clause
            endif
        endif
    endif
    return a:query
endfunction

function! SelectSqlExecute()
    " Select SQL between semicolons (or start/end of buffer)
    " Add Limit clause via special function, if not present
    " Execute via vim dadbod -> DB command

    " Save current position of cursor
    let l:initial_pos = getpos('.')

    " Go to beginning of line
    normal! 0

    " move back exactly one character (or end of previous line), only if on
    " semicolon
    if getline('.')[col('.') - 1] == ';'
        if col('.') == 1
            if line('.') > 1
                normal! k$
            endif
        else
            normal! h
        endif
    endif

    " " Search for the previous semicolon from the current cursor position
    if search(';', 'bcW') == 0
        " no semicolon found, set to beginning of the buffer -> 1,1 (first and last = 0)
        " Echo the saved position > 1= buffer, 2=line, 3=column, 4=virtual
        let l:start_pos = [0, 1, 1, 0]
    else
        " Move one word forward to be after the found character
        normal! w
        let l:start_pos = getpos('.')
    endif

    " Search for the next semicolon
    if search(';', 'W') == 0
        " No semicolon found -> go to end of buffer and save this position
        normal! G$
        let l:end_pos = getpos('.')
    else
        " Save the position of the found semicolon
        let l:end_pos = getpos('.')
    endif

    " Start visual mode and select text until the semicolon
    call setpos('.', l:start_pos)
    normal! v
    call setpos('.', l:end_pos)

    " Yank the selected text into a register (e.g., register 'a')
    silent! normal! "ay
    " Store the contents of the register 'a' in a variable 'query'
    let l:query = getreg('a')

    " Clear the register 'a' (optional)
    call setreg('a', '')

    " Process the query to add 'LIMIT xx' if necessary -> custom function
    let l:query = AddLimitToQuery(l:query)

    " Execute the SQL using Dadbod
    execute 'DB ' . l:query

    " Restore the cursor to the starting position to begin visual mode selection
    call setpos('.', l:initial_pos)

endfunction

function! ExecuteSQLUnderSelection()
    " Execute Visual selction via vim dadbod -> DB
    " Add Limit clause via special function, if not present

    " Save the current selection to a variable
    let l:selection = @"
    " Copy the selected text to the unnamed register without showing messages
    silent execute "normal! gv\"zy"
    " Get the content of the unnamed register
    let l:query = @z
    " Process the query to add 'LIMIT xx' if necessary -> custom function
    let l:query = AddLimitToQuery(l:query)
    " Execute the SQL using Dadbod
    execute 'DB ' . l:query
    " Restore the original selection
    let @" = l:selection
endfunction

" Map Ctrl-Q to the custom function in visual mode
nnoremap <silent> <C-q> :<C-U>call SelectSqlExecute()<CR>
inoremap <silent> <C-q> <Esc>:<C-U>call SelectSqlExecute()<CR>
vnoremap <silent> <C-q> :<C-U>call ExecuteSQLUnderSelection()<CR>


function! CopyToTsv()
    " Format SQL output to TSV (tabs seperated) and copy to default register

    " Ensure the buffer is modifiable
    setlocal modifiable

    " Delete the lines with the +----+ border
    silent! g/^+----/d

    " Remove the leading and trailing spaces and | character
    silent! %s/^\s*| \?//g
    silent! %s/ \?|\s*$//g

    " Replace the remaining | with tabs
    silent! %s/ \?|\s\?/\t/g

    " Remove any leading and trailing whitespace from each line
    silent! %s/^\s\+//g
    silent! %s/\s\+$//g

    " Remove any whitespace before and after tabs
    silent! %s/\s*\t\s*/\t/g

    " Replace 'NULL' with empty string
    silent! %s/NULL//g

    " Remove any blank lines
    silent! g/^$/d

    " Copy everything -> yank for easy copy/pasting
    silent! %y+
    " undo -> to get buffer to default state again -> remove if needed in here
    silent! u
    echo "Copied as TSV to default register"

endfunction

" Map to <leader>tsv
nnoremap <leader>tsv :call CopyToTsv()<CR>


function! CopyToCsv()
    " Format SQL output to CSV and copy to default register

    " Ensure the buffer is modifiable
    setlocal modifiable

    " Delete the lines with the +----+ border
    silent! g/^+----/d

    " Remove the leading and trailing spaces and | character
    silent! %s/^\s*| \?//g
    silent! %s/ \?|\s*$//g

    " Replace the remaining | with commas
    silent! %s/ \?|\s\?/,/g

    " Remove any leading and trailing whitespace from each line
    silent! %s/^\s\+//g
    silent! %s/\s\+$//g

    " Remove any whitespace before and after commas
    silent! %s/\s*,\s*/,/g

    " Replace 'NULL' with empty string
    silent! %s/NULL//g

    " Remove any blank lines
    silent! g/^$/d

    " Copy everything -> yank for easy copy/pasting
    silent! %y+
    " undo -> to get buffer to default state again -> remove if needed in here
    silent! u
    echo "Copied as CSV to default register"

endfunction

" Map to <leader>csv
nnoremap <leader>csv :call CopyToCsv()<CR>

" Markdown - Do not flag underscores as errors in markdown files
hi link markdownError Normal
syn match markdownIgnore "\$x_i\$"

" Use a block cursor in normal mode and a vertical bar cursor in insert mode
if &term =~ 'xterm\|rxvt\|alacritty\|iterm'
    let &t_SI = "\<Esc>[5 q"
    let &t_EI = "\<Esc>[1 q"
    let &t_SR = "\<Esc>[3 q"
endif
