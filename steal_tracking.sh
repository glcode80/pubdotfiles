#!/bin/bash

# tracks steal over a certain period via iostat -> json output, ignores initial value
# uses jq to parse json -> sudo apt install jq
# then save to text file

# 1) copy over file
# cp /home/moon/pubdotfiles/steal_tracking.sh /home/moon/steal/steal_tracking.sh
# 2) cron job:
# * * * * * /home/moon/steal/steal_tracking.sh >> /home/moon/steal/steal.csv 2>&1

# Define input variables -> put to 60 seconds for per minute stats
interval=60

# Calculate variables -> get beginning of minute time
# save as "timestamp, steal"
# starttime=$(date '+%Y-%m-%d,%H,%M');
starttime=$(date '+%Y-%m-%dT%H:%M:00');

steal=$(iostat -cy -d $interval 1 -o JSON | jq '.sysstat.hosts[0].statistics[0]["avg-cpu"].steal')

echo "$starttime,$steal"
