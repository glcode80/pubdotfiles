#! /bin/sh
cd /usr/share/GeoIP
wget -N "http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz" -P /usr/share/GeoIP/
wget -N "http://geolite.maxmind.com/download/geoip/database/GeoLite2-ASN.tar.gz" -P /usr/share/GeoIP/

wget -N "http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz" -P /usr/share/GeoIP/
wget -N "http://geolite.maxmind.com/download/geoip/database/GeoIPv6.dat.gz" -P /usr/share/GeoIP/
wget -N "http://download.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz" -P /usr/share/GeoIP/
wget -N "http://download.maxmind.com/download/geoip/database/asnum/GeoIPASNumv6.dat.gz" -P /usr/share/GeoIP/
gunzip /usr/share/GeoIP/*dat.gz --keep --force
tar -zxvf /usr/share/GeoIP/GeoLite2-ASN.tar.gz --strip=1
tar -zxvf /usr/share/GeoIP/GeoLite2-City.tar.gz --strip=1
echo "$(date '+%Y-%m-%d %H:%M:%S') - Geolite Update performed"

