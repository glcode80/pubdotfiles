#!/bin/bash

# tracks loadavg -> run it every minute and save 1min loadavg to csv, then parse with paython

# 1) copy over file
# cp /home/moon/pubdotfiles/loadavg_tracking.sh /home/moon/steal/loadavg_tracking.sh
# 2) cron job:
# * * * * * /home/moon/steal/loadavg_tracking.sh >> /home/moon/steal/loadavg.csv 2>&1


# Calculate variables -> get beginning of minute time
# save as "timestamp, loadavg1min"
# starttime=$(date '+%Y-%m-%d,%H,%M');
starttime=$(date '+%Y-%m-%dT%H:%M:00');

loadavg=$(cat /proc/loadavg | awk '{print $1}')

echo "$starttime,$loadavg"
