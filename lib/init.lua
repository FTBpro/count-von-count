local geoip = require "geoip";
local geoip_country = require "geoip.country";
local geoip_country_filename = "/usr/local/Cellar/geoip/1.5.1/share/GeoIP/GeoIP.dat";
geodb = geoip_country.open(geoip_country_filename);
