#!/bin/bash

# Define overall variables
mssqlusername="SA"
mssqlpassword="PASSWORD"

# backup dir in normal enviroment
backupdir="/home/moon/sqlbackups/"

# backup dir in mssql enviroment
mssqlbackupdir="backups/"

# sql base directory
mssqldirectory="/var/opt/mssql/data/"

# to compress mssql files put to 1
compress="1"

# additional arguments for sqlcmd
# e.g. with stats = print status every x %
dumparguments=""
# dumparguments="WITH STATS = 20"


# Calculate variables
today=$(date '+%Y-%m-%d-%H-%M-%S');

# arguments = databases to back up

echo
echo "$(date '+%Y-%m-%d %H:%M:%S') - Start - Backup MS-SQL database"

# create directory, if it doesn't exist yet
mkdir -p $backupdir

if [ $# -eq 0 ]
    then
        echo "No arguments supplied"
        echo "Please provide database names as argument (can process multiple ones)"

else
    for dbname in "$@"
    do
        echo
        echo "*** Processing database: $dbname"
        mssqlfilename="$mssqlbackupdir$today-$dbname.bak"
        mssqlfilenamefull="$mssqldirectory$mssqlfilename"
        filename="$backupdir$today-$dbname.bak"

        executestring="/opt/mssql-tools/bin/sqlcmd -S localhost -U $mssqlusername -P $mssqlpassword -Q \"
            BACKUP DATABASE $dbname  TO DISK = '$mssqlfilename' $dumparguments
            \"
            "

        # echo "$executestring"
        eval "$executestring"

        echo
        echo "+ Now moving file"

        movestring="mv $mssqlfilenamefull  $filename"
        # echo "$movestring"

        if [ -f "$mssqlfilenamefull" ]; then
            eval "$movestring"
        else
            echo "!! Error - File does not exist, cannot move"
        fi

        echo "+ Now compressing file"
        if [ -f "$filename" ] && [ $compress = "1" ]; then
            gzip "$filename"
        else
            echo "!! Error - File does not exist, cannot compress"
        fi
    done
fi

echo
echo "$(date '+%Y-%m-%d %H:%M:%S') - End - Backup MS-SQL database"
echo
