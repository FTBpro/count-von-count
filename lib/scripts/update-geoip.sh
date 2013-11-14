#!/bin/bash
wget -N -q http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
gunzip -f GeoIP.dat.gz
mv GeoIP.dat /usr/share/GeoIP/GeoIP.dat
nginx -s reload
