#! /bin/sh
echo "$(date '+%Y-%m-%d %H:%M:%S') - Start - Make rclone"
rclone copy /home/USERNAME/backups BUCKET:FOLDER/ -v --fast-list --config /home/USERNAME/.config/rclone/rclone.conf
echo "$(date '+%Y-%m-%d %H:%M:%S') - End - Make rclone"
