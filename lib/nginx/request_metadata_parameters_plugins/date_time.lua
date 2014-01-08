local date_time = {}
local MON={Jan=1,Feb=2,Mar=3,Apr=4,May=5,Jun=6,Jul=7,Aug=8,Sep=9,Oct=10,Nov=11,Dec=12}

function date_time:init()
end


function date_time:AddtoArgsFromNginx(args)
  date_time:fromString(args, ngx.req.start_time())
end

function date_time:AddToArgsFromLogPlayer(args, line)
  ip, request_time, query_args = line:match("^([^%s]+).*%[(.*)].*GET%s*(.*)%s* HTTP")
  date_time:fromString(args,
                       date_time:parseDateFromString(request_time))
end

function date_time:fromString(args, str)
  args["day"] = os.date("%d", str)
  args["yday"] = os.date("%j", str)
  args["week"] = os.date("%W", str)
  args["month"] = os.date("%m", str)
  args["year"] = os.date("%Y", str)
  args["week_year"] = args["week"] .. "_" .. args["year"]

  if args["week"] == "00" then
    local last_year = tostring( tonumber(args["year"]) - 1 )
    args["week_year"] = "52_" .. last_year
  end
end

function date_time:parseDateFromString(date)
  -- 28/Oct/2013:10:41:15 +0000
  print(date)
  local p ="(%d+)/(%a+)/(%d+):(%d+):(%d+):(%d+)"
  local day,month,year,hour,min,sec = date:match(p)
  month=MON[month]
  return os.time({day=day,month=month,year=year,hour=hour,min=min,sec=sec})
end

return date_time
