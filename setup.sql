*************************************
Summary setup file for server setup
-> open and run each command with f10 in vim
*************************************

***********************************
*** Release upgrades            ***
***********************************

CHECK:
- network (customization) before/after
- sources before/after
- unattended upgrades before/after
- php/nginx/special packages before/after
-> all automated updates still working?

apt policy | grep o= | grep -v Ubuntu | grep -v Debian
sudo unattended-upgrades --dry-run -v

- postfix/email/monit: all still working?
- ufw still working
- fail2ban still working properly?


***********************************
*** Main changes Ubuntu 24.04   ***
***********************************

- pipx instead of sudo pix install, default: apt packages
- fail2ban broken


***********************************
*** Main changes Ubuntu 22.04   ***
***********************************

-- **** ATTENTION for symbolic links *****
-- Ubuntu 22.04 by default has no more read access for others on home directory
-- If needed (for symbolic links), run:
-- => see below for commands to fine-tune

-- change back to default before 22.04
sudo chmod 755 /home/moon

-- change again to default 22.04
sudo chmod 750 /home/moon

-- Other Changes:
1) all done with install scripts
2) geoipupdate -> to default locations
3) nginx now uses geoip2 -> no more need for old legacy format database
4) updates for certbot/geip -> done via services (no need for cron jobs)
-> 
sudo systemctl list-timers
-- to test-run
sudo systemctl start xxx.service
-- to check logs
sudo systemctl status xxx.service

5) ssh-rsa not working by default
--> putty by default used sha-1 on sha-2 keys -> disabled now (all keys are rsa-ssh2 already!)
=> need to have all programs supporting recognizing rsa keys as sha-2 key!

-- temporary workaround -> re-enable it
sudo vim /etc/ssh/sshd_config
PubkeyAcceptedKeyTypes=+ssh-rsa
sudo systemctl restart sshd

-- proper solution to make sure to force sha-2 on rsa-keys
- upgrade all putty keys to v3 ppk (open and save again)
- use putty instead of kitty (no more scrolling issues)
- filezilla already ok
- dbeaver: use sshj instead of JSch (advanced settings)
 -> need to convert ssh keys to proper PEM format:
    ssh-keygen -p -m PEM -f <filename>
 -> wait for version that implements sshj 0.33! (older versions not ok yet!)
==> do NOT do it anymore, use OpenSSH and ED25519 keys (see below)

ssh-keygen -t ed25519 -a 16 -f <filename.ssh> -C <keyname>


***********************************
*** Check/Fine-tune chmods      ***
***********************************

-- check current status
ls -hal /home/ | grep moon
750 = drwxr-x--- = others können nichts
755 = drwxr-xr-x = others read and execute -> (nur bei symbolic links / other users in moon)

-- check symbolic links beneath moon -> might need 755 on each directory below
sudo find / -xdev -type l -ls | grep "moon/" | grep -v "pubdotfiles/cmd" | grep -v "pubdotfiles/setup"

-- find directories by owner www-data beneath moon (only first level = prune) -> might need 755 on each directory below
sudo find / -xdev -type d -user www-data -prune -ls
sudo find /home/moon/ -xdev -type d -user www-data -prune -ls
sudo find /home/moon/ -xdev -type d -group www-data -prune -ls
sudo find /home/moon/ -xdev -group www-data -prune -ls
sudo find /home/moon/ -xdev -group mssql -prune -ls

-- alles unten sauber weg nehmen recursive (group drin lassen)
sudo chmod -R o-rwx /home/moon

-- option: komplett auch group execution raus
sudo chmod -R g-rwx,o-rwx /home/moon

-- option: alle anderen raus, ausser bestimmtes verzeichnis
sudo find /home/moon/ -xdev -not -path "*/EXCLUDE*" -exec chmod o-rwx {} \;

**** Vorgehen:  *******************

** A) Wenn alles auber ist (kein www-data, kein mssql, keine symbolic links) -> setzt alles auf 700 oder tiefer
sudo chmod -R g-rwx,o-rwx /home/moon

*** B) Wenn es etwas hat -> global erlauben, dann ganze directory chain 755
sudo chmod 755 /home/moon
-- (nur others raus, group drin lassen, damit man www-data z.B bearbeiten kann)
--> combined: remove rwx on others for all files and folders excluding entered
sudo find /home/moon/ -xdev -not -path "*/EXCLUDE*" -exec chmod o-rwx {} \;
--> add back to all folders in path
sudo chmod 755 /home/moon
sudo chmod 755 /home/moon/xxx
sudo chmod 755 /home/moon/xxx/xxx

--> add back to files that need it (read+write by others, e.g. www-data)
chmod o+rw <filename>


***********************************
*** Updates machen              ***
***********************************

sudo apt update
sudo apt upgrade
sudo apt dist-upgrade  # z.b. auf Debian
sudo apt autoremove

-- Achtung: immer zuerst testen, nicht auf prod machen! (z.b. pymysql, youcompleteme, ...)
sudo pip3 install XXXX --upgrade [siehe unten]

vim -> PluginUpdate [Achtung ycm evtl zu neuer version, siehe unten]


***********************************
*** Setup basic LEMP image      ***
***********************************

0) config: GRUB2 on some hosts better for php-fpm - check if running/restarting!

1) overall server setup
sudo apt update
sudo apt upgrade
sudo timedatectl set-timezone 'Europe/Zurich'
	old: sudo dpkg-reconfigure tzdata
sudo dpkg-reconfigure keyboard-configuration


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
Defaults env_keep += "VISUAL"
Defaults env_keep += "HOME"

vim .bashrc
export EDITOR=/usr/bin/vim

=> workaround (keeps enviroment variables) -> same as 'Defaults env_keep += "HOME"':
sudo -E vim

# change default editor for cronjobs
select-editor

3) ssh keys -> login with user => NEW; use ed25519 keys
ssh-keygen -t ed25519 -a 16
OLD: ssh-keygen -b 4096
mkdir ~/.ssh
touch ~/.ssh/authorized_keys
chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys


*! add public key !*
sudo vim /etc/ssh/sshd_config
PermitRootLogin no
PasswordAuthentication no
ChallengeResponseAuthentication no
sudo systemctl restart sshd

** option to set UsePAM no **
-> with "yes" password authentication is still possible via PAM (tbd)
-> to set to "no", there needs to be an unlocked password for this user (password set and unlocked)
(!! Attention: if no user is available with password, it is not possible anymore to login!!!)
-> downside: motd message does not show up anymore at login; no upside visible in auth logs (still same retries)

- check if account is locked (with ! = locked)
sudo cat /etc/shadow | grep "moon"
- set password = unlocks account
sudo passwd moon
- unlock account
sudo passwd -u moon
- lock account
sudo passwd -l moon

- set UsePAM to no
sudo vim /etc/ssh/sshd_config
UsePAM no
sudo systemctl restart sshd

- check if password authentication is enabled
ssh -v -o Batchmode=yes  nosuchuser@hostname
-> check for: debug1: Authentications that can continue: publickey,keyboard-interactive


4) clone setup files -> link / copy to user folder
git clone https://glcode80@github.com/glcode80/pubdotfiles.git
ln -s /home/moon/pubdotfiles/cmd_linux.sql /home/moon/
ln -s /home/moon/pubdotfiles/cmd_vim.sql /home/moon/
ln -s /home/moon/pubdotfiles/setup.sql /home/moon/
others: copy
cp /home/moon/pubdotfiles/sqltest.sql /home/moon/
cp /home/moon/pubdotfiles/.dbextprofiles.vim /home/moon/
cp /home/moon/pubdotfiles/.flake8 /home/moon/
cp /home/moon/pubdotfiles/.phpcsruleset.xml /home/moon/
cp /home/moon/pubdotfiles/.phpmdruleset.xml /home/moon/
cp /home/moon/pubdotfiles/.pylintrc /home/moon/
cp /home/moon/pubdotfiles/.screenrc /home/moon/
cp /home/moon/pubdotfiles/.vimrc /home/moon/
cp /home/moon/pubdotfiles/backup_data.sh /home/moon/
cp /home/moon/pubdotfiles/backup_sql.sh /home/moon/


4b) set up steal tracking / loadavg tracking
sudo apt install pv
sudo apt install sysstat
sudo apt install jq
crontab -e
mkdir /home/moon/steal
* * * * * /home/moon/pubdotfiles/steal_tracking.sh >> /home/moon/steal/steal.csv 2>&1
* * * * * /home/moon/pubdotfiles/loadavg_tracking.sh >> /home/moon/steal/loadavg.csv 2>&1
sudo pip3 install pandas
cp /home/moon/pubdotfiles/steal_analysis.py /home/moon/steal/
cp /home/moon/pubdotfiles/loadavg_analysis.py /home/moon/steal/
cp /home/moon/pubdotfiles/steal_alert.py /home/moon/steal/
cp /home/moon/pubdotfiles/toolsalert.py /home/moon/steal/
vim /home/moon/steal/steal_alert.py
crontab -e
26 * * * * /home/moon/steal/steal_alert.py >> /home/moon/logs/stealalert.txt 2>&1

rotate logs monthly automatically (keep 6 files, rotate monthly)
sudo vim /etc/logrotate.d/steal
/home/moon/steal/*.csv {
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

4c) set up logrotate for logs directory (logs and subdirectory, keep 6 files, rotate monhtly)
mkdir /home/moon/logs
sudo vim /etc/logrotate.d/ownlogs
/home/moon/logs/*.txt /home/moon/logs/*.log /home/moon/logs/*/*.txt /home/moon/logs/*/*.log {
  rotate 6
  monthly
  compress
  missingok
  notifempty
}

*/

5) install programs needed
sudo apt install screen
sudo apt install mc

5b) fix utf8 line drawing issues -> not needed
vim .bashrc
# fix utf8 line drawing issues
test "$TERM" = "putty" && export LC_ALL=C || export LC_ALL=en_US.utf8
export TERM=xterm-256color

6) set up git
sudo apt install git
mkdir git
git config --global credential.helper "cache --timeout=72000"
git config --global user.name "x"
git config --global user.email "x"
git config --global credential.https://github.com.glcode80 glcode80


7) set up vim
sudo apt install vim
-- git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
-- use own mirror
--  git clone https://github.com/glcode80/Vundle.vim.git /home/moon/.vim/bundle/Vundle.vim
-- offiical new mirror
git clone https://github.com/VundleVim/Vundle.vim.git /home/moon/.vim/bundle/Vundle.vim
PluginInstall

Update:
PluginUpdate


* for X11-forwarding working & dbext working *
install X11 server -> https://sourceforge.net/projects/vcxsrv/
-> if 'Cannot open Display': first install xauth!
sudo apt install xauth
sudo systemctl restart sshd

sudo apt install vim-gtk
-- debian new: sudo apt install vim-gtk3

sudo apt install libdbi-perl
sudo apt install libdbd-mysql-perl

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
sudo apt install build-essential cmake
sudo apt install python-dev python3-dev

-> bei Problem: selbst herunterladen:
cd ~/.vim/bundle/
git clone https://github.com/ycm-core/YouCompleteMe
cd ~/.vim/bundle/YouCompleteMe
./install.py
(on Raspi run it on one core only: YCM_CORES=1 ./install.py --gocode-completer)

-- on older version of ubuntu/debian -> check out last version
	cd ~/.vim/bundle/YouCompleteMe
	git checkout d98f896
	git submodule update --init --recursive
	./install.py

-- remove the git directory to save 200mb in space!
rm -rf .git
-- remove install tools again to save space [203MB + 56MB]
sudo apt remove build-essential cmake
sudo apt remove python-dev python3-dev


8) install python plugins
==> new: do it with python packages / pipx / local venv - TBD
sudo apt install python3
sudo apt install python3-pip
sudo pip3 install setuptools --upgrade
-- => Achtung pymysql upgrade > 0.9.3 -> need to update toolssql with latest version!
sudo pip3 install pymysql --upgrade
sudo pip3 install requests --upgrade
sudo pip3 install pytz --upgrade
sudo pip3 install flake8 --upgrade
sudo pip3 install autopep8 --upgrade
sudo pip3 install pylint --upgrade
sudo pip3 install tld --upgrade
sudo pip3 install matplotlib --upgrade
sudo pip3 install numpy --upgrade
sudo pip3 install pandas --upgrade
sudo pip3 install rotate-backups --upgrade
sudo pip3 install beautifulsoup4 --upgrade
sudo pip3 install lxml --upgrade
sudo pip3 install httpie --upgrade
-- wenn benötigt:
sudo pip3 install woocommerce --upgrade
sudo pip3 install pytesseract --upgrade
-- google tools: bigquery
sudo pip3 install --upgrade google-cloud-bigquery
sudo pip3 install --upgrade google-cloud-bigquery-storage


update only packages manually installed:
--> mit --upgrade ausführen (kommandos oben)

-- um ein package mit bestimter version zu installieren:
sudo pip3 install 'XXXXX==0.9.3' --force-reinstall
sudo pip3 show pymysql


update all packages with pip3 => NICHT MACHEN (besser so wie oben nur manuell installierte)
-- sudo pip3 freeze — local | grep -v ‘^\-e’ | cut -d = -f 1 | xargs -n1 sudo pip3 install -U

-- venv installieren
sudo apt install -y python3-venv
mkdir venv
cd ~/venv
python3 -m venv testvenv 
source ~/venv/testvenv/bin/activate
=> install with pip3 things here
deactivate


9) install php plugins (for Vim)
php needs to be installed to work (see below)
 php -v
 sudo apt install php8.1-cli
 sudo apt install php8.1-xml

Phpmd / PhpCS (Codesniffer)
=> use distribution packages instead:
sudo apt install phpmd php-codesniffer
phpmd -v
phpcs --version
phpcbf --version
-- show installed standards
phpcs -i
-- fix file formatting:
phpcbf --standard=PSR2 path/to/php/src


10) install lint for bash
sudo apt install shellcheck


11) ufw / fail2ban
sudo ufw enable
sudo ufw default allow outgoing
sudo ufw default deny incoming
sudo ufw allow ssh
sudo ufw logging on
sudo apt install fail2ban
sudo cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo vim /etc/fail2ban/jail.local
- bantime = default: 10m => change to 10000m (= 1 week)
bantime  = 10000m

Achtung: local file wird einfach nach conf file parsed
-> kann auch einfach nur die änderungen da rein machen!
[DEFAULT]
bantime = 1w

=> viel besser als beide files zu kopieren und anzupassen!
-- einfach direkt 1wk machen via sed
sudo sed -i 's/^bantime  = 10m/bantime  = 1w/g' /etc/fail2ban/jail.local


sudo fail2ban-client -t
sudo fail2ban-client start
sudo fail2ban-client status


12) MariaDB

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

* to disable division by zero error -> add this too
[mysqld]
sql_mode = 'IGNORE_SPACE,STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION'


* Fix error log for mysql to log file location
sudo vim /etc/mysql/conf.d/mysql.cnf
[mysqld]
log_error = /var/log/mysql/error.log


* Increase innodb_buffer_pool_size => this is the main mysql buffer for better performance
(check with mysqltuner -> sudo perl /home/moon/mysqltuner/mysqltuner.pl -- see below)
--> recommendation is to hold at least the whole DB in memory, if possible
--> default is 128MB

check value in mysql:
SHOW VARIABLES LIKE '%innodb_buffer_pool_size%';

sudo vim /etc/mysql/conf.d/mysql.cnf
[mysqld]
innodb_buffer_pool_size = 2G;

sudo systemctl restart mysqld

check other variables:
SHOW VARIABLES LIKE '%innodb_buffer_pool_size%';
SHOW VARIABLES LIKE '%query_cache%';
SHOW VARIABLES LIKE '%key_buffer%';
SHOW VARIABLES LIKE '%innodb_buffer_pool%';
SHOW VARIABLES LIKE '%table_size%';

error "table is full" on temp table, try:
tmp_table_size=64M;
max_heap_table_size=64M;
tmp_memory_table_size=64M;



13) Nginx

==> ATTENTION: Need to add nginx to unattended-upgrades!

-- get most recent version from source
http://nginx.org/en/linux_packages.html#Ubuntu

curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
    | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

gpg --dry-run --quiet --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg
-> goal: 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62

-- add sources for stable OR mainline branch ==> choose one (better to use mainline)
sudo vim /etc/apt/sources.list.d/nginx.list
# deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu jammy nginx
deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/mainline/ubuntu jammy nginx

-- set up to prefer nginx over distribution
(when compiling from source: not needed, as we dont have the package installed at all)
echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
    | sudo tee /etc/apt/preferences.d/99nginx

-- set up unattended upgrades for nginx from nginx repository (needs to b enabled)
sudo vim /etc/apt/apt.conf.d/50unattended-upgrades
Unattended-Upgrade::Allowed-Origins {
        "nginx:stable";
sudo unattended-upgrades --dry-run


sudo apt update
sudo apt remove nginx
sudo apt install nginx
sudo systemctl start nginx
sudo systemctl enable nginx

* hardcode variable for testing
map $host $geoip_country_code {
	default "XX";
	}


*** Compile nginx from source (with geoip2 module working) [ubuntu 22.04 nginx 18.0 has ssl3 problem, see error log]
("SSL routines::unexpected eof while reading")
sudo zcat /var/log/nginx/error.log* | grep "unexpected eof"


==> ATTENTION: do NOT update package (this will overwrite it with the latest version without dynamic modules!!) <==
 ===>> simply install without nginx/distribution package -> install only from source and update again manually
 (existing package from apt: simply apt remove first => then it will not be overwritten
 --> when it shows up in updates available: update and re-compile on test environment!


https://www.codedodle.com/nginx-geoip2-ubuntu.html
	https://github.com/leev/ngx_http_geoip2_module

-- add maxmind repo -> will use new version of geoipupdate
sudo add-apt-repository ppa:maxmind/ppa
sudo apt update
sudo apt upgrade
sudo apt install libmaxminddb0 libmaxminddb-dev mmdb-bin geoipupdate

-- check if all working ok
[Pfad ist /var/lib mit symlink to /usr/share, damit beide funktionieren]
sudo mmdblookup --file /var/lib/GeoIP/GeoLite2-Country.mmdb --ip 8.8.8.8

-- install dependencies to avoid errors (see in tutorial above for more errors)
sudo apt install libpcre3 libpcre3-dev
sudo apt install libssl-dev

mkdir -p /home/moon/nginx-compile
cd /home/moon/nginx-compile
git clone https://github.com/leev/ngx_http_geoip2_module.git
-- get configure paramters from a proper installation of latest apt package
nginx -V
-- use current verison number
wget https://nginx.org/download/nginx-1.22.1.tar.gz
tar -zxvf nginx-1.22.1.tar.gz

cd nginx-1.22.1

./configure  <<copy here all configure arguments from nginx -V>> --add-dynamic-module=../ngx_http_geoip2_module --with-compat

-- example 1.22.1 = stable (create own!!!)
./configure  --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-cc-opt='-g -O2 -ffile-prefix-map=/data/builder/debuild/nginx-1.22.1/debian/debuild-base/nginx-1.22.1=. -flto=auto -ffat-lto-objects -flto=auto -ffat-lto-objects -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC' --with-ld-opt='-Wl,-Bsymbolic-functions -flto=auto -ffat-lto-objects -flto=auto -Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie' --add-dynamic-module=../ngx_http_geoip2_module --with-compat

-- example 1.23.3 = mainline(create own!!!)
./configure  --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-cc-opt='-g -O2 -ffile-prefix-map=/data/builder/debuild/nginx-1.23.3/debian/debuild-base/nginx-1.23.3=. -flto=auto -ffat-lto-objects -flto=auto -ffat-lto-objects -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC' --with-ld-opt='-Wl,-Bsymbolic-functions -flto=auto -ffat-lto-objects -flto=auto -Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie' --add-dynamic-module=../ngx_http_geoip2_module --with-compat


-- compile it
sudo make
-- -> all good, install it
sudo make install

=> module in:
/usr/lib/nginx/modules/ngx_http_geoip2_module.so

-- enable module
sudo mkdir -p /usr/share/nginx/modules-available
cd /usr/share/nginx/modules-available
sudo vim /usr/share/nginx/modules-available/mod-http-geoip2.conf
  load_module /usr/lib/nginx/modules/ngx_http_geoip2_module.so;

cd /usr/share/nginx/modules-available

-- remove old non-existing modules
cd /etc/nginx/modules-enabled
ls
sudo rm *

-- make directories / link in new module
sudo mkdir -p /etc/nginx/modules-enabled/
sudo mkdir -p /etc/nginx/conf.d/
sudo ln -s /usr/share/nginx/modules-available/mod-http-geoip2.conf /etc/nginx/modules-enabled/
cd /etc/nginx/modules-enabled/
ls

-- restart and re-enable nginx
sudo nginx -t
sudo service nginx reload
sudo systemctl enable nginx
sudo systemctl restart nginx
sudo systemctl status nginx

-- remove compile directory again
rm -rf /home/moon/nginx-compile/

-- checks / re-install older version (attention: deletes own compiled version!!)
-- => remove old version with apt remove!
sudo apt policy nginx
sudo apt list --all-versions nginx
sudo apt install nginx=XXXX


*** END (compile nginx from source)

*** UPGRADE nginx installed from source
-> simply run like above -> install over old install, all should just work
-> "sudo make install" installiert die neue version

*** completly remove nginx installed from source
-- first remove via apt
sudo apt remove nginx
-- remove all config files too
sudo apt purge nginx

-- remove installed from source / all files manually
sudo service nginx stop
sudo apt purge nginx
sudo rm -rf /etc/nginx /etc/default/nginx /usr/sbin/nginx* /usr/local/nginx /var/run/nginx.pid /var/log/nginx
sudo rm -rf /usr/share/nginx /usr/lib/nginx /var/cache/nginx
sudo rm -rf /etc/init.d/nginx /etc/logrotate.d/nginx /var/lib/update-rc.d/nginx


* replace default conf file with old file with proper settings
sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.replaced
sudo cp /home/moon/pubdotfiles/nginx.conf_use   /etc/nginx/nginx.conf
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
-> for php 7.4: edit file!!

sudo service nginx restart
sudo ufw allow 80

-- enable gzip compression AND enable max file size upload php!! [for wordpress download manager -> upload files! also adjust php.ini!]
sudo vim /etc/nginx/nginx.conf
	gzip on;
	gzip_disable "mise6";
	gzip_vary on;
	gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
	client_max_body_size 128M;


14) PHP (all suggested for wordpress with fpm)

sudo apt install php8.1-{cli,fpm,common,mysql,curl,gd,mbstring,xml,xmlrpc,zip,tidy,imagick,soap,bcmath,intl}
sudo apt install php8.3-{cli,fpm,common,mysql,curl,gd,mbstring,xml,xmlrpc,zip,tidy,imagick,soap,bcmath,intl}

* upgrade from php 7.2 to php 7.4 *
https://php.watch/articles/Ubuntu-PHP-7.4

sudo add-apt-repository ppa:ondrej/php # Press enter when prompted.
sudo apt-get update

-- list current packages installed => to know which ones to re-install / remove => remove with purge!
dpkg -l | grep php
dpkg -l | grep php | awk '{print $2}'
dpkg -l | grep php > php-packages.txt


sudo systemctl enable php8.1-fpm
sudo systemctl restart php8.1-fpm
sudo systemctl status php8.1-fpm

Achtung: bei php7.4-fpm / php8.1-fpm
=> ini file neu schreiben / variablen anpassen (siehe oben)
sudo vim /etc/php/7.4/fpm/php.ini
sudo vim /etc/php/8.1/fpm/php.ini
sudo vim /etc/php/8.2/fpm/php.ini
sudo vim /etc/php/8.3/fpm/php.ini

=> go to wordpress dashboard and check if all modules are present

=> test:
php -v

=> check all packages, macke sure to have latest versions everywhere, check default ones, remove old ones
=> remove old packages
sudo systemctl disable php7.4-fpm

-- find packages existing to purge with grep/awk
dpkg -l | grep php
dpkg -l | grep php | awk '{print $2}'
dpkg -l | grep "php7.4-" | awk '{print "sudo apt purge " $2}'
dpkg -l | grep "php7.4-" | awk '{print $2}' | tr '\n' ' ' | awk '{print "sudo apt purge " $0}'
dpkg -l | grep "php8.0-" | awk '{print $2}' | tr '\n' ' ' | awk '{print "sudo apt purge " $0}'
dpkg -l | grep "php8.1-" | awk '{print $2}' | tr '\n' ' ' | awk '{print "sudo apt purge " $0}'
dpkg -l | grep "php8.2-" | awk '{print $2}' | tr '\n' ' ' | awk '{print "sudo apt purge " $0}'
dpkg -l | grep "php8.3-" | awk '{print $2}' | tr '\n' ' ' | awk '{print "sudo apt purge " $0}'
-- double check the ones with no version number (need to exist with proper version number!)
dpkg -l | grep "php-" | awk '{print "sudo apt purge " $2}'
=> no need to remove any of them, all good!

sudo apt purge php7.7 php7.4-common, ....

-- force older version of php cli
sudo update-alternatives --set php /usr/bin/php7.4
php -v

=> Adjust php.ini file!! [check above, do same as on default install!!]
sudo vim /etc/php/8.1/fpm/php.ini
  sudo vim /etc/php/7.4/fpm/php.ini
  
memory_limit = 512M
max_execution_time = 60
max_input_time=60
upload_max_filesize = 64M
post_max_size = 64M

sudo service php7.4-fpm restart
sudo service nginx restart

=> Adjust nginx config -> point to 8.1 instead of 7.4
grep -rn -e 'php7.4-fpm.sock'
grep -rl -e 'php7.4-fpm.sock' . | xargs sed -i 's/php7.4-fpm.sock/php8.1-fpm.sock/g'

sudo nginx -t
sudo service nginx reload

** Achtung: php7.4 auf ubuntu 20.04 -> braucht ondrej/php nicht mehr
--> Fehlermeldung im Wordpress "php intl" not present

--> remove ppa and re-install:
sudo add-apt-repository --remove ppa:ondrej/php
sudo apt remove php7.4-common
sudo apt install php7.4-common

14b) Install PHP with Ondrey / Sury packages -> PHP And Nginx
https://deb.sury.org/

=> ** Attention **: Need to add it to unattended-upgrades!! see above!!
--> for updates: needs to be based on proper version -> check/fix

** PHP Ondrej: **
https://deb.sury.org/

* Ubuntu: ppa:ondrej/php
https://launchpad.net/~ondrej/+archive/ubuntu/php/

sudo add-apt-repository ppa:ondrej/php
sudo apt update

--> remove again
sudo add-apt-repository --remove ppa:ondrej/php



** Nginx Ondrej: **
ppa:ondrej/nginx = stable
ppa:ondrej/nginx-mainline = latest

sudo add-apt-repository ppa:ondrej/nginx
sudo apt update

--> remove again
sudo add-apt-repository --remove ppa:ondrej/nginx


**** Debian: php/nginx/geoip plugin
https https://packages.sury.org/php/README.txt -d
https https://packages.sury.org/nginx/README.txt -d
---> commands in here, check & run
sudo apt -y install libnginx-mod-http-geoip2

==> add to unattened-upgrades -> see above



15) geoip database & update script
sudo apt install geoip-bin
-> directory: /usr/share/GeoIP/
geoiplookup 8.8.8.8

-- install new geoipupdate program and config
sudo apt install geoipupdate
sudo vim /home/moon/GeoIP.conf

# GeoIP.conf file - used by geoipupdate program to update databases
# from http://www.maxmind.com
# save to: /home/moon/GeoIP.conf
# run as: sudo /usr/bin/geoipupdate -f /home/moon/GeoIP.conf -d /usr/share/GeoIP -v
UserId XXXXXXXXXXXXX
# AccountID YOUR_ACCOUNT_ID_HERE # only for newer version of geoipupdate (>3.3.1)
LicenseKey XXXXXXXXXXXXX
# update everything -> disabled
# ProductIds GeoLite2-ASN GeoLite2-City GeoLite2-Country
# update only country file
ProductIds GeoLite2-Country
# EditionIDs GeoLite2-ASN GeoLite2-City GeoLite2-Country  # only for newer version of geoipupdate (>3.3.1)

test geoipupdate:
sudo /usr/bin/geoipupdate -f /home/moon/GeoIP.conf -d /usr/share/GeoIP -v
-- with default location
sudo /usr/bin/geoipupdate -v

** add cron job to update weekly (seems to be no timer)
7 16 * * 3 /usr/bin/geoipupdate -v >> /home/moon/logs/sudologs.txt 2>&1


16) remove/adjust message of the day / motd - https://oitibs.com/ubuntu-16-04-dynamic-motd/
cd /etc/update-motd.d/
sudo chmod -x /etc/update-motd.d/10-help-text
sudo chmod -x /etc/update-motd.d/50-motd-news 
sudo chmod -x /etc/update-motd.d/80-livepatch
sudo chmod -x /etc/update-motd.d/88-esm-announce

-- when adding own message: -> c) below
sudo chmod -x /etc/update-motd.d/50-landscape-sysinfo

-- adjust Debian
-- a) remove warranty
sudo rm /etc/motd

-- b) remove kernel message line (add more detailed below)
sudo chmod -x /etc/update-motd.d/10-uname

-- c) add own system information message (like ubuntu)
sudo cp /home/moon/pubdotfiles/45-sysinfo /etc/update-motd.d/
sudo chmod 755 /etc/update-motd.d/45-sysinfo




--  sudo apt install update-motd update-notifier-common landscape-common

-- custom reboot checker based on kernel available/kernel running
sudo cp /home/moon/pubdotfiles/90-reboot-check /etc/update-motd.d/

17) monit
sudo apt install monit
-> check in install

sudo monit -t
sudo service monit reload
-> then
sudo monit summary
sudo monit status nginx
sudo monit status

logfile:
sudo vim /var/log/monit.log


18) fstrim timer -> weekly to daily (empty up empty space on lvm-thin volumes / on dedi)
sudo vim /lib/systemd/system/fstrim.timer
weekly -> daily

sudo systemctl daemon-reload
sudo systemctl list-timers

-- run manually before backup:
sudo /usr/sbin/fstrim --fstab --verbose


19) unattended-upgrades
-> should be installed by default
- standard setting installs only security updates

0) install
sudo apt install unattended-upgrades

a) enable updates:
sudo vim /etc/apt/apt.conf.d/20auto-upgrades
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";

b) define what should be updated / add re-starts etc.
sudo vim /etc/apt/apt.conf.d/50unattended-upgrades

-> default: only security updates (<distro>-security)
add:
//	"${distro_id}:${distro_codename}-updates";
//Unattended-Upgrade::Remove-Unused-Dependencies "false";

-- add other (non distro updates)
-> check with:
apt policy

==> check only the non standard ones -> compare to currently active
apt policy | grep o= | grep -v Ubuntu | grep -v Debian
sudo unattended-upgrades --dry-run -v

-- check next timer run
sudo systemctl status apt-daily-upgrade.timer

(on Ubuntu: <o-value>:<a-value> -> wenn nichts steht einfach :)
(on Debian/Kali: orign=xxx)
add, eg.:

-- -> write conf file /etc/apt/apt.conf.d/52ownallowedorigins

-- Debian/Kali
sudo vim /etc/apt/apt.conf.d/52ownallowedorigins

Unattended-Upgrade::Allowed-Origins {
		"origin=Proxmox";			// debian - LEGACY - check
		"origin=Kali";				// kali - LEGACY - check
		"deb.sury.org:bookworm";	// sury - php/nginx - debian bookworm
        "deb.sury.org:trixie";      // sury - php/nginx - debian trixie
};

-- Ubuntu ("origin" term not allowed)
sudo vim /etc/apt/apt.conf.d/52ownallowedorigins

Unattended-Upgrade::Allowed-Origins {
		"matrix.org:";				// ubuntu
		"nginx:stable";				// ubuntu
		"LP-PPA-ondrej-php:focal";	// ubuntu 20.04 / focal
		"LP-PPA-ondrej-php:jammy";	// ubuntu 22.04 / jammy
		"LP-PPA-ondrej-php:noble";	// ubuntu 24.04 / noble		
		"LP-PPA-ondrej-nginx:focal";	// ubuntu 20.04 / focal
		"LP-PPA-ondrej-nginx:jammy";	// ubuntu 22.04 / jammy
		"LP-PPA-ondrej-nginx:noble";	// ubuntu 24.04 / noble
		"LP-PPA-ondrej-nginx-mainline:focal";	// ubuntu 20.04 / focal
		"LP-PPA-ondrej-nginx-mainline:jammy";	// ubuntu 22.04 / jammy
		"LP-PPA-ondrej-nginx-mainline:noble";	// ubuntu 24.04 / noble				
		"LP-PPA-maxmind:jammy";		// ubuntu 22.04 / jammy
		"LP-PPA-maxmind:noble";		// ubuntu 24.04 / noble
};


-- reboot
//Unattended-Upgrade::Automatic-Reboot "false";
//Unattended-Upgrade::Automatic-Reboot-Time "02:00";


-- allow conffile prompts confirmation -> by default keep, e.g. for cloud-init updates
-- -> write conf file /etc/apt/apt.conf.d/51conffileprompt
sudo vim /etc/apt/apt.conf.d/51conffileprompt

// by default no prompt for change in conf files
DPkg::Options {
        "--force-confold";
        "--force-confdef";
};


c) run manually / dry-run -> check origins all ok?
sudo unattended-upgrades --dry-run -v
sudo unattended-upgrades -v

d) check logs
cd /var/log/unattended-upgrades


20) make sure ntp timeserver synchronization is working
-> should be set up by default
Attention: incoming port 123 UDP needs to be open in Robot Firewall

-- check if sync is ok
timedatectl status

-- check logs / force sync by restarting the daemon
sudo systemctl status systemd-timesyncd.service
sudo systemctl restart systemd-timesyncd.service


21 ) manage max file size of journald -> set 300MB limit

-- check current usage
journalctl --disk-usage
-- delete everything except 300MB
sudo journalctl --vacuum-size=300M

-- set default max limit of 300MB and restart service
sudo vim /etc/systemd/journald.conf
SystemMaxUse=300M

sudo service systemd-journald restart
sudo service systemd-journald status


***********************************
*** Fine-tune gold master       ***
***********************************

2) add private key
vim ~/.ssh/id_ed25519
vim ~/.ssh/id_ed25519.pub
chmod 600 ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519.pub


3) firewall: open ports needed
sudo ufw status

4) * mysql *
sudo mysql

- a) change root password
-- neu: ubuntu 22.04:
sudo mysql -e "UPDATE mysql.global_priv SET priv=json_set(priv, '$.plugin', 'mysql_native_password', '$.authentication_string', PASSWORD('xxxx')) WHERE User='root';"


- b) drop default schema
DROP SCHEMA Playground;
DROP USER 'Analyst'@'localhost';
FLUSH PRIVILEGES;
exit;

- c) disable overall
sudo systemctl disable mariadb.service
sudo systemctl enable/disable/status/start/stop/restart mariadb.service

- d) transfer data -> see below

5) nginx: start/stop + setup services
sudo systemctl disable nginx
sudo systemctl enable/disable/status/start/stop/restart nginx


7) adjust monit
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
  # using TLSV1 with timeout 30 seconds # attention: need 1.1 on Ubuntu 20.04
  using TLSV1.1 with timeout 30 seconds
set alert **RECEIVING_EMAIL** #email address which will receive monit alerts
sudo monit -t
sudo monit restart


8) nginx: default profile, certificate, certbot, settings

9) fail2ban: nginx-wordpress, nginx-default, ...
sudo fail2ban-client unban --all

11) steal-alert
clear / add monitoring

12) enable ubuntu kernel live patch updates
-> create ubuntu one account: https://ubuntu.com/advantage
-> get 3 free personal tokens

sudo ua attach <token>
sudo ua enable livepatch
sudo canonical-livepatch status
sudo canonical-livepatch status --verbose
-- remove again
sudo ua status
sudo ua disable <service name>
sudo ua detach
sudo snap disable canonical-livepatch
sudo snap remove canonical-livepatch
-> restart


****************************************
*** Additional settings/adjustments  ***
****************************************

0) set up backup rotation for backups directory
https://github.com/xolox/python-rotate-backups
mkdir /home/moon/backups
sudo pip3 install rotate-backups
-- > Achtung: --dry-run muss am Anfang stehen!
-- zwei verschiedene machen für sql backups und tar backups -> immer für jeden namen und sql/tar separat!
-- -> keep 7 days, 4 weeks, 4 months, 2 years
-- => do two different ones for sql backups (daily) and data backups (weekly)?

-- nur sql
rotate-backups --dry-run --daily=8 --weekly=4 --monthly=6 --yearly=2 --include='*xxxx.sql.gz' /home/moon/backups 
-- nur tar
rotate-backups --dry-run --daily=8 --weekly=4 --monthly=6 --yearly=2 --include='*xxxx.tar.gz' /home/moon/backups 

-- -> anschliessend in crontab rein (täglich ein mal machen, natürlich ohne dry-run!) -> gleich wie backups (sudo oder nicht)
crontab -e
17 3 * * * /usr/local/bin/rotate-backups --daily=8 --weekly=4 --monthly=6 --yearly=2 --include='*xxxx.sql.gz' /home/moon/backups >> /home/moon/logs/rotatebackups.txt 2>&1
18 3 * * * /usr/local/bin/rotate-backups --daily=8 --weekly=4 --monthly=6 --yearly=2 --include='*xxxx.tar.gz' /home/moon/backups >> /home/moon/logs/rotatebackups.txt 2>&1


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
sudo apt iozone3
iozone -e -I -a -s 100M -r 4k -i 0 -i 1 -i 2 
[-f /path/to/file]
- cpu: sysbench -> check events per second / total number of events
sudo apt install sysbench
sysbench --time=10 --cpu-max-prime=10000 cpu run
sysbench --time=10 --cpu-max-prime=20000 cpu run
sysbench --threads=4 --time=10 --cpu-max-prime=20000 cpu run
sysbench --test=memory run
-- first prepare test files in its own directory
mkdir sysbench
cd sysbench
sysbench --test=fileio --file-test-mode=seqwr prepare

sysbench --test=fileio --file-test-mode=seqwr run
sysbench --test=fileio --file-test-mode=rndwr run

sysbench --test=fileio --file-test-mode=seqrd run
sysbench --test=fileio --file-test-mode=rndrd run

sysbench --test=fileio --file-test-mode=rndrw run

 -> test mode {seqwr, seqrewr, seqrd, rndrd, rndwr, rndrw}
-- remove test data again
rm -rf /home/moon/sysbench

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

-- new: ubuntu 22.04
sudo mysql -e "UPDATE mysql.global_priv SET priv=json_set(priv, '$.plugin', 'mysql_native_password', '$.authentication_string', PASSWORD('xxxx')) WHERE User='root';"


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
sudo perl /home/moon/mysqltuner/mysqltuner.pl


* Mysql Tuning script tuning-primer.sh
cd ~
git clone https://github.com/BMDan/tuning-primer.sh/


** enable mariadb query log to file -> attention: performance killer! **
sudo mysql
SET GLOBAL general_log_file='/var/log/mysql/mycustom.log';
SET GLOBAL log_output = 'FILE';
SET GLOBAL general_log = 1;
SHOW VARIABLES LIKE "general_log%";

-- disable again
SET GLOBAL general_log = 0;

-- enable persistant (in config file)
sudo vim /etc/mysql/mariadb.conf.d/50-server.cnf
#general_log_file       = /var/log/mysql/mysql.log
#general_log            = 1


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
- need "enabled = true"
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
(default findtime = 10min, default bantime fixed to 1 year, maxretry = 5)

* uncomment -> to make sure monit still works for mysql
ignoreip = 127.0.0.1/8 ::1

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


-- 20.04
sudo apt install python3-certbot-nginx

sudo certbot --nginx -d example.com -d www.example.com

-- to install without email / non-interaticve / agree tos
sudo certbot --nginx --agree-tos --register-unsafely-without-email
sudo certbot --nginx --agree-tos --register-unsafely-without-email --non-interactive 
sudo certbot --nginx --agree-tos --register-unsafely-without-email --non-interactive -d example.com -d www.example.com

sudo certbot certificates

** dry run:
sudo certbot renew --dry-run


certbot update script: ==> NOT needed anymore (certbot adds a timer)
check:
sudo systemctl list-timers

*** enable http2 for both ip4 and ip6 -> check and adjust/enable
(ipv6only=on is not needed - enabled by default)
listen [::]:443 ssl http2;
listen 443 ssl http2;

cd /etc/nginx/conf.d/
grep -rn -ie "443 ssl" *.conf
grep -rn -ie "443 ssl" *.conf | grep http2
grep -rn -ie "443 ssl" *.conf | grep -v http2

sed -i 's/listen 443 ssl;/listen 443 ssl http2;/g' *.conf
sed -i 's/listen \[::\]:443 ssl;/listen \[::\]:443 ssl http2;/g' *.conf
sed -i 's/listen \[::\]:443 ssl ipv6only=on;/listen \[::\]:443 ssl http2;/g' *.conf

** Achtung: nginx Warnung "nginx: [warn] protocol options redefined for"
-> ein Socket z.B. 443 muss überall die gleichen Einstellungen haben (z.B. 443 http2)
  -> es ist eh schon automatisch so --> überall auch so rein schreiben (auch default empty)

"use the "http2" directive instead"
new format for nginx >= 1.25.1 is

server {
    listen  xxx.xxx.xx.xx:443 ssl;
    http2  on;


sudo nginx -t
sudo systemctl restart nginx
sudo systemctl status nginx


*** robots.txt wordpress exclustions ***
User-agent: *
Disallow: /wp-admin/
Disallow: /*add-to-cart=*
Disallow: /*add_to_wishlist=*
Disallow: /cart/
Disallow: /de/warenkorb/
Disallow: /*checkout/
Disallow: /de/kasse/
Disallow: /my-account/
Disallow: /de/mein-konto/


*/
*** Nginx FastCGI Page Cache -> caches pages in memory (like varnish) ***
-> test by checking response headers: HIT/MISS/BYPASS
curl -I https://example.com/
=> Attention: expiry time is in nginx.conf for global cache, in domain.conf file for specific domain
[specific domain setting seems to be the most important setting] -> to be sure, set both to same time
==> new best practice: set both to 20m to avoid caching issues, and to protect for high traffic

/var/run = ram disk! -> can also put to normal disk. be careful with size of cache
/etc/nginx = normal disk -> instead of 50ms around 60-70ms (no big difference)

sudo vim /etc/nginx/nginx.conf

# ** NGINX PAGE CACHE START - nginx.conf http - options: 60m, 5h, 5d - adjust in conf too! **

# fastcgi_cache_path /var/run/nginxcacheGLOBAL levels=1:2 keys_zone=cacheGLOBAL:100m inactive=7d;
fastcgi_cache_path /var/run/nginxcacheGLOBAL levels=1:2 keys_zone=cacheGLOBAL:300m inactive=20m;

# can have second cache for other page with different params, if no intention to share
# fastcgi_cache_path /var/run/nginxcacheSITE1 levels=1:2 keys_zone=cacheSITE1:100m inactive=20m;
# fastcgi_cache_path /var/run/nginxcacheSITE2 levels=1:2 keys_zone=cacheSITE2:100m inactive=20m;

fastcgi_cache_key "$scheme$request_method$host$request_uri";
# for geoip cache, add countrycode (needs working geoip module!)
# fastcgi_cache_key "$scheme$request_method$host$request_uri$geoip_country_code";

fastcgi_cache_use_stale error timeout invalid_header http_500;
fastcgi_ignore_headers Cache-Control Expires Set-Cookie;
# ** NGINX PAGE CACHE END - nginx.conf http**

+ NEW !!: add $geoip_country_code to log file as test!
-- -> '"$http_user_agent" "$http_x_forwarded_for" "$geoip_country_code"';


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
sudo rm -rf /etc/nginx/nginxcacheGLOBAL/*

*/Wordrepss Plugin to purge -> Nginx Cache Tim Krüss
  /var/run/nginxcacheGLOBAL
  (or custom cache path)

benchmark testing: loader.io


*** Nginx blocking of bad bot traffic ***
https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker

sudo wget https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/install-ngxblocker -O /usr/local/sbin/install-ngxblocker
sudo chmod +x /usr/local/sbin/install-ngxblocker

cd /usr/local/sbin
-- dry run
sudo ./install-ngxblocker
-- execute
sudo ./install-ngxblocker -x
sudo chmod +x /usr/local/sbin/setup-ngxblocker
sudo chmod +x /usr/local/sbin/update-ngxblocker
cd /usr/local/sbin/
-- dry run => don't do it in prod -> add it manually + add own IP manually
[wirklich NICHT machen -> hardcoded files / removes links!]
sudo ./setup-ngxblocker -v /etc/nginx/conf.d -e .conf

-- ** manual addition to server block 443 at the end (do not add to 80 only to 443) - DO IT MANUALLY!
    ##
    # Nginx Bad Bot Blocker Includes
    # REPO: https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker
    ##
	include /etc/nginx/bots.d/ddos.conf; 
 	include /etc/nginx/bots.d/blockbots.conf;
-- ** manual addition to server block 443

sudo vim /etc/nginx/bots.d/whitelist-ips.conf
--> add own ip
OWNIP	0;

sudo vim /etc/nginx/conf.d/botblocker-nginx-settings.conf
--> erste zeile auskommentieren, sonst funktioniert certbot update nicht!! [TBD]
# server_names_hash_bucket_size 256;


sudo nginx -t
sudo service nginx reload

-- to remove everything again:
remove bots.d directory
remove in conf.d -> both files (botblocker-nginx-settings.conf / globalblacklist.conf)
comment out addition to each conf file


-- daily update -> logs file / mailgun email notification
sudo crontab -e
00 22 * * * /usr/local/sbin/update-ngxblocker >> /home/moon/logs/sudologs.txt 2>&1
-- option with mailgun
00 22 * * * /usr/local/sbin/update-ngxblocker -g yourname@yourdomain.com -d yourdomain.com -a mailgun api key -f from@yourdomain.com

-- check if it works
curl -A "Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.96 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)" -I https://yourdomain.com
curl -A "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)" -I https://yourdomain.com
--> 200

curl -A "Xenu Link Sleuth/1.3.8" -I https://yourdomain.com
curl -A "Mozilla/5.0 (compatible; AhrefsBot/5.2; +http://ahrefs.com/robot/)" -I https://yourdomain.com
--> 52/56/92

curl -I https://yourdomain.com -e http://100dollars-seo.com
curl -I https://yourdomain.com -e http://zx6.ru
--> 52/56/92

-- check top referres & top user agents
sudo tail -10000 /var/log/nginx/access.log | awk '$11 !~ /google|bing|yahoo|yandex|MYWEBSITE.com/' | awk '{print $11}' | tr -d '"' | sort | uniq -c | sort -rn | head -50
sudo tail -50000 /var/log/nginx/access.log | awk '{print $12}' | tr -d '"' | sort | uniq -c | sort -rn | head -50

-- NEXT STEP: add fail2ban for 444 errors
https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/tree/master/_fail2ban_addon/filter.d

-- check 444 error codes by IP => candidates to block
sudo cat /var/log/nginx/access.log | awk '{if ($9 == "444") print $1}' | sort -n | uniq -c | sort -nr | head -20


*** Ngxinx redirect based on country code from IP ***
https://dzone.com/articles/nginx-with-geoip-maxmind-database-to-fetch-user-ge
https://www.howtoforge.com/tutorial/how-to-use-geoip-with-nginx-on-ubuntu-16.04/

1) install / load geoip module

-- 20.04
sudo vim /etc/apt/sources.list.d/nginx.list

# Nginx repository
deb [arch=amd64,arm64] http://nginx.org/packages/ubuntu/ focal nginx
deb-src http://nginx.org/packages/ubuntu/ focal nginx

sudo wget https://nginx.org/keys/nginx_signing.key
sudo apt-key add nginx_signing.key

sudo apt update
sudo apt install nginx-module-geoip

-- 18.04
	sudo apt install nginx-module-geoip

sudo vim /etc/nginx/nginx.conf
-> beginning
load_module "modules/ngx_http_geoip_module.so";



+ NEW !!: add $geoip_country_code to log file as test!
-- -> '"$http_user_agent" "$http_x_forwarded_for" "$geoip_country_code"';

-- --> analyze logs to be sure:
sudo cat /var/log/nginx/access.log | awk '{print $NF}' | sort -n | uniq -c | sort -nr | head -20


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


*** Nginx block countries based on country code (only allow certain countries)
# *** START: block by country code (above server section)
# --> actual block in server 443 section
map $geoip_country_code $allowed_country {
    default no;
    CH yes;
    DE yes;
    # US yes;
}
# *** END: block by country code (map section)

# *** START: block by country code (server section - 80 and 443)
if ($allowed_country = no) {
    return 444;
    # return 403;
}
# *** START: block by country code (server section - 80 and 443)


*** Nginx do not leak nginx version in headers

    # Prevent nginx HTTP Server Detection (server section - 80 and 443 or http section in nginx.conf)
    server_tokens off;


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



** Whitelist certain resources based on IP - block everything else **

## START: limit wp-login and wp-json/wc/ by IP whitelist only!
location ~* wp-login.php {
    # allow xxx.xxx.xxx.xxx;
    deny all;
    fastcgi_pass unix:/run/php/php7.4-fpm.sock;
    include         fastcgi_params;
    fastcgi_param   SCRIPT_FILENAME    $document_root$fastcgi_script_name;
    fastcgi_param   SCRIPT_NAME        $fastcgi_script_name;
}

location ~* wp-json/wc/ {
    # allow xxx.xxx.xxx.xxx;
    deny all;
    try_files $uri $uri/ /index.php$is_args$args;
    fastcgi_pass unix:/run/php/php7.4-fpm.sock;
    include         fastcgi_params;
    fastcgi_param   SCRIPT_FILENAME    $document_root$fastcgi_script_name;
    fastcgi_param   SCRIPT_NAME        $fastcgi_script_name;
}
## END: limit wp-login and wp-json/wc/ by IP whitelist only!


** Avoid 504 gateway timeout / increase timeout
- default is 60 seconds
- happens, for example, in woocommerce bulk translations
- add to config (for sites -> just after fastcgi_pass
  fastcgi_pass ... 
  fastcgi_read_timeout 300;

*** Nginx password protect subfolder with http auth ***
1) create htpasswd file in the respective directory with apache2-utils
sudo apt-get install apache2-utils
htpasswd -c /var/www/foldertoprotect/.htpasswd exampleuser

2) adjust nginx configuration (in config for respective web page)
location /foldertoprotect {
    auth_basic "Restricted";
    auth_basic_user_file /var/www/foldertoprotect/.htpasswd;
}
sudo nginx -t
sudo service nginx reload



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


*/* optimize wordpress **
-- limit post revisions
vim wp-config.php
define('WP_POST_REVISIONS', 10);

-- alle alten post revisions löschen
DELETE FROM wp_posts WHERE post_type = "revision";


***********************************
*** Install Wordpress-cli  ***
***********************************
https://wp-cli.org/#installing)

curl https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /home/moon/wp-cli.phar
chmod +x /home/moon/wp-cli.phar
sudo mv /home/moon/wp-cli.phar /usr/local/bin/wp

-- update
sudo wp cli update

-- to install only minor updates, e.g. from 5.8.1 to 5.8.5 [apply latest security updates!]:
wp core update --minor

-- to install update to latest version (run in folder or add --path=)
wp core update

-- to force (re)install (specific version), without content-directory
wp core download --force --skip-content --version=6.0.1 
wp core download --force --skip-content --version=5.8

-- to update/run wp cron events [next step: replace normal wp cron]
wp cron event list
wp cron event run --due-now

=> run update as user moon in folder xxx (add to normal crontab)
wp core update --minor --path=/var/www/FOLDER

-- replace wp cron (loading on each page load with proper cron job)
define('DISABLE_WP_CRON', true);

=> might lead to problems - TBD


*****************************************
*** Install Postfix / Mailgun emails  ***
*****************************************
-> mailgun as smtp relay -> server can send emails (only postfix needed, mailutils only for testing)

sudo debconf-set-selections <<< "postfix postfix/mailname string $HOSTNAME"
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"

sudo apt install -y postfix
sudo apt install -y libsasl2-modules

sudo systemctl status postfix
sudo systemctl start postfix
sudo systemctl enable postfix

sudo postfix status

-- set up config for mailgun
sudo vim /etc/postfix/main.cf

--> append info to end of file
relayhost = smtp.mailgun.org:587
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = static:postmaster@<DOMAIN.COM>:<PASSWORD>
smtp_sasl_security_options = noanonymous

sudo systemctl restart postfix

-- send test email
sudo apt install mailutils

mail -V
mail -s 'test from server via mailgun' <receipient-email>
ctrl-D to send

-- check logs
sudo vim /var/log/mail.log

-- check/flush queue
sudo postqueue -p
sudo postqueue -f


***************************************************
*** Replace Ubuntu Archive with local mirror    ***
***************************************************

sudo vim /etc/apt/sources.list

-- use de mirrors by default
sudo sed -i -e 's/http:\/\/archive/http:\/\/de.archive/' /etc/apt/sources.list
sudo sed -i -e 's/http:\/\/security/http:\/\/de.archive/' /etc/apt/sources.list

sudo apt update


***********************************
*** Error dpkg sudo apt update -> e.g. mariadb-server    ***
***********************************
Errors: dpkg: error processing archive
Errors: dpkg-deb: error: paste subprocess was killed by signal (Broken pipe)
-> wichtig nach deinstallieren noch autoremove zu machen!

sudo apt remove mariadb-server
sudo apt autoremove
sudo apt update
sudo apt upgrade
sudo apt install mariadb-server

