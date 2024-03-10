#! /bin/sh
cd /usr/share/GeoIP

# New download with Maxmind databases with login -> first install geoipupdate and add auth file
/usr/bin/geoipupdate -f /home/moon/GeoIP.conf -d /usr/share/GeoIP -v

# New: use manually compiled dat files from third parties
# for safety, don't overwrite default databases
# page for download: https://www.miyuru.lk/geoiplegacy
# tool to convert myself: https://github.com/sherpya/geolite2legacy

wget -N "https://dl.miyuru.lk/geoip/maxmind/country/maxmind.dat.gz" -P /usr/share/GeoIP/
gunzip /usr/share/GeoIP/maxmind.dat.gz --keep --force

echo "$(date '+%Y-%m-%d %H:%M:%S') - Geolite Update performed"
