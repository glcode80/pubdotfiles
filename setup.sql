*************************************
Summary setup file for server setup
-> open and run each command with f10 in vim
*************************************

***********************************
*** Setup basic LEMP image      ***
***********************************

1) overall server setup
sudo apt-get update
sudo apt-get upgrade
sudo dpkg-reconfigure tzdata
adduser moon
adduser moon sudo


2) adjust sudo settings
sudo visudo
# increase sudo timeout (-1 = never timeout / default = 5 min)
# Defaults    timestamp_timeout=180
# no password required for user at all -> add to end
moon ALL=(ALL)  NOPASSWD: ALL


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


5) install programs needed
sudo apt-get install screen
sudo apt-get install mc


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
#PHPMD
sudo curl -LsS http://static.phpmd.org/php/latest/phpmd.phar -o /usr/local/bin/phpmd
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
cd /etc/fail2ban
sudo cp fail2ban.conf fail2ban.local
sudo cp jail.conf jail.local
sudo vim jail.local
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


***********************************
*** Fine-tune gold master       ***
***********************************

goldmaster after install [enable=auto-start]
 => everything enabled by default on master + port 80 open (443 / 3306 closed)

sudo apt update
sudo apt upgrade
sudo hostnamectl set-hostname [HOSTNAME]
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

6) php-fpm: adjsut/finetune settings
sudo systemctl disable php7.2-fpm
sudo systemctl enable/disable/status/start/stop/restart php7.2-fpm

7) nginx: default profile, certificate, certbot, settings
8) php/wordpress: caching (memcached/nginx cache/opcache/settings)
9) monit: install (see below)


****************************************
*** Additional settings/adjustments  ***
****************************************

1) monit
sudo apt-get install monit
sudo vim /etc/monit/conf.d/php7-fpm

# make sure to use 7.0 / 7.2 everywhere!!
check process php7-fpm with pidfile /run/php/php7.2-fpm.pid
	group www-data #change accordingly
    start program = "/usr/sbin/service php7.2-fpm start" with timeout 60 seconds
    stop program  = "/usr/sbin/service php7.2-fpm stop"
    if failed unixsocket /var/run/php/php7.2-fpm.sock then restart

sudo ln -s /etc/monit/conf-available/nginx /etc/monit/conf-enabled/
sudo ln -s /etc/monit/conf-available/mysql /etc/monit/conf-enabled/
sudo ln -s /etc/monit/conf-available/openssh-server /etc/monit/conf-enabled/
sudo monit -t
sudo service monit reload


2) Backup scripts
sudo wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/make_sql_backups.sh -P /usr/bin
sudo chmod +x /usr/bin/make_sql_backups.sh
sudo vim /usr/bin/make_sql_backups.sh

NEW:
wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/backup_sql.sh -P /home/moon
chmod +x /home/moon/backup_sql.sh
vim /home/moon/backup_sql.sh

sudo wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/make_sql_backups_delete.sh -P /usr/bin
sudo chmod +x /usr/bin/make_sql_backups_delete.sh
sudo vim /usr/bin/make_sql_backups_delete.sh

sudo wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/make_data_backups.sh -P /usr/bin
sudo chmod +x /usr/bin/make_data_backups.sh
sudo vim /usr/bin/make_data_backups.sh

NEW:
wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/backup_data.sh -P /home/moon
chmod +x /home/moon/backup_data.sh
vim /home/moon/backup_data.sh

sudo wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/make_data_backups_delete.sh -P /usr/bin
sudo chmod +x /usr/bin/make_data_backups_delete.sh
sudo vim /usr/bin/make_data_backups_delete.sh

sudo wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/make_rclone.sh -P /usr/bin
sudo chmod +x /usr/bin/make_rclone.sh
sudo vim /usr/bin/make_rclone.sh


3) fix local ip instead of dhcp on 18.04
ifconfig
sudo cp /etc/netplan/50-cloud-init.yaml /etc/netplan/01-netcfg.yaml
sudo vim /etc/netplan/01-netcfg.yaml
addresses: [192.168.2.xxx/24]
sudo netplan apply


4) speed tests
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
sysbench --test=cpu --cpu-max-prime=10000 run
sysbench --test=cpu --num-threads=8 --cpu-max-prime=10000 run
sysbench --test=memory run
sysbench --test=fileio --file-test-mode=seqwr run
sysbench --test=fileio --file-test-mode=rndwr run
 -> test mode {seqwr, seqrewr, seqrd, rndrd, rndwr, rndrw}


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


* Mysqltuner - https://github.com/major/MySQLTuner-perl
mkdir /home/moon/mysqltuner
cd /home/moon/mysqltuner
wget http://mysqltuner.pl/ -O mysqltuner.pl
wget https://raw.githubusercontent.com/major/MySQLTuner-perl/master/basic_passwords.txt -O basic_passwords.txt
wget https://raw.githubusercontent.com/major/MySQLTuner-perl/master/vulnerabilities.csv -O vulnerabilities.csv
perl /home/moon/mysqltuner/mysqltuner.pl


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

sudo vim /etc/nginx/nginx.conf

# ** NGINX PAGE CACHE START - nginx.conf http - options: 60m, 5h, 5d - adjust in conf too! **
fastcgi_cache_path /var/run/nginxcacheGLOBAL levels=1:2 keys_zone=cacheGLOBAL:100m inactive=7d;
# can have second cache for other page with different params, if no intention to share
# fastcgi_cache_path /var/run/nginxcacheSITE1 levels=1:2 keys_zone=cacheSITE1:100m inactive=7d;
# fastcgi_cache_path /var/run/nginxcacheSITE2 levels=1:2 keys_zone=cacheSITE2:100m inactive=7d;
fastcgi_cache_key "$scheme$request_method$host$request_uri";
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
opcache.enable=1
opcache.memory_consumption=128
opcache.max_accelerated_files=4000
opcache_revalidate_freq = 240

sudo phpenmod opcache
sudo service php7.2-fpm restart
  sudo service php7.0-fpm restart
sudo service nginx restart

* tune php-fpm - max children etc! => adjust if more RAM is available!
sudo vim /etc/php/7.2/fpm/pool.d/www.conf
  sudo vim /etc/php/7.0/fpm/pool.d/www.conf

-> on 2GB droplet, maybre around 1.5GB free -> use 700MB
pm.max_children = 12
pm.start_servers = 4 [ca 1/3]
pm.min_spare_servers = 4 [ca/3]
pm.max_spare_servers = 7 [ca 60%]
pm.max_requests = 500 [leave]

-> for 4GB Linode -> free 3.5GB -> use 2GB -> 
pm.max_children = 24
pm.start_servers = 8 [ca 1/3]
pm.min_spare_servers = 8 [ca/3]
pm.max_spare_servers = 16 [ca 60%]
pm.max_requests = 500 [leave]


* memcached *
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

Wordpress -> use W3TC -> memcached


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



