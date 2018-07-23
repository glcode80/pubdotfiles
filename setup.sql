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

* Catags / YouCompleteMe *
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
sudo pip3 install flake8
sudo pip3 install pylint
sudo pip3 install matplotlib
sudo pip3 install numpy

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


9) nginx / php
sudo vim /etc/apt/sources.list
deb http://nginx.org/packages/mainline/ubuntu/ xenial nginx
sudo wget http://nginx.org/keys/nginx_signing.key
sudo apt-key add nginx_signing.key
sudo apt update
sudo apt install nginx
sudo systemctl start nginx
sudo systemctl enable nginx

sudo apt install php7.2-mysql
sudo apt install php7.2-fpm
sudo apt-get install php-curl php-gd php-mbstring php-mcrypt php-xml php-xmlrpc
sudo apt-get install php7.0-zip
sudo apt-get install php7.0-tidy
 [evtl: sudo apt-get install php-memcached ]

sudo systemctl restart php7.0-fpm
sudo systemctl restart php7.2-fpm

sudo apt-get install software-properties-common python-software-properties
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install python-certbot-nginx
sudo certbot --nginx -d example.com -d www.example.com

sudo vim /etc/nginx/nginx.conf
=> www-data
[from nginx] - if not, you get a 502 gateway error!!

-> set access rights on www-folder
cd /var/www/
chown www-data:www-data  -R *


10) cron job 
*/5 * * * * /home/USERNAME/directory/script.py >> /home/USERNAME/logs/logs.txt 2>&1
sudo service cron restart

