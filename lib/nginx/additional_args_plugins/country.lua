local country = {}

function country:init(from_nginx)
  local geoip = require "geoip";
  local geoip_country = require "geoip.country";
  local geoip_file = "/usr/share/GeoIP/GeoIP.dat"
  local geoip_country_filename = geoip_file
  geodb = geoip_country.open(geoip_country_filename)
end

function country:AddtoArgsFromNginx(args)
  country:fromString(args, ngx.var.remote_addr)
end

function country:AddToArgsFromLogPlayer(args, line)
  ip, request_time, query_args = line:match("^([^%s]+).*%[(.*)].*GET%s*(.*)%s* HTTP")
  country:fromString(args,ip)
end

function country:fromString(args, ip)
   local country = geodb:query_by_addr(ip, "id")
   args["country"] = geoip.code_by_id(country) or "--"
end

return country
