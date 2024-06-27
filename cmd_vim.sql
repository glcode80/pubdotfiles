*** VIM COMMANDS ***

temporarily exit vim to get to shell
- ctrl-z
- fg [get back]

main: esc = command mode
:w = write
:sav = save as (open save filed)
:q = exit
:q! = exit without writing
i = insert
:qa = exit all

many many comands.... very cool
vim . = open in explorer view
:e . = open file directory
:tabnew
ctrl-w w = change windows (oder left/right arrows after ctrl-w = move in nerdtree!)
ctrl-w = = equal size
ctrl-wT = any open window to own tab
ctrl-w_ / ctrl-w| = maximize size
:tabedit % = open copy maximized in a new tab
splitv filename => new file in new split
ctlr-d = auto-complete
ctrl-space = auto-complete ycm (auto-trigger = .)
G= ende
set number
gg = Anfang
u = undo
ctrl-R = redo
dd = delete line
v = select text
y = copy selected text
yy = copy full line
p = paste

gj / gk = move only one line in wraps

J = join lines (with space)
gJ = join lines without space

gf = edit file under cursor name!

dtx = deletes to charachter x (without x)
dfx = deletes to character x (including x)
daW = delete whole word
diw = delete in word
d% = delete in brackets block -> go to first sign, then d%
--> y% = copy everything within block
di" = delete in " signs 
--> di[ di( di' , ....
da" = delete around " signs

fx = go to next character x [with t/T = go before this character]
Fx = go to previous character x


search and replace
------------------------
%s/alt/neu/g (o \r fuer line, \t fuer tab,...)
 => can also use something else, e.g. ! [no more need to escape / ]
  => %s!alt!neu!g

Select blocks / comment:
ctrl-v = block select
shift-I = insert at left
# 
esc, esc

wieder zurück:
ctrl-v
2x

comment/uncomment code:
-----------------------------
ESC
Ctrl - v [block selection] -> go down
Shift - i
#
ESC

* Uncomment code:
ESC
Ctrl - v
 chunk of test shift + left/right arrow key
d or x to delete characters
ESC

Alternative:-> NerdCommenter script?
Commands: 
=> immer mit [count] voraus möglich!!
=> immer mit leader key => mapped to space!
c<space> = toggle comment state for selected lines
cl = comment ,left alligned
cc = comment, algined with code
-- cb = comment, aligned at left
-- cn = comment, force nesting
ci = toggle comment state individually (on/off each line)
cs = comment selection with block format
cA = comment at end of line + Append
c$ = comments to end of line

cu = uncomment selected lines

vim surround
----------------------
cs"' = change, ds" = delete
yss" = full line, ysiw" = one word, ys2w" = two words, ...
<b> = tag -> remove with cst"
visual, then S<b> to add around top/bottom
) = no space ( = space



marks and registers
-----------------------
registers = show all registers
ma -> mark a (only valid in buffer)
mA -> mark A (valid accross all buffers)
'a -> go to beginning of line of buffer a '
`a -> go exactly to a => linked to -

"a -> register a (to save copied text) "
"A -> same across buffers "
"+ -> system clipboard (should also work on windwos -> install vim-gtk, run x11 server in windows)"

copy/paste everything:
gg y G "+ y


=> access in insert command/mode with Ctrl -r a
-> ctrl-r " (for default pasted text) "
-> ctrl-r ctrl-o " (for literal control characters) "

"" = unnamed register
"% = current file path => ctrl-r %
": = most recent executed command
"= = result of expressions
 -> ctrl-r = 2+2
 -> ctrl-r = system('ls')   "
 
vim macros (are aleso registers!)
-------
 q<letter> (any letter for the macro)
 -> commands
 q
 
 execute: <number>@<letter>
@@ = excute again


Folding"
-----------
zo = open under cursor
zc = closes under cursor
za = toggle fold
zR = open all folds
zM = close all folds

Indent/Dedent
----------------------
v to select
<< / >>
oder 5>> für 5 linien
oder ,30

besser: mapped to tab / shift-tab in visual mode!
vmap <TAB> >gv
vmap <S-TAB> <gv

Format text nicely / for specifi format
------------------------
gg=G
:%!python -m json.tool
-> saved to :JSON

enable syntax highlighting / folding (to get structure)
:set filetype=json
:syntax on
:set foldmethod=syntax
-> saved to :Jsonfold


Get input from running shell command
------------------------
:read !date


Paste without indents!!
---------------------------
: set paste
-> right-click / shift-insert

Vimdiff / compare two files with diff view
--------------------------------------
vim -d file1 file2
fold/unfold like normal!
]c :        - next difference
[c :        - previous difference
do          - diff obtain
dp          - diff put
zo          - open folded text
zc          - close folded text
:diffupdate - re-scan the files for differences

dbext - MySql
------------------------
let g:dbext_default_profile_ProfileA = 'type=DBI:user=username:passwd=xxxx:driver=mysql:conn_parms=database=DBNAME;host=localhost' 
let g:dbext_default_profile_ProfileB_nonDBI='type=MYSQL:user=username:passwd=xxxx:dbname=DBNAME:host=examplehost12345.com'
<leader>se = run selected query
<leader>sel = run selected line
<leader>sbp = define default profile to use
<leader>st = select * from table under cursor
<leader>sT = select from table, Prompt for number of rows
<leader>stw = select from table, promt for where
<leader>sdt = describes table
<leader>slc = get column names to register -> paste with p
R = re-run results
q = close results

ctrl-x / ctrl-o = enable omni complete (direct db contents completion)

modeline at beginning of sql file:
// dbext:profile=Coindb


Nerdtree commands:
----------------
? = help
ctrl w w = switch window (oder rechts links)
=> mapped to ctrl + pfeiltasten!!
/xxx = search term
I = show hidden file
m = file mode => delete/copy .... !!
:NerdTree = find and show!!
:NERDTreeTabsToggle = disable/enable nerdtraa tabs on all screens!!
:NerdTreeToggle = select file
 enter = open in current tab
 t = open in new tab
:tabn         go to next tab
:tabp         go to previous tab
:tabfirst     go to first tab
:tablast      go to last tab

:split
:vsplit
:resize 60
:resize -5 / +5
:vertical resize 60 / +5 / -5

:split filename = neues file öffnen

:cd /xx/xxx = change file directory in vim
CD = change NerdTree home directory to same directory!
U = up home directory by one directory (keep tree open, alterantive: u)
C = set current directory as home directory

phpcs = syntax correction in PHP files
---------------------------------------------
0) install it (see setup.sql) -> extension + .phpcsruleset.xml
1) check error codes -> can be exluded -> add to .phpcsruleset.xml
phpcbs xxx.php -s --standard=~/.phpcsruleset.xml
2) fix automatically, what can be fixed!
phpcbf xxx.php -s --standard=~/.phpcsruleset.xml
in-file exclusions:
// phpcs:disable PSR1.Files.SideEffects

phpmd = php code guidelines (comes after php, phpcs)
Way to comment out ** --> check file:
~/.phpmdruleset.xml
1) uncomment global rules in here
2) add Comment text SuppressWarnings to php funciton etc
Combine -> add more with * in between, easy!


autopep8 = automatically fix python files
----------------------------------------------
autopep8 --in-place --max-line-length=100 xxx.py
--select="E226"
--ignore="E226"

flake8 - inline ignore comment
# noqa: E731


ctrlp = fuzzy search
-----------------------------------------------
ctrl-p = start search in current directory (:cd to other if needed)
=> can type anything: beginning, end, combination, ...
ctrl-f = toggle mode (current, full)
ctrl-t = open in tab
ctrl-v = open on side
ctrl-x = open below
ctrl-z = mark multiple files, ctrl-o = open them

fix ctrl-s accidential command
------------------------------
ctrl-s freezes everything!
ctrl-q to unfreeze


--******************
--** setup VIM
--******************

apt install vim
settings from .vimrc frmom dotfiles in git account!
putty settnigs from putty-sessions.reg in dotfiles
more putty settings: http://dag.wiee.rs/blog/content/improving-putty-settings-on-windows





 
Links:
https://www.digitalocean.com/community/tutorials/how-to-use-vundle-to-manage-vim-plugins-on-a-linux-vps
https://www.digitalocean.com/community/tutorials/how-to-use-vim-for-advanced-editing-of-plain-text-or-code-on-a-vps--2
https://www.digitalocean.com/community/tutorials/installing-and-using-the-vim-text-editor-on-a-cloud-server
http://askubuntu.com/questions/123392/how-can-i-customize-vim-for-web-development-and-programming
http://michael.peopleofhonoronly.com/vim/vim_cheat_sheet_for_programmers_screen.png
http://chrisstrelioff.ws/sandbox/2014/05/29/install_and_setup_vim_on_ubuntu_14_04.html
http://vimawesome.com


http://regexr.com/



**** summary all commands from vimtutor

Other things not mentioned here:
:tabnew
ctrl-w w = change windows
  splitv filename => new file in new split
ctlr-d = auto-complete
. = repreat command

page moves:
ctrl-d = half page down
M = middle of page
ctrl-b = page uo
ctrl-f = page down
ctrl-e = move cursor, but keep selection


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                               Lesson 1 SUMMARY

  3. To exit Vim type:     <ESC>   :q!   <ENTER>  to trash all changes.
             OR type:      <ESC>   :wq   <ENTER>  to save the changes.

  4. To delete the character at the cursor type:  x

  5. To insert or append text type:
         i   type inserted text   <ESC>         insert before the cursor
         A   type appended text   <ESC>         append after the line

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                               Lesson 2 SUMMARY

  0. . = repeat last command!

  1. To delete from the cursor up to the next word type:    dw
      -> go one word back: b
      -> go to end of wored: e
  2. To delete from the cursor to the end of a line type:    d$
  3. To delete a whole line type:    dd

  4. To repeat a motion prepend it with a number:   2w
  5. The format for a change command is:
               operator   [number]   motion

  6. To move to the start of the line use a zero:  0

  7. To undo previous actions, type:           u  (lowercase u)
     To undo all the changes on a line, type:  U  (capital U)
     To undo the undos, type:                 CTRL-R

	 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                               Lesson 3 SUMMARY

  1. To put back text that has just been deleted, type   p .

  2. To replace the character under the cursor, type   r   and then the
     character you want to have there.

  3. The change operator allows you to change from the cursor to where the
     motion takes you.  eg. Type  ce  to change from the cursor to the end of
     the word,  c$  to change to the end of a line.

  4. The format for change is:

         c   [number]   motion

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                               Lesson 4 SUMMARY

  1. CTRL-G  displays your location in the file and the file status.
             G  moves to the end of the file.
     number  G  moves to that line number.
            gg  moves to the first line.

  2. Typing  /  followed by a phrase searches FORWARD for the phrase.
     Typing  ?  followed by a phrase searches BACKWARD for the phrase.
     After a search type  n  to find the next occurrence in the same direction
     or  N  to search in the opposite direction.
     CTRL-O takes you back to older positions, CTRL-I to newer positions.

  3. Typing  %  while the cursor is on a (,),[,],{, or } goes to its match.

  4. To substitute new for the first old in a line type    :s/old/new
     To substitute new for all 'old's on a line type       :s/old/new/g
     To substitute phrases between two line #s type       :#,#s/old/new/g
     To substitute all occurrences in the file type        :%s/old/new/g
     To ask for confirmation each time add 'c'             :%s/old/new/gc

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                               Lesson 5 SUMMARY

  1.  :!command  executes an external command.

      Some useful examples are:
         (MS-DOS)         (Unix)
          :!dir            :!ls            -  shows a directory listing.
          :!del FILENAME   :!rm FILENAME   -  removes file FILENAME.

  2.  :w FILENAME  writes the current Vim file to disk with name FILENAME.

  3.  v  motion  :w FILENAME  saves the Visually selected lines in file
      FILENAME.

  4.  :r FILENAME  retrieves disk file FILENAME and puts it below the
      cursor position.

  5.  :r !dir  reads the output of the dir command and puts it below the
      cursor position.


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                               Lesson 6 SUMMARY

  1. Type  o  to open a line BELOW the cursor and start Insert mode.
     Type  O  to open a line ABOVE the cursor.

  2. Type  a  to insert text AFTER the cursor.
     Type  A  to insert text after the end of the line.

  3. The  e  command moves to the end of a word.

  4. The  y  operator yanks (copies) text,  p  puts (pastes) it.
   -> yy = copies a whole line

  5. Typing a capital  R  enters Replace mode until  <ESC>  is pressed.

  6. Typing ":set xxx" sets the option "xxx".  Some options are:
        'ic' 'ignorecase'       ignore upper/lower case when searching
        'is' 'incsearch'        show partial matches for a search phrase
        'hls' 'hlsearch'        highlight all matching phrases
     You can either use the long or the short option name.

  7. Prepend "no" to switch an option off:   :set noic

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                               Lesson 7 SUMMARY

  1. Type  :help  or press <F1> or <Help>  to open a help window.

  2. Type  :help cmd  to find help on  cmd .

  3. Type  CTRL-W CTRL-W  to jump to another window

  4. Type  :q  to close the help window

  5. Create a vimrc startup script to keep your preferred settings.

  6. When typing a  :  command, press CTRL-D to see possible completions.
     Press <TAB> to use one completion.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
