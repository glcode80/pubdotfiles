#! /bin/sh
#
## Assumed usage in monitrc (where 80 is max capacity in percentages
## and 2764800 is scrub and trim expiration in seconds):
## default setting is only once per month (first sunday = trim, second sunday = scrub)

## 1) copy file over and add monit
## cp /home/moon/pubdotfiles/zfs_health.sh /home/moon/zfs_health.sh
##
## sudo vim /etc/monit/conf.d/zfs
## check program zfs_health with path "/home/moon/zfs_health.sh 80 2764800"
##     if status != 0 then alert
#
## Scrub and Trim share the same expiration threshold for the backward compatibility reasons.

# Parameters

maxCapacity=$1 # in percentages
scrubExpire=$2 # in seconds (2764800= 32 days)
trimExpire=$2 # in seconds (2764800= 32 days)

usage="Usage: $0 maxCapacityInPercentages scrubExpireInSeconds\n"

if [ ! "${maxCapacity}" ]; then
  printf "Missing arguments\n"
  # printf "${usage}"
  printf "%s" "${usage}"
  exit 1
fi

if [ ! "${scrubExpire}" ]; then
  printf "Missing second argument\n"
  # printf "${usage}"
  printf "%s" "${usage}"
  exit 1
fi


# Output for monit user interface

printf "==== ZPOOL STATUS ====\n"
printf "$(/sbin/zpool status)"
printf "\n\n==== ZPOOL LIST ====\n"
printf "%s\n" "$(/sbin/zpool list)"


# Health - Check if all zfs volumes are in good condition. We are looking for
# any keyword signifying a degraded or broken array.

condition=$(/sbin/zpool status | grep -E 'DEGRADED|FAULTED|OFFLINE|UNAVAIL|REMOVED|FAIL|DESTROYED|corrupt|cannot|unrecover')

if [ "${condition}" ]; then
  printf "\n==== ERROR ====\n"
  printf "One of the pools is in one of these statuses: DEGRADED|FAULTED|OFFLINE|UNAVAIL|REMOVED|FAIL|DESTROYED|corrupt|cannot|unrecover!\n"
  printf "$condition"
  exit 1
fi


# Capacity - Make sure the pool capacity is below 80% for best performance. The
# percentage really depends on how large your volume is. If you have a 128GB
# SSD then 80% is reasonable. If you have a 60TB raid-z2 array then you can
# probably set the warning closer to 95%.
#
# ZFS uses a copy-on-write scheme. The file system writes new data to
# sequential free blocks first and when the uberblock has been updated the new
# inode pointers become valid. This method is true only when the pool has
# enough free sequential blocks. If the pool is at capacity and space limited,
# ZFS will be have to randomly write blocks. This means ZFS can not create an
# optimal set of sequential writes and write performance is severely impacted.

capacity=$(/sbin/zpool list -H -o capacity | cut -d'%' -f1)

for line in ${capacity}
  do
    if [ $line -ge $maxCapacity ]; then
      printf "\n==== ERROR ====\n"
      printf "One of the pools has reached it's max capacity!"
      exit 1
    fi
  done


# Errors - Check the columns for READ, WRITE and CKSUM (checksum) drive errors
# on all volumes and all drives using "zpool status". If any non-zero errors
# are reported an email will be sent out. You should then look to replace the
# faulty drive and run "zpool scrub" on the affected volume after resilvering.

errors=$(/sbin/zpool status | grep ONLINE | grep -v state | awk '{print $3 $4 $5}' | grep -v 000)

if [ "${errors}" ]; then
  printf "\n==== ERROR ====\n"
  printf "One of the pools contains errors!"
  printf "$errors"
  exit 1
fi


# Scrub Expired - Check if all volumes have been scrubbed in at least the last
# 8 days. The general guide is to scrub volumes on desktop quality drives once
# a week and volumes on enterprise class drives once a month. You can always
# use cron to schedule "zpool scrub" in off hours. We scrub our volumes every
# Sunday morning for example.
#
# Check your /etc/cron.d/zfsutils_linux for any already scheduled jobs
#
# Scrubbing traverses all the data in the pool once and verifies all blocks can
# be read. Scrubbing proceeds as fast as the devices allows, though the
# priority of any I/O remains below that of normal calls. This operation might
# negatively impact performance, but the file system will remain usable and
# responsive while scrubbing occurs. To initiate an explicit scrub, use the
# "zpool scrub" command.
#
# The scrubExpire variable is in seconds.

currentDate=$(date +%s)
zfsVolumes=$(/sbin/zpool list -H -o name)

for volume in ${zfsVolumes}
  do
    if [ $(/sbin/zpool status $volume | grep -E -c "none requested") -ge 1 ]; then
      printf "\n==== ERROR ====\n"
      printf "ERROR: You need to run \"zpool scrub $volume\" before this script can monitor the scrub expiration time."
      break
    fi

    if [ $(/sbin/zpool status $volume | grep -E -c "scrub in progress|resilver") -ge 1 ]; then
      break
    fi

    ### Ubuntu with GNU supported date format - compatible with ZFS v2.0.3 output
    scrubRawDate=$(/sbin/zpool status $volume | grep scrub | awk '{print $11" "$12" " $13" " $14" "$15}')
    scrubDate=$(date -d "$scrubRawDate" +%s)

    ### FreeBSD with *nix supported date format
    #scrubRawDate=$(/sbin/zpool status $volume | grep scrub | awk '{print $15 $12 $13}')
    #scrubDate=$(date -j -f '%Y%b%e-%H%M%S' $scrubRawDate'-000000' +%s)

    if [ $(($currentDate - $scrubDate)) -ge $scrubExpire ]; then
      printf "\n==== ERROR ====\n"
      printf "${volume}'s scrub date is too far in the past!"
      exit 1
    fi
  done

# TRIM Expired - Check if all volumes have been trimmed in at least the last
# 8 days. The general guide is to manually trim volumes on desktop quality drives once
# a week and volumes on enterprise class drives once a month. You can always
# use cron to schedule "zpool trim" in off hours. We trim our volumes every
# Sunday morning for example.
#
# Check your /etc/cron.d/zfsutils_linux for any already scheduled jobs
#
# Manual trimming is recommended even though autotrim feature is turned on for your pool.
# From ZFS documentation:
# > Since the automatic TRIM will skip ranges it considers too small there is value in occasionally
# > running a full zpool trim. This may occur when the freed blocks are small and not enough time
# > was allowed to aggregate them. An automatic TRIM and a manual zpool trim may be run concurrently,
# > in which case the automatic TRIM will yield to the manual TRIM.

for volume in ${zfsVolumes}
  do
    if [ $(/sbin/zpool status -t $volume | grep -E -c "trim unsupported") -ge 1 ]; then
      break
    fi

    ### Ubuntu with GNU supported date format - compatible with ZFS v2.0.3 output - For other systems and version adjust awk parameter below
    /sbin/zpool status -t $volume | grep trim | awk '{print $10" "$11" " $12" " $13" "$14}' | while read -r trimRawDate
      do
        trimDate=$(date -d "$trimRawDate" +%s)

        if [ $(($currentDate - $trimDate)) -ge $trimExpire ]; then
          printf "\n==== ERROR ====\n"
          printf "${volume}'s trim date is too far in the past!"
          exit 1
        fi
      done
  done

# Finish - If we made it here then everything is fine
exit 0
