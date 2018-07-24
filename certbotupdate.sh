#! /bin/sh
echo "$(date '+%Y-%m-%d %H:%M:%S') - Start - Certbot update"
certbot renew
echo "$(date '+%Y-%m-%d %H:%M:%S') - End - Certbot update"
