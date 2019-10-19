*************************************
Summary setup file for server setup
-> open and run each command with f10 in vim
*************************************

***********************************
*** Setup basic LEMP image      ***
***********************************

0) config: GRUB2 on some hosts better for php-fpm - check if running/restarting!

1) overall server setup
sudo apt-get update
sudo apt-get upgrade
sudo dpkg-reconfigure tzdata
adduser moon
adduser moon sudo


2) adjust sudo settings
sudo EDITOR=vim visudo
# increase sudo timeout (-1 = never timeout / default = 5 min)
# Defaults    timestamp_timeout=180
# no password required for user at all -> add to end
moon ALL=(ALL)  NOPASSWD: ALL

# if sudo crontab -e raises issues, add to visudo settings
Defaults env_keep += "EDITOR"

vim .bashrc
export EDITOR=/usr/bin/vim
# change default editor for cronjobs
select-editor

3) ssh keys -> login with user
ssh-keygen -b 4096
mkdir ~/.ssh
touch ~/.ssh/authorized_keys
chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys
*! add public key !*
sudo vim /etc/ssh/sshd_config
PermitRootLogin no
PasswordAuthentication no
ChallengeResponseAuthentication no
sudo systemctl restart sshd


4) clone setup files -> link / copy to user folder
git clone https://glcode80@github.com/glcode80/pubdotfiles.git
ln -s /home/moon/pubdotfiles/cmd_linux.sql /home/moon/
ln -s /home/moon/pubdotfiles/cmd_vim.sql /home/moon/
ln -s /home/moon/pubdotfiles/sqltest.sql /home/moon/
ln -s /home/moon/pubdotfiles/setup.sql /home/moon/
others: copy

4b) set up steal tracking
sudo apt install sysstat
sudo apt install jq
crontab -e
mkdir /home/moon/steal
* * * * * /home/moon/pubdotfiles/steal_tracking.sh >> /home/moon/steal/steal.csv 2>&1
sudo pip3 install pandas
ln -s /home/moon/pubdotfiles/steal_analysis.py /home/moon/steal/
cp /home/moon/pubdotfiles/steal_alert.py /home/moon/steal/
cp /home/moon/pubdotfiles/toolsalert.py /home/moon/steal/
vim /home/moon/steal/steal_alert.py
crontab -e
26 * * * * /home/moon/steal/steal_alert.py >> /home/moon/logs/stealalert.txt 2>&1

rotate logs monthly automatically (keep 6 files, rotate monthly)
sudo vim /etc/logrotate.d/steal
/home/moon/steal/steal.csv {
  rotate 6
  monthly
  compress
  missingok
  notifempty
}

test:
sudo logrotate /etc/logrotate.conf --debug

force logrotate:
sudo logrotate /etc/logrotate.conf --verbose --force

5) install programs needed
sudo apt-get install screen
sudo apt-get install mc

5b) fix utf8 line drawing issues
vim .bashrc
# fix utf8 line drawing issues
test "$TERM" = "putty" && export LC_ALL=C || export LC_ALL=en_US.utf8
export TERM=xterm-256color

6) set up git
sudo apt-get install git
mkdir git
git config --global credential.helper "cache --timeout=72000"
git config --global user.name "x"
git config --global user.email "x"
git config --global credential.https://github.com.glcode80 glcode80


7) set up vim
sudo apt-get install vim
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
PluginInstall

* for X11-forwarding working & dbext working *
install X11 server -> https://sourceforge.net/projects/vcxsrv/
sudo apt-get install vim-gtk
sudo apt-get install libdbi-perl
sudo apt-get install libdbd-mysql-perl

* avoid ctrl-s hanging terminal (could stop with ctrl-q)
echo "stty -ixon" >> .bashrc

* proper bash auto-complete with tab/shift-tab
vim .bashrc

# tab to auto-complete
bind TAB:menu-complete
# shift-tab to go back
bind '"\e[Z": menu-complete-backward'
# display list of matching files
bind "set show-all-if-ambiguous on"
# only start cycling on second tab press
bind "set menu-complete-display-prefix on"



* Ctags / YouCompleteMe *
sudo apt install exuberant-ctags
sudo apt-get install build-essential cmake
sudo apt-get install python-dev python3-dev
cd ~/.vim/bundle/YouCompleteMe
./install.py
(on Raspi run it on one core only: YCM_CORES=1 ./install.py --gocode-completer)


8) install python plugins
sudo apt-get install python3
sudo apt-get install python3-pip
sudo pip3 install --upgrade setuptools
sudo pip3 install pymysql
sudo pip3 install requests
sudo pip3 install pytz
sudo pip3 install flake8
sudo pip3 install autopep8
sudo pip3 install pylint
sudo pip3 install tld
sudo pip3 install matplotlib
sudo pip3 install numpy

update all packages with pip3:
sudo pip3 freeze — local | grep -v ‘^\-e’ | cut -d = -f 1 | xargs -n1 sudo pip3 install -U

sudo apt-get install -y python3-venv
mkdir venv
cd ~/venv
python3 -m venv testvenv 
source ~/venv/testvenv/bin/activate
=> install with pip3 things here
deactivate


9) install php plugins (for Vim)
php needs to be installed to work (see below)
 php -v
 sudo apt-get install php7.2-cli
 sudo apt-get install php7.2-xml
   sudo apt-get install php
 -> more plugins php-tools-install.sql
#PHPCS
sudo curl -LsS https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar -o /usr/local/bin/phpcs
sudo chmod a+x /usr/local/bin/phpcs
#PHPMD -> use version saved on own github, as other one is not available anymore
sudo curl -LsS https://raw.githubusercontent.com/glcode80/pubdotfiles/master/install/phpmd.phar -o /usr/local/bin/phpmd
  --  sudo curl -LsS http://static.phpmd.org/php/latest/phpmd.phar -o /usr/local/bin/phpmd
sudo chmod a+x /usr/local/bin/phpmd
#PHPCBF
sudo curl -LsS https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar -o /usr/local/bin/phpcbf
sudo chmod a+x /usr/local/bin/phpcbf


10) install lint for bash
sudo apt install shellcheck


11) ufw / fail2ban
sudo ufw enable
sudo ufw default allow outgoing
sudo ufw default deny incoming
sudo ufw allow ssh
sudo ufw logging on
sudo apt-get install fail2ban
sudo cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo vim /etc/fail2ban/jail.local
- bantime = default: 600 =10 minutes => change to 31536000 = 1 year
sudo fail2ban-client start


12) MariaDB 10.3
(starting 10.2 supports subqueries in views, default is 10.1 in 18.04)

sudo apt-get install software-properties-common
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
sudo vim /etc/apt/sources.list.d/mariadb.list
# MariaDB 10.3 Repository
deb [arch=amd64,arm64,ppc64el] http://sfo1.mirrors.digitalocean.com/mariadb/repo/10.3/ubuntu bionic main
deb-src http://sfo1.mirrors.digitalocean.com/mariadb/repo/10.3/ubuntu bionic main

sudo apt update
sudo apt install mariadb-server
sudo mysql_secure_installation
sudo systemctl restart mariadb.service
sudo mysql -u root -p

* Enable events!
-- root needs to run:
SET GLOBAL event_scheduler = ON;

-- And add to mysqld file to enable it on restart
sudo vim /etc/mysql/conf.d/mysql.cnf
[mysqld]
event_scheduler = ON 

* Fix error log for mysql to log file location
sudo vim /etc/mysql/conf.d/mysql.cnf
[mysqld]
log_error = /var/log/mysql/error.log


13) Nginx
-- get most recent version from source
wget http://nginx.org/keys/nginx_signing.key
sudo apt-key add nginx_signing.key

sudo vim /etc/apt/sources.list.d/nginx.list

# Nginx repository
deb [arch=amd64,arm64] http://nginx.org/packages/ubuntu/ bionic nginx
deb-src http://nginx.org/packages/ubuntu/ bionic nginx

sudo apt update
sudo apt remove nginx
sudo apt install nginx
sudo systemctl start nginx
sudo systemctl enable nginx

* replace default conf file with old file with proper settings
sudo rm /etc/nginx/nginx.conf
sudo cp /home/moon/pubdotfiles/nginx.conf.1.14.0_use   /etc/nginx/nginx.conf
sudo systemctl restart nginx
sudo systemctl status nginx

* fix bug with "can't open pid" on status
sudo mkdir /etc/systemd/system/nginx.service.d
sudo vim /etc/systemd/system/nginx.service.d/override.conf
[Service]
ExecStartPost=/bin/sleep 0.1

sudo systemctl daemon-reload
sudo systemctl restart nginx
sudo systemctl status nginx


sudo vim /etc/nginx/nginx.conf
=> www-data
[from nginx] - if not, you get a 502 gateway error!!
worker_processes 1



sudo rm /etc/nginx/sites-enabled/default
sudo rm /etc/nginx/conf.d/default.conf

-- test: hello world
sudo wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/nginx-default-helloworld.conf -P /etc/nginx/conf.d
sudo vim /etc/nginx/conf.d/nginx-default-helloworld.conf

sudo service nginx restart
sudo ufw allow 80

-- enable gzip compression AND enable max file size upload php!! [for wordpress download manager -> upload files! also adjust php.ini!]
sudo vim /etc/nginx/nginx.conf
	gzip on;
	gzip_disable "mise6";
	gzip_vary on;
	gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
	client_max_body_size 128M;

	
14) PHP

sudo apt install php7.2-fpm
sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.2/fpm/php.ini
sudo apt install php7.2-mysql
sudo apt-get install php-curl php-gd php-mbstring php-xml php-xmlrpc php-json
sudo apt-get install php7.2-zip
sudo apt-get install php7.2-tidy

sudo systemctl enable php7.2-fpm
sudo systemctl restart php7.2-fpm


15) geoip database & update script
sudo apt-get install geoip-bin
-> directory: /usr/share/GeoIP/
geoiplookup 8.8.8.8
sudo rm /usr/bin/geoipupdate.sh
sudo wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/geoipupdate.sh -P /usr/bin
sudo chmod +x /usr/bin/geoipupdate.sh
sudo geoipupdate.sh
0 16 * * 3 /usr/bin/geoipupdate.sh >> /home/moon/logs/sudologs.txt 2>&1


16) remove/adjust message of the day / motd - https://oitibs.com/ubuntu-16-04-dynamic-motd/
cd /etc/update-motd.d/
sudo chmod -x /etc/update-motd.d/10-help-text
sudo chmod -x /etc/update-motd.d/50-motd-news 
sudo chmod -x /etc/update-motd.d/80-livepatch

sudo apt-get install lsb-release figlet update-motd update-notifier-common
sudo wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/10-sysinfo -P /etc/update-motd.d/
sudo chmod +x /etc/update-motd.d/10-sysinfo

17) monit
sudo apt-get install monit

* php7.2-fpm
sudo vim /etc/monit/conf.d/php7.2-fpm
# make sure to use 7.0 / 7.2 everywhere!!
check process php7.2-fpm with pidfile /run/php/php7.2-fpm.pid
	group www-data #change accordingly
    start program = "/usr/sbin/service php7.2-fpm start" with timeout 60 seconds
    stop program  = "/usr/sbin/service php7.2-fpm stop"
    if failed unixsocket /var/run/php/php7.2-fpm.sock then restart

* mariadb	
sudo cp /etc/monit/conf-available/mysql /etc/monit/conf.d/
sudo vim /etc/monit/conf.d/mysql
find pid files: 
	sudo find / -name "*.pid"
replace pid for mariadb: /var/lib/mysql/localhost.pid
-> attention: this is always the hostname!

* nginx
sudo ln -s /etc/monit/conf-available/nginx /etc/monit/conf-enabled/

* openssh
sudo cp /etc/monit/conf-available/openssh-server /etc/monit/conf.d/
sudo vim /etc/monit/conf.d/openssh-server
-> comment out line 12 / 26-28 (dsa_key sections)

* cron
sudo ln -s /etc/monit/conf-available/cron /etc/monit/conf-enabled/

* memcached (tbd)

* enable httpd service on localhost:
sudo vim /etc/monit/monitrc
set httpd port 2812 and
    use address localhost  # only accept connection from localhost
    allow localhost        # allow localhost to connect to the server and

	
sudo monit -t
sudo service monit reload
-> then
sudo monit summary
sudo monit status nginx
sudo monit status

logfile:
sudo vim /var/log/monit.log


***********************************
*** Fine-tune gold master       ***
***********************************

goldmaster after install [enable=auto-start]
 => everything enabled by default on master + port 80 open (443 / 3306 closed)
 => monit enabled
 
check: php7.2-fpm working after restart?
if not: use GRUB2 (and or monit to make sure it restarts) -> issue with linode kernel!
sudo monit summary

 
sudo apt update
sudo apt upgrade
sudo hostnamectl set-hostname [HOSTNAME]
sudo vim /etc/hosts
-> if issues with hostname error message: add hostname after localhost
-> 127.0.0.1       localhost xxx
sudo dpkg-reconfigure tzdata 


1) add new key for server / remove default
vim /home/moon/.ssh/authorized_keys

2) add private key (to connect to other servers, RSA key with 4096 bits + strong password -> conversions export openssh key)
vim ~/.ssh/id_rsa
vim ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/id_rsa;
chmod 600 ~/.ssh/id_rsa.pub

3) firewall: open ports needed
sudo ufw status

4) * mysql *
mysql -u root -p

- a) change root password
USE mysql;
select user,host,authentication_string,password from user;
UPDATE user SET password=PASSWORD('xxxx') WHERE User='root';
  UPDATE user SET authentication_string=PASSWORD('xxxx') WHERE User='root' and host='xxx';
FLUSH PRIVILEGES;
exit;

- b) drop default schema
DROP SCHEMA Playground;
DROP USER 'analyst'@'localhost';
FLUSH PRIVILEGES;
exit;

- c) disable overall
sudo systemctl disable mariadb.service
sudo systemctl enable/disable/status/start/stop/restart mariadb.service

- d) transfer data -> see below

5) nginx: start/stop + setup services
sudo systemctl disable nginx
sudo systemctl enable/disable/status/start/stop/restart nginx

6) php-fpm: adjust/finetune settings
sudo systemctl disable php7.2-fpm
sudo systemctl enable/disable/status/start/stop/restart php7.2-fpm

7) adjust monit accordingly
cd /etc/monit/conf-enabled
cd /etc/monit/conf.d
rm files
sudo monit summary
sudo vim /etc/monit/monitrc

* attention need to adjust mysql pid in hostname
sudo vim /etc/monit/conf.d/mysql
find pid files: 
    sudo find / -name "*.pid"
replace pid for mariadb: /var/lib/mysql/localhost.pid
-> attention: this is always the hostname!


* enable email alerts from monit
sudo vim /etc/monit/monitrc
#Mail settings via Mailgun SMTP
set mail-format {
  from: monit@**MONITDOMAIN**.com
  subject: $HOST - Monit Alert -- $EVENT
  message: $EVENT Service $SERVICE
                Date:        $DATE
                Action:      $ACTION
                Host:        $HOST
                Description: $DESCRIPTION
				}
set mailserver smtp.mailgun.org port 587
  username postmaster@mg.**MONITDOMAIN**.com password "**MAILGUN_SMTP_PASSWORD**"
  using TLSV1 with timeout 30 seconds
set alert **RECEIVING_EMAIL** #email address which will receive monit alerts
sudo monit restart

8) nginx: default profile, certificate, certbot, settings

9) fail2ban: nginx-wordpress, nginx-default, ...
sudo fail2ban-client unban --all

10) php/wordpress: caching (memcached/nginx cache/opcache/settings)

11) steal-alert
clear / add monitoring


****************************************
*** Additional settings/adjustments  ***
****************************************


1) Backup scripts
wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/backup_sql.sh -P /home/moon
chmod +x /home/moon/backup_sql.sh
vim /home/moon/backup_sql.sh

wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/backup_data.sh -P /home/moon
chmod +x /home/moon/backup_data.sh
vim /home/moon/backup_data.sh

wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/backup_delete.sh -P /home/moon
chmod +x /home/moon/backup_delete.sh
vim /home/moon/backup_delete.sh

wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/backup_rclone.sh -P /home/moon
chmod +x /home/moon/backup_rclone.sh
vim /home/moon/backup_rclone.sh


2) fix local ip instead of dhcp on 18.04
ifconfig
sudo cp /etc/netplan/50-cloud-init.yaml /etc/netplan/01-netcfg.yaml
sudo vim /etc/netplan/01-netcfg.yaml
addresses: [192.168.2.xxx/24]
sudo netplan apply

2b) fix dhcp ip release on 18.04 -> use max as identifier
ifconfig
sudo cp /etc/netplan/50-cloud-init.yaml /etc/netplan/01-netcfg.yaml
sudo vim /etc/netplan/01-netcfg.yaml
add:
	dhcp-identifier: mac
sudo netplan apply

2c) -- if hostname doesn't change, run first:
sudo apt remove cloud-init


3) speed tests
- read/write
Write speed:
sync; dd if=/dev/zero of=~/test.tmp bs=500K count=1024
Read speed:
sync; echo 3 | sudo tee /proc/sys/vm/drop_caches
sync; time dd if=~/test.tmp of=/dev/null bs=500K count=1024
rm ~/test.tmp
sudo apt-get iozone3
iozone -e -I -a -s 100M -r 4k -i 0 -i 1 -i 2 
[-f /path/to/file]
- cpu: sysbench -> check events per second / total number of events
sudo apt install sysbench
sysbench --time=10 --cpu-max-prime=10000 cpu run
sysbench --time=10 --cpu-max-prime=20000 cpu run
sysbench --threads=4 --time=10 --cpu-max-prime=20000 cpu run
sysbench --test=memory run
sysbench --test=fileio --file-test-mode=seqwr run
sysbench --test=fileio --file-test-mode=rndwr run
 -> test mode {seqwr, seqrewr, seqrd, rndrd, rndwr, rndrw}

- download test file
wget -O /dev/null https://speed.hetzner.de/100MB.bin
wget -O /dev/null http://speedtest.frankfurt.linode.com/100MB-frankfurt.bin
wget -O /dev/null http://fra-de-ping.vultr.com/vultr.com.100MB.bin

wget -O /dev/null http://speedtest.newark.linode.com/100MB-newark.bin
wget -O /dev/null https://speed.hetzner.de/1GB.bin


***********************************
*** Mysql Cheat Sheet           ***
*********************************** 
 
select User,host,password,authentication_string from mysql.user;
select concat("'",user,"'@'",host,"'") from mysql.user;
select concat("show grants for '",user,"'@'",host,"';") from mysql.user;
select concat("create user '",user,"'@'",host,"' identified by '';") from mysql.user;

CREATE USER 'exampleuser'@'localhost' IDENTIFIED BY 'xxxx';
CREATE USER 'userremote'@'%' IDENTIFIED BY 'xxxx';
show grants for 'user'@'host';
GRANT ALL ON *.* TO 'exampleuser'@'localhost';
grant SELECT,INSERT,UPDATE,DELETE ON `db`.* TO 'user'@'host';
revoke all privileges on *.* from 'user'@'host';
FLUSH PRIVILEGES;
quit

* change password
USE mysql;
select user,host,authentication_string,password from user;
UPDATE user SET password=PASSWORD('xxxx') WHERE User='zzz' AND Host ='localhost';
  UPDATE user SET authentication_string=PASSWORD('xxxx') WHERE User='zzzz' AND Host ='localhost';
FLUSH PRIVILEGES;
exit;


* check status of all tables in a schema
mysqlcheck -u mydbuser -p mydbname

* enable remote access:
sudo ufw allow 3306
sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf
sudo vim /etc/mysql/my.cnf.dpkg-new
-> #bind 127.0.0.1 => comment it out
sudo systemctl restart mysql

* database dumps

1) general mysqldump db-backup:
mysqldump -u root -p DATABASENAME > DATABASENAME.sql
mysql -u root -p SOMEDATABASENAME < DATABASENAME.sql

2) backup everyting -> newer versions support skip-definer, olders not
i) all data (attention: do it only from same db to same db!)
mysqldump -u root -p --all-databases --routines --triggers --events --skip-definer > alldb.sql
mysqldump -u root -p --all-databases --routines --triggers --events  | sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' | sed -e 's/DEFINER[ ]*=[ ]*[^*]*PROCEDURE/PROCEDURE/' | sed -e 's/DEFINER[ ]*=[ ]*[^*]*FUNCTION/FUNCTION/' > alldb.sql

ii) all data specifying database names
mysqldump -u root -p --databases db1 db2 db3 --routines --triggers --events | sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' | sed -e 's/DEFINER[ ]*=[ ]*[^*]*PROCEDURE/PROCEDURE/' | sed -e 's/DEFINER[ ]*=[ ]*[^*]*FUNCTION/FUNCTION/' > alldb.sql

iii) all grants (escape special characters in password)
select concat("'",user,"'@'",host,"'") from mysql.user;
select concat("show grants for '",user,"'@'",host,"';") from mysql.user;

MYSQL_CONN="-uroot -pPASSWORD"
mysql ${MYSQL_CONN} --skip-column-names -A -e"SELECT CONCAT('SHOW GRANTS FOR ''',user,'''@''',host,''';') FROM mysql.user WHERE user<>''" | mysql ${MYSQL_CONN} --skip-column-names -A | sed 's/$/;/g' > MySQLUserGrants.sql

iv) recreate users (if not specified datbase names)
select concat("create user '",user,"'@'",host,"' identified by '';") from mysql.user;

v) import on other server (remove lines that produce error in grants)
mysql -u root -p < alldb.sql
mysql -u root -p -A < MySQLUserGrants.sql

vi) flush privileges!
flush privileges

vii) check views / issues with definers
SELECT TABLE_SCHEMA, TABLE_NAME FROM information_schema.tables WHERE TABLE_TYPE LIKE 'VIEW';
SHOW CREATE VIEW xxx;

viii) check if everything is in order!
-> do another all db export as test on target machine

* Attention with big files *
- use option to create (should be enabled by default): --opt
- when re-importing: first edit the file -> remove the index creations!!
 -> this changes the import time from 6 hours to 20 mins on 4GB of data!!
 -> then add the index via sql, easy

* server name anpassen/ersetzen in der DB! -> benutze tool dazu!
git clone https://github.com/interconnectit/Search-Replace-DB.git
php srdb.cli.php -h localhost -n DBNAME -u USERNAME -p PASSWORT -s ALTEDOMAIN.com -r NEUEDOMAIN.COM
** !! attention -> if wordpress gives 404
  -> disable / delete nginx.conf file from w3tc in conf / foldder **


* Mysqltuner - https://github.com/major/MySQLTuner-perl
mkdir /home/moon/mysqltuner
cd /home/moon/mysqltuner
wget http://mysqltuner.pl/ -O mysqltuner.pl
wget https://raw.githubusercontent.com/major/MySQLTuner-perl/master/basic_passwords.txt -O basic_passwords.txt
wget https://raw.githubusercontent.com/major/MySQLTuner-perl/master/vulnerabilities.csv -O vulnerabilities.csv
perl /home/moon/mysqltuner/mysqltuner.pl


* Mysql Tuning script tuning-primer.sh
cd ~
git clone https://github.com/BMDan/tuning-primer.sh/

***********************************
*** Others Cheat Sheet          ***
*********************************** 

1) cron job 
*/5 * * * * /home/moon/directory/script.py >> /home/moon/logs/logs.txt 2>&1
sudo service cron restart

2) directory zip/unzip -> need tar! (gzip does each file individually!)
tar/gzip is much better, as it keeps more access rights!

- Compress:
tar -zcvf archive.tar.gz directory/ 
- Decompress into current directory: 
tar -zxvf archive.tar.gz

[alternative: zip => zip -r archive.zip foldertozip ]

3) Ufw / fail2ban
- general
sudo ufw allow from XXX.XX.XX.XX
sudo ufw delete allow XXXX
sudo ufw allow from XXX.XX.XX.XX to any port 1433
sudo ufw allow from XXX.XX.XX.XX proto udp to any port 1433
- ban an IP with ufw
-- ACHTUNG: Order is important to block an IP
sudo ufw insert 1 deny from xx.xx.xx.xx to any

- unban an IP with ufw
sudo ufw status numbered
sudo ufw delete XXX

- unban an IP with fail2ban
sudo fail2ban-client set <JAIL> unbanip <IP>
sudo fail2ban-client unban <IP> ... <IP>
sudo fail2ban-client unban --all


- add other jails to fail2ban -> add enabled=true + make sure to have proper log file
sudo vim /etc/fail2ban/jail.local
sudo fail2ban-client -t
sudo fail2ban-client reload
sudo service fail2ban restart
sudo fail2ban-client status [xxx]

* important:
- by default localhost is excluded
- filter needs to be in /etc/fail2ban/filter.d
- need "enabeld = true"
- need filter = xxx (if different name from heading)
- need proper log path
- test filter on a file -> to show exact lines: --print-all-matched
sudo fail2ban-regex /var/log/nginx/access.log /etc/fail2ban/filter.d/nginx-wordpress.conf
sudo fail2ban-regex /var/log/mysql/error.log /etc/fail2ban/filter.d/mysqld-auth.conf
sudo fail2ban-regex /var/log/nginx/error.log /etc/fail2ban/filter.d/nginx-http-auth.conf
sudo fail2ban-regex /var/log/nginx/error.log /etc/fail2ban/filter.d/nginx-botsearch.conf

* option [to ignore an ip on a filter]
ignoreip = xxx.xxx

* regex basis = python regex
https://docs.python.org/2/library/re.html
=> test with https://regex101.com/ -> select Python

* add own nginx-wordpress filter
a) check for php login/xmlrpc exploits
sudo vim /etc/fail2ban/filter.d/nginx-wordpress.conf
[Definition]
failregex = <HOST>.*POST.*(wp-login\.php|xmlrpc\.php).* (403|499|200)

b) check for running code in search -> more than x searches to be blocked
[first s=? then a charachter (to exclude search bots with nothing), then status code (to exlcude including the ones where it is only a referrer]

sudo vim /etc/fail2ban/filter.d/nginx-wordpress-search.conf
[Definition]
failregex = <HOST>.*GET.*(\?s\=)[0-9a-zA-Z].* (200|404|301|302)

c) check for trying to access database -> block [better than checking for search]
sudo vim /etc/fail2ban/filter.d/nginx-select.conf
[Definition]
failregex = <HOST>.*GET.*(SELECT%%20|select%%20|UPDATE%%20|update%%20).* (200|404|301|302)


enable a new filter:
** attention: also add filter description! **
sudo vim /etc/fail2ban/jail.local

* uncomment -> to make sure monit still works for mysql
ignoreip = 127.0.0.1/8 ::1


[nginx-select]
enabled = true
port = http,https
filter = nginx-select
logpath = /var/log/nginx/*access.log
maxretry = 6

# better to use nginx-select than search -> disable for now!
[nginx-wordpress-search]
enabled = true
port = http,https
filter = nginx-wordpress-search
logpath = /var/log/nginx/*access.log
maxretry = 20
findtime = 300
bantime = 86400


[nginx-wordpress]
enabled = true
port = http,https
filter = nginx-wordpress
logpath = /var/log/nginx/*access.log
maxretry = 6


[mysqld-auth]
enabled = true
port     = 3306
logpath=/var/log/mysql/error.log
# logpath  = %(mysql_log)s
backend  = %(mysql_backend)s


* and enable for -> check later
[nginx-http-auth]
enabled = true
logpath = /var/log/nginx/*error.log

[nginx-botsearch]
enabled = true
logpath = /var/log/nginx/*error.log
# logpath = %(nginx_error_log)s

sudo fail2ban-client -t
sudo fail2ban-client reload
sudo fail2ban-client reload [jailname]


* check log files / status */
sudo vim /var/log/fail2ban.log
sudo fail2ban-client -t
sudo fail2ban-client status
sudo fail2ban-client status sshd
sudo fail2ban-client status nginx-wordpress
sudo systemctl status fail2ban.service


***********************************
*** Nginx adjustments / Certbot ***
***********************************

-> set access rights on www-folder
cd /var/www/
chown www-data:www-data  -R *

* link file to /var/www/
sudo ln -s /home/moon/git/GITFOLDER/index.php /var/www/main/

* config -> link to /etc/nginx/conf.d/
sudo ln -s /home/moon/git/GITFOLDER/configfile.conf /etc/nginx/conf.d/

-- 1) remove default file! / add default for empty server response / others !!!
-- => need to get certificate for default https

sudo rm /etc/nginx/sites-enabled/default

sudo mkdir /etc/nginx/owncert
sudo openssl req -x509 -nodes -days 9999 -newkey rsa:2048 -keyout /etc/nginx/owncert/privateKey.key -out /etc/nginx/owncert/certificate.crt -subj '/CN=<SERVERIP_ADD_HERE>'
cd /etc/nginx/conf.d
ls

-- default: empty file -> ip not going to first server
-> first remove: nginx-default-helloworld.conf
sudo wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/nginx-default-empty.conf -P /etc/nginx/conf.d
-> put in server IP!
sudo vim /etc/nginx/conf.d/nginx-default-empty.conf

-- redirect
sudo wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/nginx-redirect.conf -P /etc/nginx/conf.d
sudo vim /etc/nginx/conf.d/nginx-redirect.conf

-- www
sudo wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/nginx-www.conf -P /etc/nginx/conf.d
sudo vim /etc/nginx/conf.d/nginx-www.conf

-- www with php
sudo wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/nginx-www-php.conf -P /etc/nginx/conf.d
sudo vim /etc/nginx/conf.d/nginx-www-php.conf

-- php with wordpress
sudo wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/nginx-wordpress.conf -P /etc/nginx/conf.d
sudo vim /etc/nginx/conf.d/nginx-wordpress.conf

* certbot -> make sure to open port first!!
sudo ufw allow 443
sudo apt install software-properties-common
  sudo apt install software-properties-common python-software-properties
sudo add-apt-repository ppa:certbot/certbot
sudo apt update
sudo apt upgrade
sudo apt install python-certbot-nginx
sudo certbot --nginx -d example.com -d www.example.com

update script:
sudo wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/certbotupdate.sh -P /usr/bin
sudo chmod +x /usr/bin/certbotupdate.sh
sudo certbotupdate.sh
sudo crontab -e
0 3,15 * * * /usr/bin/certbotupdate.sh >> /home/moon/logs/sudologs.txt 2>&1
	
	
*** Nginx FastCGI Page Cache -> caches pages in memory (like varnish) ***
-> test by checking response headers: HIT/MISS/BYPASS

/var/run = ram disk! -> can also put to normal disk. be careful with size of cache
/etc/nginx = normal disk -> instead of 50ms around 60-70ms (no big difference)

sudo vim /etc/nginx/nginx.conf

# ** NGINX PAGE CACHE START - nginx.conf http - options: 60m, 5h, 5d - adjust in conf too! **

# fastcgi_cache_path /var/run/nginxcacheGLOBAL levels=1:2 keys_zone=cacheGLOBAL:100m inactive=7d;
fastcgi_cache_path /etc/nginx/nginxcacheGLOBAL levels=1:2 keys_zone=cacheGLOBAL:300m inactive=7d;

# can have second cache for other page with different params, if no intention to share
# fastcgi_cache_path /var/run/nginxcacheSITE1 levels=1:2 keys_zone=cacheSITE1:100m inactive=7d;
# fastcgi_cache_path /var/run/nginxcacheSITE2 levels=1:2 keys_zone=cacheSITE2:100m inactive=7d;

fastcgi_cache_key "$scheme$request_method$host$request_uri";
# for geoip cache, add countrycode (needs working geoip module!)
# fastcgi_cache_key "$scheme$request_method$host$request_uri$geoip_country_code";

fastcgi_cache_use_stale error timeout invalid_header http_500;
fastcgi_ignore_headers Cache-Control Expires Set-Cookie;
# ** NGINX PAGE CACHE END - nginx.conf http**

+ add two blocks to nginx conf file -> see examples

-- www with php with fastcgi pache cache
sudo wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/nginx-www-php-fastcgi-cache.conf -P /etc/nginx/conf.d
sudo vim /etc/nginx/conf.d/nginx-www-php-fastcgi-cache.conf

-- php with wordpress with fastcgi pache cache
sudo wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/nginx-wordpress-fastcgi-cache.conf -P /etc/nginx/conf.d
sudo vim /etc/nginx/conf.d/nginx-wordpress-fastcgi-cache.conf

sudo nginx -t
sudo service nginx restart

to clear manually -> empty everythin in directory:
sudo rm -rf /var/run/nginxcacheGLOBAL/*

*/Wordrepss Plugin to purge -> Nginx Cache Tim Krüss
  /var/run/nginxcacheGLOBAL
  (or custom cache path)

benchmark testing: loader.io


*** Ngxinx redirect based on country code from IP ***
https://dzone.com/articles/nginx-with-geoip-maxmind-database-to-fetch-user-ge
https://www.howtoforge.com/tutorial/how-to-use-geoip-with-nginx-on-ubuntu-16.04/

1) install / load geoip module
sudo apt-get install nginx-module-geoip
sudo vim /etc/nginx/nginx.conf
-> beginning
load_module "modules/ngx_http_geoip_module.so";

2) run new geoipupdate.sh script
!! attention: not possible to update anymore! check!!
 -> use new geoip update script from manual source
 => /usr/share/GeoIP/maxmind.dat

3) adjust http section of nginx.conf
sudo vim /etc/nginx/nginx.conf

    # load db -> make field available to config scripts
    # -> can use $geoip_country_code
	# use manually downloaded db that is still updated for country 4/6
	geoip_country /usr/share/GeoIP/maxmind.dat;

sudo vim /etc/nginx/conf.d/CONFFILE.conf

    # do temporary redirect (307) based on country code -> add to server block
    if ($geoip_country_code ~ (US|DE) ) {
        return 307 https://www.OTHERDOMAIN.com;
		# return 307 https://www.OTHERDOMAIN.com$request_uri;
    }

*** Nginx more redirect codes / Cookies ***

* Redirect with rewrite -> add to location block (will cause 302="found")
rewrite ^ $scheme://NEWURL break;
# rewrite ^ $scheme://$NEWURL$request_uri break;

* Redirect only the first time -> only if cookie is not set yet
if ($http_cookie !~ "redirect=set") {
	add_header Set-Cookie "redirect=set;Max-Age=31536000";
	rewrite ^ $scheme://NEWURL break;
	}

* Multiple conditions -> do hack of seting $test = A, then $testB -> check for "AB"

** Combine: redirect only first time for certain country codes 

# general server section
# first set redirect_goal to default uri entered, if geoip redirect -> change it
# then below: only redirect, if http cookie is not set yet
set $redirect_goal $host$request_uri;
if ($geoip_country_code ~ (DE|CH) ) {
	set $redirect_goal "CUSTOMURL";
}

# within location section (before nginx page cache)
# Redirect only first time, if cookie is not set yet
# redirect to URI defined above (based on country code)
if ($http_cookie !~ "redirect=set") {
	add_header Set-Cookie "redirect=set;Max-Age=31536000";
	rewrite ^ $scheme://$redirect_goal break;
	}

** Block access to certain resources based on country code **
-> important: need "else" block in there, to process like normal

 # return 403 by geoip on certain paths (from root path)
 # location ~* /checkout {
 location ~* ^/(checkout|de/kasse) {
	if ($geoip_country_code ~ (JP) ) {
		return 403;
	}       
	try_files $uri $uri/ /index.php$is_args$args;
}

	
** Rewrite glcid / fbclid -> cached page instead of loading it every time

## fix fbclid added to uri - inside each server block - START ###
# remove GET parameters:
if ($args ~* (.*)fbclid|gclid=[^&]*(.*)) {
set $args $1$2;
set $removearg "removearg";
}
# cleanup any repeated & introduced:
if ($args ~ (.*)&&+(.*)) {
set $args $1&$2;
}
# cleanup leading &
if ($args ~ ^&(.*)) {
set $args $1;
}
# cleanup ending &
if ($args ~ (.*)&$) {
set $args $1;
}
if ( $removearg = "removearg" ) {
rewrite ^(.*)$ $uri permanent;
}
## fix fbclid added to uri - inside each server block - END ###




***********************************
*** Adjust PHP / Memcached      ***
***********************************

* adjust php settings [ALSO adjust nginx.conf for client_max_body_size=128m; !!!]
sudo vim /etc/php/7.2/fpm/php.ini

memory_limit = 512M
max_execution_time = 60
max_input_time=60
upload_max_filesize = 64M
post_max_size = 64M
-- opcode cache seems not to be very helpful, page cache much more important
opcache.enable=1
opcache.memory_consumption=128
opcache.max_accelerated_files=4000
opcache_revalidate_freq = 240

sudo phpenmod opcache
sudo service php7.2-fpm restart
  sudo service php7.0-fpm restart
sudo service nginx restart



** tune php workers **

* Attention: if cpu 100% is the problem, then better to have not too many workers *
* -> better to have 2 workers, if 2 cpus are available, otherwise just too much overhead *

sudo vim /etc/php/7.2/fpm/pool.d/www.conf
-> user/group = www-data

i) tune php-fpm - max children etc! => adjust if more RAM is available!
a) get memory used per process:
ps aux | grep "php-fpm"
-> last before ? -> around 65mb

=> how much ram available (after memcached)?
-> maybe take 50% of "free -m"
on 2GB droplet, maybre around 1.5GB free -> use 700MB
-> set it to 12 children

pm.max_children = 12
pm.start_servers = 4 [ca 1/3]
pm.min_spare_servers = 4 [ca/3]
pm.max_spare_servers = 7 [ca 60%]
pm.max_requests = 500 [leave]

for 4GB Linode -> free 3.5GB -> use 2GB -> 
pm.max_children = 24
pm.start_servers = 8 [ca 1/3]
pm.min_spare_servers = 8 [ca/3]
pm.max_spare_servers = 16 [ca 60%]
pm.max_requests = 500 [leave]

ii) php-fpm emergency restart settings [not implemented yet, using monit]
https://serverfault.com/questions/575457/constantly-have-to-reload-php-fpm
sudo vim /etc/php/7.2/fpm/php-fpm.conf

emergency_restart_threshold=3
emergency_restart_interval=1m
process_control_timeout=5s


** memcached => Do NOT do it for now*
sudo apt-get install memcached 
sudo apt-get install php-memcached
sudo vim /etc/memcached.conf
-m 128

disable udp
-l 127.0.0.1
-U 0

sudo service memcached restart
sudo service php7.2-fpm restart
sudo service nginx restart


***********************************
*** Install Wordpress    ***
***********************************
sudo mkdir /var/www/example.com/src/
cd /var/www/example.com/src/
sudo chown -R www-data:www-data /var/www/example.com/
sudo wget http://wordpress.org/latest.tar.gz
sudo -u www-data tar -xvf latest.tar.gz
sudo mv latest.tar.gz wordpress-`date "+%Y-%m-%d"`.tar.gz
sudo mv wordpress/* ../public_html/
sudo chown -R www-data:www-data /var/www/example.com/



