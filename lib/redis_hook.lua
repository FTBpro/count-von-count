-- Helper Methods

function emptyGif()
  ngx.exec('/_.gif')
end

function logErrorAndExit(err)
   ngx.log(ngx.ERR, err)
   emptyGif()
end

function initRedis()
  local redis = require "resty.redis"
  local red = redis:new()
  red:set_timeout(3000) -- 3 sec
  local ok, err = red:connect("127.0.0.1", 6379)
  if not ok then logErrorAndExit("Error connecting to redis: ".. err) end
  return red
end

---------------------
ngx.header["Cache-Control"] = "no-cache"

local args = ngx.req.get_uri_args()
args["action"] = ngx.var.action
args["day"] = os.date("%d", ngx.req.start_time())
week = os.date("%W",ngx.req.start_time())
if week == "00" then week = "52" end
args["week"] = week
args["month"] = os.date("%m", ngx.req.start_time())
args["year"] = os.date("%Y",ngx.req.start_time())
local cjson = require "cjson"
local args_json = cjson.encode(args)

red = initRedis()

ok, err = red:evalsha(ngx.var.redis_counter_hash, 2, "args", "config", args_json, ngx.var.config)
if not ok then logErrorAndExit("Error evaluating redis script: ".. err) end

ok, err = red:set_keepalive(10000, 100)
if not ok then ngx.log(ngx.ERR, "Error setting redis keep alive ".. err) end
emptyGif()
