function initGeoIP() 
	local geoip = require "geoip";
	local geoip_country = require "geoip.country";
	local geoip_file = "/path/to/geoip.dat"
	local geoip_country_filename = geoip_file
	geodb = geoip_country.open(geoip_country_filename)
end

-- Uncomment this line if you want to use the geoIP, after you followed the installation instructions
-- initGeoIP()
