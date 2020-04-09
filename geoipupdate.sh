#! /bin/sh
cd /usr/share/GeoIP

# New download with Maxmind databases with login -> first install geoipupdate and add auth file
/usr/bin/geoipupdate -f /home/moon/GeoIP.conf -d /usr/share/GeoIP -v

# MaxMind databases require login starting Jan 2020 
# wget -N "https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz" -P /usr/share/GeoIP/
# wget -N "http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz" -P /usr/share/GeoIP/
# wget -N "http://geolite.maxmind.com/download/geoip/database/GeoLite2-ASN.tar.gz" -P /usr/share/GeoIP/

# tar -zxvf /usr/share/GeoIP/GeoLite2-Country.tar.gz --strip=1
# tar -zxvf /usr/share/GeoIP/GeoLite2-City.tar.gz --strip=1
# tar -zxvf /usr/share/GeoIP/GeoLite2-ASN.tar.gz --strip=1

# Legacy databases discontinued Jan 2019
# wget -N "http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz" -P /usr/share/GeoIP/
# wget -N "http://geolite.maxmind.com/download/geoip/database/GeoIPv6.dat.gz" -P /usr/share/GeoIP/
# wget -N "http://download.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz" -P /usr/share/GeoIP/
# wget -N "http://download.maxmind.com/download/geoip/database/asnum/GeoIPASNumv6.dat.gz" -P /usr/share/GeoIP/
# gunzip /usr/share/GeoIP/*dat.gz --keep --force

# New: use manually compiled dat files from third parties
# for safety, don't overwrite default databases
# page for download: https://www.miyuru.lk/geoiplegacy
# tool to convert myself: https://github.com/sherpya/geolite2legacy

wget -N "https://dl.miyuru.lk/geoip/maxmind/country/maxmind.dat.gz" -P /usr/share/GeoIP/
gunzip /usr/share/GeoIP/maxmind.dat.gz --keep --force

echo "$(date '+%Y-%m-%d %H:%M:%S') - Geolite Update performed"
