*** LINUX COMMANDS ***

*** Multitasking with SCREEN - https://www.cyberciti.biz/tips/linux-screen-command-howto.html
screen -S 1
ctrl-a c = new concolse
ctrl-a ctrl-a = switch between them
ctrl-a d = detach
cral-a w = list all
ctrl-a k = kill
ctrl-a 0-9 = select

ctrl-a S = split horizontally
ctrl-a :split -v = split vertically
-> go into it with ctrl-a TAB
-> start new console with ctrl-a c

ctrl-a Q = unsplit
ctrl-a TAB = go to next
ctrl-a :resize
ctrl-a :remove
ctla-a :fit

scroll in screen:
ctra-a ESC
up/down/pup/pdwon
enter-enter to exit



*** Prozesssteuerung -> https://wiki.ubuntuusers.de/Shell/Prozesssteuerung/
ctrl-z = send job to background
jobs = show all jobs
command & = start it directly in background!
fg %x = get job back to foreground
bg %x = send to background
disown -h %x => job läuft weiter, wenn terminal beendet wurde!!
nohup command & => job direkt schon laufen lassen im hintergrund, ohne dass er beendet wird


*** Updates (at least monthly)
sudo apt-get update && sudo apt-get upgrade

sudo apt-get remove xxxxx
sudo apt-get clean
sudo apt-get auto-remove
sudo apt-get install xxxxx


*** general linux
| less => pages unterbrechen
-> b = last, space=next, q=exits

*** copy and paste
highlight with mouse [copy]
Shift-Insert OR right-click [paste]
(in vim: mode :set paste)

*** copy and paste to console / to windows!!
-> install x server! https://sourceforge.net/projects/vcxsrv/
 -> start it in windows

VIM needs  xterm_clipboard!!
check: vim --version | grep clipboard

upgrade version:
sudo apt-get install vim-gtk
install X11 server -> https://sourceforge.net/projects/vcxsrv/
=> simply run it, in putty "x11 forwarding" needs to be enabled
copy to register + !!!
DISADVANTAGE: vim is slower, needs more resources... 


*** other commands
sudo [=> to execute root commands without root user!]
su -> to become root
sudo shutdown -r now
sudo reboot
sudo netstat -tulpn
date
ping
whois
nslookup
mtr [like tracert but better]

df -H = free disk space
mcedit (esc 0 = F10)
ps
free -m [cached=free!]
vmstat 1 20 [check io issues]
htop [monitor memory etc, install first]
dpkg -l [find all installed packages]


* remove directory including everything
rm -rf xxxxx


*** remove unused network-facing services
sudo netstat -tulpn

*** Compress decompress with tar/gzip
tar -zcvf archive.tar.gz directory/  [Compress]
tar -zxvf archive.tar.gz [Decompress into current directory]

*** find a file
find -name testfile.txt
find . -name testfile.xt => in current directory

*** grep details => find  -- https://www.linode.com/docs/tools-reference/linux-system-administration-basics / https://www.linode.com/docs/tools-reference/search-and-filter-text-with-grep
grep
grep -rnw '/path/to/somewhere/' -e 'pattern'
sed [search and replace accross files]

find . -type f -exec sed -i.bak "s/foo/bar/g" {} \;



*** nano tipps
ctrl-x = exit
ctrl-w /alt-w= search
ctrl-k = cut line
ctrl-shift-6 = highlight text!
ctrl-u = paste block
nono -m = mouse enabled
f7/f8 = page up/down
esc-$ = word wrap!

*** MySQL tipps
export to CSV (export in tab format -> transform to commas):
mysql -u root -p mydb -e "select * from mytable" -B | sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" > mytable.csv 


-- ********************
-- get access logs sorted by IP
-- ********************

cat access.log | awk '{print $1}' | sort -n | uniq -c | sort -nr | head -20

only for root access!
cat access.log | grep 'GET / ' | awk '{print $1}' |  sort -n | uniq -c | sort -rn | head

whole line for root access to output file
cat access.log | grep 'GET / ' > simplelogs.txt




