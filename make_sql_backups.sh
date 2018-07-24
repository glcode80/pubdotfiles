#! /bin/sh
today=$(date '+%Y-%m-%d-%H-%M-%S');
echo "$(date '+%Y-%m-%d %H:%M:%S') - Start - Make SQL database backups - XXX"
mysqldump -u USERNAME -pPASSWORD DBNAME > /home/USERNAME/backups/"$today-XXX.sql"
gzip /home/UERNAME/backups/"$today-XXX.sql"
echo "$(date '+%Y-%m-%d %H:%M:%S') - End - Make SQL database backups - XXX"

