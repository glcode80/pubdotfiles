*****************************************
goldmaster after install [enable=auto-start]
 => everything enabled by default on master + port 80 open (443 / 3306 closed)
*****************************************

sudo apt update
sudo apt upgrade
sudo hostnamectl set-hostname [HOSTNAME]
sudo dpkg-reconfigure tzdata 

- firewall: open ports needed
sudo ufw status

- mysql: add/remove default DB/user 'analyst' + start/stop service overall + mysqltune?
sudo systemctl enable mariadb.service
sudo systemctl disable mariadb.service
sudo systemctl enable/disable/status/start/stop/restart mariadb.service

- nginx: start/stop + setup services
sudo systemctl enable nginx
sudo systemctl disable nginx
sudo systemctl enable/disable/status/start/stop/restart nginx

- php-fpm: adjsut/finetune settings
sudo systemctl enable php7.2-fpm
sudo systemctl disable php7.2-fpm
sudo systemctl enable/disable/status/start/stop/restart php7.2-fpm

- nginx: default profile, certificate, certbot, settings
- php/wordpress: caching (memcached/nginx cache/opcache/settings)
- monit: install

