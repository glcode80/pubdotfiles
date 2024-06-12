exit
-- safety exit not to run full script by mistake

*** LINUX COMMANDS ***

**************
*** apt / dpkg commands
**************

* apt commands -> search/list packages *
apt list
apt search
apt show
apt policy

--> search for package name overall
apt list nginx*
apt list nginx-*

--> search for geoip2 in description and then grep
apt search geoip2 | grep nginx

--> search for all php packages available
apt list php8.*
apt search php8. | grep php
apt search php8.2 | grep php
apt search php8.3 | grep php

--> show detailed description of a package
APT show nginx-core
apt show nginx-extras
apt show libnginx-mod-http-geoip2


** dpkg to check installed status / config status **
dpkg -l | grep "nginx"
ii = installed, config installed correctly
rc = removed, config still present -> need to purge

remove rc ones / purge config
apt purge packagename
apt purge php8.*
dpkg -l | grep "php8-" | awk '{print "sudo apt purge " $2}'

* apt policy => check sources for package *
-- show all sources available
apt policy
-- grep for special ones and compare to unattended upgrades
apt policy | grep o= | grep -v Ubuntu | grep -v Debian
sudo unattended-upgrades --dry-run -v

-- show sources just for one package
apt policy nginx-core

**************
*** systemd based systems that use logs in journal instead of /var/log (e.g. auth.log / error.log etc)
**************
- journalctl instead of rsyslog -> systemd based logging
 -> all in binary format instead of /var/log/auth.log and /var/log/syslog

- check logs with journalctl
	-> add -f to get "follow" = "live tail"
	-> add -n 10 -> enly last 10
journalctl -f -u myservice
journalctl -u nginx --no-pager --since "1 hour ago"
journalctl -u nginx --no-pager -n 20
journalctl -u nginx --no-pager -f -n 20
journalctl -u ssh -n 50
journalctl -u mariadb -n 50
journalctl -u mariadb -f -n 10
-- failed login attempts
journalctl -p authpriv.warning
journalctl --since "1 week ago"
-- string Error
journalctl -S Error
-- grep for error on service
journalctl -u mariadb | grep error


**************
*** httpie -> run http / https commands (much better than curl / wget)
**************

-- normal get
https pie.dev/get

-- query string parameters with: ==
https pie.dev/get hello==world

-- more details
https pie.dev/get hello==world -v

-- post request with query parameters
https POST pie.dev/post hello==world -v

-- send json with: =
https pie.dev/post hello=world -v

-- send form data with: -f / =
https -f pie.dev/post hello=world -v

-- download file with progress bar
https pie.dev -d

-- send headers with: :
https pie.dev/get x-api-key:abc -v

-- basic auth
http -a username:password pie.dev/basic-auth/username/password

-- bearer auth
https -A bearer -a token pie.dev/bearer


** Curl / Httpie -> get response timings / breakdowns **
https pie.dev/get --meta

curl -o /dev/null -s -w '   namelookup: %{time_namelookup}\n      connect: %{time_connect}\n   appconnect: %{time_appconnect}\n  pretransfer: %{time_pretransfer}\n     redirect: %{time_redirect}\nstarttransfer: %{time_starttransfer}\n-----------------\n        total: %{time_total}\n' --location https pie.dev/get

-- run from script -> double escape
curl -o /dev/null -s -w '   namelookup: \%{time_namelookup}\n      connect: \%{time_connect}\n   appconnect: \%{time_appconnect}\n  pretransfer: \%{time_pretransfer}\n     redirect: \%{time_redirect}\nstarttransfer: \%{time_starttransfer}\n-----------------\n        total: \%{time_total}\n' --location https pie.dev/get


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

-- show all active listening devices (legacy: netstat -> now ss)
-- -> 0.0.0.0 + [::] -> sind die offenen ip4/ip6!
sudo ss -tulpn
-- all connections
ss -a
sudo ss -a | grep "http"

sudo ss -tulpn '( dport = :22 or sport = :22 )'
sudo ss -tulpn '( dport = :ssh or sport = :ssh )'

-- nur public listening devices!
sudo ss -tulpn src 0.0.0.0
sudo ss -tulpn src [::]

-- combined only public / only local (6010 = x11 forwarding)
sudo ss -tulpn '( src 0.0.0.0 or src [::] )'
sudo ss -tulpn '( src 127.0.0.1 or src 127.0.0.53 or src [::1] )'

-- see previous sessions
sudo w
-- kill session
-- sudo pkill -KILL -t pts/0

date
ping
whois
nslookup
mtr [like tracert but better]

-- run command in current shell -> source / . command
-- -> can be used for example to change directory in bash/shell script
. scriptname.sh

df -H = free disk space
mcedit (esc 0 = F10)
ps
free -m [cached=free!]
vmstat 1 20 [check io issues]
htop [monitor memory etc, install first]
dpkg -l [find all installed packages]

size of directories below (combined)
du -h --max-depth=1

size of directories -> list each one seperately
du -sh *

* remove directory including everything
rm -rf xxxxx

** completely remove bash history
rm /home/moon/.bash_history
history -c

-> do not store command to history when executing
==> add space before command

* rsync -> check man rsync!
rsync -av /home/moon/source/ /home/moon/newsource
(a = archive: keep attributes and modification times)
(trailing / -> copy contents of folder to new folder)
-L = copy contents of symlinks
-> attention: modification times only synced to full seconds (rclone: milliseconds)
exclude: --exclude "@Recycle/**" -> multilevel subpaths below it

* cp -> different with trailing / - -av flag exists too
-> need . at end (all files, including hidden, including source)
cp -av /home/moon/source/. /home/moon/newsource


** user/group management
-- get all groups for user moon
groups moon
-- get all groups for all users
cat /etc/passwd | awk -F':' '{ print $1}' | xargs -n1 groups
-- user/group are the same
cat /etc/passwd | awk -F':' '{ print $1}' | xargs -n1 groups | awk -F' : ' '$1==$2 { print $1}'
-- user/group are NOT the same
cat /etc/passwd | awk -F':' '{ print $1}' | xargs -n1 groups | awk -F' : ' '$1!=$2 { print $0}'
-- only the ones with more then 1 entry (more than 2 spaces
cat /etc/passwd | awk -F':' '{ print $1}' | xargs -n1 groups | awk -F' ' 'NF > 3'
-- only the ones with only 1 entry
cat /etc/passwd | awk -F':' '{ print $1}' | xargs -n1 groups | awk -F' ' 'NF == 3'

-- add user moon to www-data group -> moon can read all www-data contents
sudo adduser moon sudo
sudo adduser moon www-data
sudo adduser moon mssql

-- add user without password/login/home (e.g. for samba)
sudo adduser --disabled-password --disabled-login --no-create-home USERNAME

-- find all symbolic links below directory
find /home/moon -type l -ls
find /var/www -type l -ls
-- find all symbolic links that point to a certain directory
sudo find / -xdev -type l -ls | grep "moon/"

** chmod
-- group/others: alles weg -> 700 / 600
sudo chmod -R g-rwx,o-rwx /home/moon
-- others: alles weg -> 770 / 660
sudo chmod -R o-rwx /home/moon
-- others: alles weg, ausser exclusion path
sudo find /home/moon/ -xdev -not -path "*/EXCLUDE*" -exec chmod o-rwx {} \;

-- write exact chmod for directories/files recursively - FOR SPECIFIC FOLDER
-- 770 = directories owner/group: read/write/execute
-- 660 = files owner/group: read/write
sudo find /home/moon/ -type d -exec chmod 770 {} \;
sudo find /home/moon/ -type f -exec chmod 660 {} \;
-- same with owner only: 700 / 600
sudo find /home/moon/ -type d -exec chmod 700 {} \;
sudo find /home/moon/ -type f -exec chmod 600 {} \;

** chown
sudo chown -R moon:moon /home/moon

** mount
-- make mount directory (chown doesn't matter, can remain root)
sudo mkdir /mnt/mountpoint
-- for ext4: ownership via chmod/chown
sudo mount /dev/sdd1 /mnt/mountpoint
sudo umount /mnt/mountpoint
-- set proper ownership on disk
sudo chown -R moon:moon /mnt/mountpoint/
sudo chmod 700 /mnt/mountpoint/
sudo chmod -R g-rwx,o-rwx /mnt/mountpoint/
-- samba share busy: go out of directory + restart samba daemon if needed
sudo systemctl restart smbd

*** network commands
- query nameserver
dig google.com
- query nameserver - use specific nameserver
dig google.com @1.1.1.1
dig ns google.com @1.1.1.1
dig a google.com @1.1.1.1
dig mx google.com @1.1.1.1

-- same with nslookup
nslookup google.com 1.1.1.1

** trim disk
sudo fstrim -va
sudo /usr/sbin/fstrim --fstab --verbose

* rename file in mc
shift-f5 = copy to now new
shift-f6 = rename with template
(attention: need to set shortcuts=no in kitty.ini)

* bulk rename files based on pattern -> install rename package
-- replace OLD with NEW for files (n = print only)
rename s/OLD/NEW/g *findstring* -n

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
-> in current directory and all subdirectories, case insensitive (for exact match: "name" instead of "iname")
- -xdev = ignore other filesystems (like proc)
find . -type f -iname "*searchterm*"
find /home/moon/ -type f -iname "*searchterm*"
find / -type f -iname "*searchterm*"
-- only in current directory -> maxdepth option
find . -maxdepth 1 -type f -iname "*searchterm*"
-- exact filename
sudo find / -type f -name error.log
sudo find / -type f -name *.log

*** find largest files (only on current filesystem)
-- size > 100mb
sudo find / -xdev -type f -size +500M
sudo find / -xdev -type f -size +100M
-- largest directories
sudo du -Bm / 2>/dev/null | sort -nr | head -n 20
-- largest files/directories overall
sudo du -aBm / 2>/dev/null | sort -nr | head -n 20

*** grep details => find  -- https://www.linode.com/docs/tools-reference/linux-system-administration-basics / https://www.linode.com/docs/tools-reference/search-and-filter-text-with-grep
-e = exact term, -ie = insensitive of case
--include="*.sql" = include only this pattern (same for exclude)
grep
including subdirectories

grep -rn -ie 'pattern'
grep -rn -ie 'pattern' --include="*.py"

grep -rn '/path/to/somewhere/' -ie 'pattern'
  -> only full words:
  grep -rnw '/path/to/somewhere/' -ie 'pattern'

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

*** sed to comment / uncomment whole line if word is found
-- comment out full line that contains pattern (and isn't commented out yet)
sed -i '/<pattern>/ s/^#*/#/g' filename.txt

-- uncomment full line that contains pattern
sed -i '/<pattern>/s/^#//g' filename.txt


*** awk tipps **
- get second item for each line
awk '{print $2}'
- add custom text to it
awk '{print "vim " $2}'
- combine lines and output with text
tr '\n' ' ' | awk '{print "vim " $0}'


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


*** Safeley delete files / clean harddisks ***
shred
-vf = verbose, force write
-n 1 = only one pass

-> complete hardisk
lsblk
sudo fdisk -l
sudo shred -vf -n 1 /dev/sdXXX

-> safely delete one file
shred --remove filename.txt

-> safely delete all files in one directory
find /home/moon/testremove/ -type f -exec shred --remove {} +;


*** SMART status of harddisk ***
full status
sudo smartctl /dev/sdXXX -a

-c = get time for quick test
-t short = run short test
-H = health summary only
-l selftest = status of test



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

