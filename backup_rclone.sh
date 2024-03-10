#! /bin/bash
echo "$(date '+%Y-%m-%d %H:%M:%S') - Start - Backup rclone"
# rclone copy /home/moon/backups BUCKET:FOLDER/ -v --fast-list --config /home/moon/.config/rclone/rclone.conf
rclone copy /home/moon/backups BUCKET-crypt:/ -v --fast-list --config /home/moon/.config/rclone/rclone.conf
echo "$(date '+%Y-%m-%d %H:%M:%S') - End - Backup rclone"
