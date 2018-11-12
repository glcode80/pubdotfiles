#!/bin/bash

echo "$(date '+%Y-%m-%d %H:%M:%S') - Start - Script to delete if not enough space, then run backup"

DIR="/home/USERNAME/backups"
reqSpace=6000000

availSpace=$(df "$HOME" | awk 'NR==2 { print $4 }')

if ! cd $DIR
then
    echo "ERROR: unable to chdir to directory '$DIR'"
    exit 2
fi

echo "Available space: $availSpace"

if (( availSpace < reqSpace )); then
    echo "Available space not sufficient, deleting files"
    # Get list of files, oldest first.
    # Delete the oldest files until
    # we are below the limit. Just
    # delete regular files, ignore directories.
    #
    ls *sql* -rt | while read FILE
    do
        if [ -f $FILE ]
        then
            if rm -f $FILE
            then
                echo "Deleted $FILE"
                availSpace=$(df "$HOME" | awk 'NR==2 { print $4 }')

                if (( availSpace < reqSpace )); then
                    echo "Done deleting files"
                    availSpace=$(df "$HOME" | awk 'NR==2 { print $4 }')
                    echo "Available space: $availSpace"

                    # we're below the limit, so stop deleting
                    exit
                fi
            fi
        fi
    done
else
  echo "enough space"
fi

availSpace=$(df "$HOME" | awk 'NR==2 { print $4 }')
echo "Available space after deleting files if not enough space: $availSpace"

if (( availSpace > reqSpace )); then
    echo "Enough available space now - doing backup job"
	# ADD BACKUP details here OR call backup script
	source /usr/bin/make_sql_backups.sh
	# source /usr/bin/make_data_backups.sh
else
	echo "Available space still not sufficient, not doing anything!"
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - End - Script to delete if not enough space, then run backup"
