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
ctrl-z = send job to background and stop it
bg %x = continue process runinng in background
jobs = show all jobs
command & = start it directly in background!
fg %x = get job back to foreground
bg %x = send to background
disown -h %x => job läuft weiter, wenn terminal beendet wurde!!
nohup command & => (nicht so gut, besser screen!) job direkt schon laufen lassen im hintergrund, ohne dass er beendet wird


** send running process to screen
a) send it to background
ctrl-z
b) resume in background
bg
c) make job continue when terminal ends
disown %1
d) start and screen and take over the job
screen -S 1
find pid, two options (first one is the pid):
 pgrep [command]
 ps aux | grep [command]
take over pid: 
 reptyr [pid]
e) detach/restart screen
ctrl-a d
screen -r

** check memory consumed => RSS = memory in kb
ps aux --sort -rss | head -n15


** Output to textfile / console / logfile / stdout
output to new file: >
append to file: >>
!!! no buffer in pyhton: -u (call with python3 instead of executing the file)

**TOP1* Everything to outfile, including error (nothing to stdout):
python3 -u test.py > outfile.txt 2>&1

vim refresh file (or use tail logfile.txt):
:e

**TOP2* Everything also to the stdout - replace file
python3 -u test.py 2>&1 | tee outfile.txt

Everything also to the stdout - append file
python3 -u test.py 2>&1 | tee -a outfile.txt

* -> spcial with process:
Run it in background as job (not in screen) and send to append file:
python3 -u test.py > outfile.txt &
python3 -u test.py > outfile.txt 2>&1 &





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

size of directories below
du -h --max-depth=1

* remove directory including everything
rm -rf xxxxx

* rename file in mc
shift-f5 = copy to now new
shift-f6 = rename with template
(attention: need to set shortcuts=no in kitty.ini)

* create smybolic link
- set symoblic link -> this places "sourcefolder" into "targetfolder"
  ln -s /PATH_FOR_ACTUAL_DATA/sourcefolder /PATH_TO_LINK_TO/targetfolder

- delete symbolic link
  rm sourcefolder

** copy whole structure via encrypted ftp to local directory
 -> nur ein file: curl

1) screen -S 1
2) mirror with output to logs and using encrypted ftp connectiion
wget -nv -m -o /home/xxx/ftplog.txt --secure-protocol=SSLv3 --no-proxy --passive-ftp --ftp-user=xxxx --ftp-password=xxxx ftp://xxx.xxx.xxx.xxx/

(nv=less output, [q=quiet], m=mirror, o=logging to file)

2b) securly copy only one file!
wget --secure-protocol=SSLv3 --no-proxy --passive-ftp --ftp-user=USER --ftp-password=xxxxxxx ftp://xxx.xxx.xxx.xxx/xxxxx

3) then check with du directory size OR tail log file
watch du -h --max-depth=1
tail -f ftplog.txt


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
including subdirectories

grep -rn -e 'pattern'
grep -rn '/path/to/somewhere/' -e 'pattern'
  -> only full words:
  grep -rnw '/path/to/somewhere/' -e 'pattern'

only in current directory
grep -s "pattern" * .*

sed [search and replace accross files]
- find full instances / all file names only to replace
grep -rn -e "OLDTEXT"
grep -rl -e "OLDTEXT" . | xargs
[option: --exclude-dir=.abc ]

- replace term in one file
sed -i 's/OLDTEXT/NEWTEXT/g' FILENAME.txt

- replace term in all files checked for before
grep -rl -e "OLDTEXT" . | xargs sed -i 's/OLDTEXT/NEWTEXT/g'

Alternative:
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

*** Block an IP with sudo ufw
sudo ufw insert 1 deny from xx.xx.xx.xx to any


-- ********************
-- get access logs sorted by IP
-- ********************

cat access.log | awk '{print $1}' | sort -n | uniq -c | sort -nr | head -20

only for root access!
cat access.log | grep 'GET / ' | awk '{print $1}' |  sort -n | uniq -c | sort -rn | head

whole line for root access to output file
cat access.log | grep 'GET / ' > simplelogs.txt

*** speed test
Write speed:
sync; dd if=/dev/zero of=~/test.tmp bs=500K count=1024
Read speed:
sync; echo 3 | sudo tee /proc/sys/vm/drop_caches
sync; time dd if=~/test.tmp of=/dev/null bs=500K count=1024
rm ~/test.tmp

sudo apt-get iozone3

iozone -e -I -a -s 100M -r 4k -i 0 -i 1 -i 2 
[-f /path/to/file]

*** processor speed / info
cat /proc/cpuinfo

