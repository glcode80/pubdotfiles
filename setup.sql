*************************************
Summary setup file for server setup
-> open and run each command with f10 in vim
*************************************

1) get this setup file from github, get vimrc and all other config files
wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/setup.sql
wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/.vimrc
wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/.screenrc
wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/cmd_linux.sql
wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/cmd_vim.sql
wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/.dbextprofiles.vim
wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/.flake8
wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/.pylintrc

2) set up git
sudo apt-get install git
mkdir git
git config --global credential.helper "cache --timeout=72000"
git config --global user.name "x"
git config --global user.email "x"
git config --global credential.https://github.com.glcode80 glcode80

3) set up vim
sudo apt-get install vim
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
PluginInstall

* for X11-forwarding working & dbext working *
install X11 server -> https://sourceforge.net/projects/vcxsrv/
sudo apt-get install vim-gtk
sudo apt-get install libdbi-perl
sudo apt-get install libdbd-mysql-perl

* Ctags / YouCompleteMe *
sudo apt install exuberant-ctags
sudo apt-get install build-essential cmake
sudo apt-get install python-dev python3-dev
cd ~/.vim/bundle/YouCompleteMe
./install.py
(on Raspi run it on one core only: YCM_CORES=1 ./install.py --gocode-completer)

4) overall server setup
sudo apt-get update
sudo apt-get upgrade
hostnamectl set-hostname [HOSTNAME]
sudo dpkg-reconfigure tzdata 
vim /etc/hosts 
adduser [USERNAME]
adduser [USERNAME] sudo

5) install python plugins
sudo apt-get install python3
sudo apt-get install python3-pip
sudo pip3 install pymysql
sudo pip3 install requests
sudo pip3 install pytz
sudo pip3 install flake8
sudo pip3 install pylint
sudo pip3 install matplotlib
sudo pip3 install numpy

sudo apt-get install -y python3-venv
mkdir venv
cd ~/venv
python3 -m venv testvenv 
source ~/venv/testvenv/bin/activate
=> install with pip3 things here
deactivate

5b) install php plugins
sudo apt-get install php-pear
sudo pear install PHP_CodeSniffer


6) install programs needed
sudo apt-get install screen
sudo apt-get install mc

7) ssh / ufw / fail2ban
sudo vim /etc/ssh/sshd_config
PermitRootLogin no
sudo systemctl restart sshd
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

8) mariadb / mysql
sudo apt-get install mysql-server
sudo apt-get install mariadb-server
sudo mysql_secure_installation

mysql -u root -p

select User,host,plugin from mysql.user;

CREATE USER 'exampleuser'@'localhost' IDENTIFIED BY 'xxxxxxxxxx';
CREATE USER 'userremote'@'%' IDENTIFIED BY 'xxxx';
show grants for 'user'@'host';
GRANT ALL ON *.* TO 'exampleuser'@'localhost';
grant SELECT,INSERT,UPDATE,DELETE ON `db`.* TO 'user'@'host';
revoke all privileges on *.* from 'user'@'host';
FLUSH PRIVILEGES;
quit

* enable remote access:
sudo ufw allow 3306
sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf
-> #bind 127.0.0.1 => comment it out
sudo systemctl restart mysql

* Enable events!
-- root needs to run:
SET GLOBAL event_scheduler = ON;

-- And add to mysqld file to enable it on restart
sudo vim /etc/mysql/conf.d/mysql.cnf
[mysqld]
event_scheduler = ON 


9) nginx / certbot
sudo vim /etc/apt/sources.list
deb http://nginx.org/packages/mainline/ubuntu/ xenial nginx
sudo wget http://nginx.org/keys/nginx_signing.key
sudo apt-key add nginx_signing.key
sudo apt update
sudo apt install nginx
sudo systemctl start nginx
sudo systemctl enable nginx

sudo vim /etc/nginx/nginx.conf
=> www-data
[from nginx] - if not, you get a 502 gateway error!!

-> set access rights on www-folder
cd /var/www/
chown www-data:www-data  -R *

* link file to /var/www/
sudo ln -s /home/USERNAME/git/GITFOLDER/index.php /var/www/main/

* config -> link to /etc/nginx/conf.d/
sudo ln -s /home/USERNAME/git/GITFOLDER/configfile.conf /etc/nginx/conf.d/

-- 1) remove default file!
cd /etc/nginx/conf.d
ls

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

7) enable gzip compression AND enable max file size upload php!! [for wordpress download manager -> upload files! also adjust php.ini!]
sudo vim /etc/nginx/nginx.conf
	gzip on;
	gzip_disable "mise6";
	gzip_vary on;
	gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
	client_max_body_size 128M;



* certbot
sudo apt-get install software-properties-common python-software-properties
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install python-certbot-nginx
sudo certbot --nginx -d example.com -d www.example.com

update script:
sudo wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/certbotupdate.sh -P /usr/bin
sudo chmod +x /usr/bin/certbotupdate.sh
sudo certbotupdate.sh
sudo crontab -e
0 3,15 * * * /usr/bin/certbotupdate.sh >> /home/USERNAME/logs/sudologs.txt 2>&1


10) php

sudo apt install php7.2-fpm
  sudo apt install php7.0-fpm
sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.2/fpm/php.ini
  sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.0/fpm/php.ini
sudo apt install php7.2-mysql
  sudo apt install php7.0-mysql
sudo apt-get install php-curl php-gd php-mbstring php-mcrypt php-xml php-xmlrpc php-json
sudo apt-get install php7.2-zip
  sudo apt-get install php7.0-zip
sudo apt-get install php7.2-tidy
  sudo apt-get install php7.0-tidy

sudo systemctl restart php7.2-fpm
  sudo systemctl restart php7.0-fpm

* adjust php settings [ALSO adjust nginx.conf for client_max_body_size=128m; !!!]
sudo vim /etc/php/7.2/fpm/php.ini
  sudo vim /etc/php/7.0/fpm/php.ini

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



11) memcached
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


12) geoip database & update script
sudo apt-get install geoip-bin
-> directory: /usr/share/GeoIP/
geoiplookup 8.8.8.8
wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/geoipupdate.sh -P /usr/bin
sudo chmod +x /usr/bin/geoipupdate.sh
sudo geoipupdate.sh
0 16 * * 3 /home/USERNAME/geoipupdate.sh >> /home/USERNAME/logs/sudologs.txt 2>&1


12) cron job 
*/5 * * * * /home/USERNAME/directory/script.py >> /home/USERNAME/logs/logs.txt 2>&1
sudo service cron restart

13) monit
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


14) backup
sudo wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/make_sql_backups.sh -P /usr/bin
sudo chmod +x /usr/bin/make_sql_backups.sh
sudo vim /usr/bin/make_sql_backups.sh
sudo wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/make_data_backups.sh -P /usr/bin
sudo chmod +x /usr/bin/make_data_backups.sh
sudo vim /usr/bin/make_data_backups.sh
sudo wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/make_data_backups_delete.sh -P /usr/bin
sudo chmod +x /usr/bin/make_data_backups_delete.sh
sudo vim /usr/bin/make_data_backups_delete.sh
sudo wget https://raw.githubusercontent.com/glcode80/pubdotfiles/master/make_rclone.sh -P /usr/bin
sudo chmod +x /usr/bin/make_rclone.sh
sudo vim /usr/bin/make_rclone.sh


