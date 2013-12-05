local country = {}

function country:init()
  local geoip = require "geoip";
  local geoip_country = require "geoip.country";
  local geoip_file = "/usr/share/GeoIP/GeoIP.dat"
  local geoip_country_filename = geoip_file
  geodb = geoip_country.open(geoip_country_filename)
end

function country:addToArgs(args)
  args["country"] = country:getCountry()
end

function country:getCountry()
  local country = geodb:query_by_addr(ngx.var.remote_addr, "id")
  return geoip.code_by_id(country) or "--"
end

return country
