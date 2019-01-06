#!/bin/bash

# Define overall variables
datadir="/var/www/"
backupdir="/home/moon/backups/"

# will slow down the process to not occupy 100% of cpu
# Attention: pv needs to be installed to slow down
slowdown="0"

# Calculate variables
today=$(date '+%Y-%m-%d-%H-%M-%S');

# arguments = folders in datadir to back up

echo
echo "$(date '+%Y-%m-%d %H:%M:%S') - Start - Data folders backup"

# create directory, if it doesn't exist yet
mkdir -p $backupdir

if [ $# -eq 0 ]
    then
        echo "No arguments supplied"
        echo "Please provide folder names within $datadir to export, options:"
        eval "ls $datadir"

else
    echo "Backup into individual files"
    for foldername in "$@"
    do
        fullfoldername=$datadir$foldername/
        filename="$backupdir$today-$foldername.tar.gz"

        echo
        echo "* Processing folder: $fullfoldername"

        # check if folder exists
        if [ -d "$fullfoldername" ]; then
            if [ $slowdown = "1" ]; then
                # NEW with slowing down to use only around 30% of CPU -> limit to 5mb/s instead of 15
                executestring="tar -zcf - $fullfoldername | pv -L 5m -q > $filename"
            else
                executestring="tar -zcf $filename $fullfoldername"
            fi
            # echo "$executestring"
            eval "$executestring"

        else
            echo "Error - folder '$fullfoldername' does NOT exist"
        fi

    done
    fi

echo
echo "$(date '+%Y-%m-%d %H:%M:%S') - End - Date folders backup"
echo
