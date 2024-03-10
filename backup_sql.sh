#!/bin/bash

# Define overall variables
sqlusername="root"
sqlpassword="PASSWORD"

backupdir="/home/moon/backups/"

# to compress sql files put to 1
compress="1"

# to get one combined file for all databases provided set to 1
combinefiles="0"

# additional arguments for mysqldump
# export procedures, triggers and events too
# option: pipe though sed to remove definers for procedures

# dumparguments="--routines --triggers --events"
dumparguments="--routines --triggers --events | sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' | sed -e 's/DEFINER[ ]*=[ ]*[^*]*PROCEDURE/PROCEDURE/' | sed -e 's/DEFINER[ ]*=[ ]*[^*]*FUNCTION/FUNCTION/'"


# Calculate variables
today=$(date '+%Y-%m-%d-%H-%M-%S');

# arguments = databases to back up

echo
echo "$(date '+%Y-%m-%d %H:%M:%S') - Start - Backup SQL database"

# create directory, if it doesn't exist yet
mkdir -p $backupdir

if [ $# -eq 0 ]
    then
        echo "No arguments supplied"
        echo "Please provide database names as argument"
        echo "'--all-databases' will export all databases"

#special argument alldb will export all databases
elif [ "$1" = "--all-databases" ]; then
    echo "* Processing all databases export"

    filename="$backupdir$today-alldbs.sql"

    executestring="sudo mysqldump -u $sqlusername -p$sqlpassword --all-databases $dumparguments > $filename"
    # echo "$executestring"
    eval "$executestring"

    if [ -f "$filename" ] && [ $compress = "1" ]; then
        gzip "$filename"
    fi


else
    # combinefiles = 1 means that only one command is executed for all databases at the same time
    if [ $combinefiles = "1" ]; then
        echo "Combining files into one output file"
        filenamecombined=""
        dbnamecombined=""
        for dbname in "$@"
        do
            filenamecombined="$filenamecombined"-"$dbname"
            dbnamecombined="$dbnamecombined $dbname"
        done

        echo
        echo "* Processing databases combined: $dbnamecombined"
        filename="$backupdir$today$filenamecombined.sql"

        executestring="sudo mysqldump -u $sqlusername -p$sqlpassword --databases $dbnamecombined $dumparguments > $filename"
        # echo "$executestring"
        eval "$executestring"

        if [ -f "$filename" ] && [ $compress = "1" ]; then
            gzip "$filename"
        fi

    else
        echo "Backup into individual files"
        for dbname in "$@"
        do
            echo
            echo "* Processing database: $dbname"
            filename="$backupdir$today-$dbname.sql"

            executestring="sudo mysqldump -u $sqlusername -p$sqlpassword --databases $dbname $dumparguments > $filename"
            # echo "$executestring"
            eval "$executestring"

            if [ -f "$filename" ] && [ $compress = "1" ]; then
                gzip "$filename"
            fi
        done
    fi
fi

echo
echo "$(date '+%Y-%m-%d %H:%M:%S') - End - Backup SQL database"
echo
