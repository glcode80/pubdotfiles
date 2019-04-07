#!/bin/bash

# tracks steal over a certain period via iostat -> json output, ignores initial value
# uses jq to parse json -> sudo apt install jq
# then save to text file

# set up cron job to save to file every minute
# * * * * * /home/moon/pubdotfiles/steal_tracking.sh >> /home/moon/steal_tracking.txt 2>&1

# Define input variables -> put to 60 seconds for per minute stats
interval=60

# Calculate variables -> get beginning of minute time
# save as "date, hour, minute" for easy csv analysis
# starttime=$(date '+%Y-%m-%d-%H-%M-%S');
starttime=$(date '+%Y-%m-%d,%H,%M');

steal=$(iostat -cy -d $interval 1 -o JSON | jq '.sysstat.hosts[0].statistics[0]["avg-cpu"].steal')

echo "$starttime,$steal"
