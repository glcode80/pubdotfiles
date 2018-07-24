#! /bin/sh
today=$(date '+%Y-%m-%d-%H-%M-%S');
echo "$(date '+%Y-%m-%d %H:%M:%S') - Start - Make data folders backup"
# sudo tar -zcf /home/USERNAME/backups/"$today-html-folders.tar.gz" /var/www/FOLDERNAME/
# NEW with slowing down to use only around 30% of CPU -> limit to 5mb/s instead of 15
sudo tar -zcf - /var/www/FOLDERNAME/ | pv -L 5m -q >/home/USERNAME/backups/"$today-html-folders.tar.gz"
echo "$(date '+%Y-%m-%d %H:%M:%S') - End - Make data folders backup"

