#!/bin/bash

echo "$(date '+%Y-%m-%d %H:%M:%S') - Start - Script to delete if not enough space, then run backup"

backupdir="/home/moon/backups"
reqSpace=12000000

searchstring="*.tar.gz" # for data files
# searchstring="*sql*" # for sql files

executestring="source /home/moon/backup_data.sh XXXX"
# executestring = "source /home/moon/backup_sql.sh XXXX"


availSpace=$(df "$backupdir" | awk 'NR==2 { print $4 }')

if ! cd $backupdir
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
    lsstring="ls $searchstring -rt"
    eval "$lsstring" | while read -r FILE
    do
        if [ -f "$FILE" ]
        then
            if rm -f "$FILE"
            then
                echo "Deleted $FILE"
                availSpace=$(df "$backupdir" | awk 'NR==2 { print $4 }')

                if (( availSpace < reqSpace )); then
                    echo "Done deleting files"
                    availSpace=$(df "$backupdir" | awk 'NR==2 { print $4 }')
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

availSpace=$(df "$backupdir" | awk 'NR==2 { print $4 }')
echo "Available space after deleting files if not enough space: $availSpace"

if (( availSpace > reqSpace )); then
    echo "Enough available space now - doing backup job"
	# ADD BACKUP details here OR call backup script
	eval "$executestring"
else
	echo "Available space still not sufficient, not doing anything!"
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - End - Script to delete if not enough space, then run backup"
