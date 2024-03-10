#!/bin/bash
#
# This script configures WordPress file permissions based on recommendations
# from http://codex.wordpress.org/Hardening_WordPress#File_permissions
#
# Attention: only working for nginx (for Apache: need to add htaccess part)
#
# Original Author for part of script: Michael Conigliaro#
#
# Attention: After this, update of wordpress core is not possible anymore via UI! (plugins can be updated as they are in wp-content)
# To update wp core:
#
# Option 1) use wp-cli: go to directory and run:
#       -- for full update
#       wp core update
#       -- for minor update (security updates only)
#       wp core update --minor
#               (this works as the moon user, because this is owned by moon - no need to add moon to www-data group)
#               (install wp cli: https://wp-cli.org/)
#
# Option 2) update ownership of full install to www-data:
#       sudo chown -R www-data:www-data /var/www/FOLDER/
#   -> !!! after update run this script again !!!
#
WP_OWNER=moon           #  normal user account that owns the wordpress installation
WP_GROUP=moon           #  normal group account that owns the wordpress installation
WS_GROUP=www-data       #  webserver group -> gets group write access on wp-content and some files (see below)

datadir="/var/www/" #  path to wordpress installations

echo
echo "$(date '+%Y-%m-%d %H:%M:%S') - Start - Update wordpress ownership and rights"


if [ $# -eq 0 ]
    then
        echo
        echo "No arguments supplied. Please provide folder names within $datadir to export, options:"
        echo "(alternative: provide full folder path starting with /)"
        echo
        eval "ls $datadir"
        echo

else
    echo "Start updating wordpress ownerships"
    for foldername in "$@"
    do
        # if full folder path is provided (starting with /) use this 
        if [ "${foldername::1}" = "/" ]; then
            WP_ROOT=$foldername
        else
            WP_ROOT=$datadir$foldername
        fi

        echo
        echo "* Processing folder:  >>>>   $WP_ROOT   <<<"

        # check if folder exists
        if [ -d "$WP_ROOT" ]; then

            # # reset to safe defaults
            echo
            echo "1) Apply default owner and default rights to all files"
            echo "  -> $WP_OWNER:$WP_GROUP and chmod 755 (directories) / 644 (files)"
            # slow method: do it on all folders/files individually
            # eval "sudo find ${WP_ROOT} -exec chown ${WP_OWNER}:${WP_GROUP} {} \;"
            # faster method: run chown -R
            eval "sudo chown -R ${WP_OWNER}:${WP_GROUP} ${WP_ROOT}"
            # all directories and files chmod
            eval "sudo find ${WP_ROOT} -type d -exec chmod 755 {} \;"
            eval "sudo find ${WP_ROOT} -type f -exec chmod 644 {} \;"
            echo "Done"
            echo

            # # allow wordpress to manage wp-config.php (but prevent world access)
            echo "2) Allow wordpress to manage wp-config.php (but prevent world access)"
            echo "  -> $WP_OWNER:$WS_GROUP and chmod 660 to wp-config.php"
            eval "sudo chgrp ${WS_GROUP} ${WP_ROOT}/wp-config.php"
            eval "sudo chmod 660 ${WP_ROOT}/wp-config.php"
            echo "Done"
            echo

            # # allow wordpress to manage wp-content => 775 => allow write to www-data user!
            echo "3) Allow wordpress to manage wp-content"
            # echo "  -> $WP_OWNER:$WS_GROUP and chmod 775 to wp-content and all subdirectories (775 = write to group!)"
            # slow method: do it on all folders/files individually
            # eval "sudo find ${WP_ROOT}/wp-content -exec chgrp ${WS_GROUP} {} \;"
            # faster method: run chmod -R
            eval "sudo chown -R ${WP_OWNER}:${WS_GROUP} ${WP_ROOT}/wp-content"
            # all directories and files chmod - wihtin wp-content
            eval "sudo find ${WP_ROOT}/wp-content -type d -exec chmod 775 {} \;"
            eval "sudo find ${WP_ROOT}/wp-content -type f -exec chmod 664 {} \;"
            echo "Done"
            echo

            # # # allow wordpress to manage .htaccess -> not needed on nginx
            # # touch ${WP_ROOT}/.htaccess
            # # chgrp ${WS_GROUP} ${WP_ROOT}/.htaccess
            # # chmod 664 ${WP_ROOT}/.htaccess

            # # Force access mode in wp-config => add via wp cli (needs to be installed!)
            # => without it you get ftp access popup!
            echo "4) Enable direct FS_METHOD in wp-config -> to force direct file updates (instead of ftp)"
            echo " --> wp cli needs to be installed for it to work"
            eval "wp config set FS_METHOD direct --path=${WP_ROOT}"
            echo "ADDED \"define( 'FS_METHOD', 'direct' );\" to wp-config file! to force direct file updates (instead of ftp)"
            echo "Done"
            echo

        else
            echo "Error - folder '$WP_ROOT' does NOT exist"
        fi

    done
    fi
echo
echo "$(date '+%Y-%m-%d %H:%M:%S') - Done"
