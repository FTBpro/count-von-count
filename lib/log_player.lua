package.cpath = "/usr/local/openresty/lualib/?.so;" .. package.cpath
local logFilePath = arg[1]
local MON={Jan=1,Feb=2,Mar=3,Apr=4,May=5,Jun=6,Jul=7,Aug=8,Sep=9,Oct=10,Nov=11,Dec=12}
local geoip = require "geoip";
local geoip_country = require "geoip.country"
local geoip_file = "/usr/share/GeoIP/GeoIP.dat"
local geoip_country_filename = geoip_file
geodb = geoip.country.open(geoip_country_filename)


function parseDate(date)
  -- 28/Oct/2013:10:41:15 +0000
  local p ="(%d+)/(%a+)/(%d+):(%d+):(%d+):(%d+)"
  local day,month,year,hour,min,sec = date:match(p)
  month=MON[month]
  return os.time({day=day,month=month,year=year,hour=hour,min=min,sec=sec})
end

function getCountry(ip)
  local country = geodb:query_by_addr(ip, "id")
  return geoip.code_by_id(country)
end

function parseQueryArgs(queryArgs)
  params = {}
  for k,v in queryArgs:gmatch("(%w+%[?%]?)=(*)%&?") do
    if k:match("[[]]") then
      local key = k:gsub("[[]]", "")
      if params[key] then
        table.insert(params[key], v)
      else
        params[key] = {v}
      end
    else
      params[k] = v
    end
  end
  return params
end

function parseArgs(line)
  args = parseQueryArgs(line)
  ip, request_time, query_args = line:match("^([^%s]+).*%[(.*)].*GET%s*(.*)%s*HTTP")
  parseQueryArgs(query_args)
  args["action"] = query_args:match("%/(.*)%?")
  date = parseDate(request_time)
  args["day"] = os.date("%d", date)
  args["week"] = os.date("%W", date)
  args["month"] = os.date("%m", date)
  args["year"] = os.date("%Y", date)
  args["country"] = getCountry(ip)
  if args["week"] == "00" then
    args["week"] = "52"
    args["year"] = tostring( tonumber(args["year"]) - 1 )
  end
  return args
end

local cjson = require "cjson"
for line in io.lines(logFilePath) do
  args = parseArgs(line)
  args_json = "'" .. cjson.encode(args) .. "'"
  print(args_json)
  os.execute("redis-cli evalsha 66063b195459196a03132c0c89b95efd6c17aa77 2 args mode " .. args_json .. " record")
end
