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

local args = ngx.req.get_uri_args()
args["week_index"] = os.date("%W",ngx.req.start_time())
local cjson = require "cjson"
local args_json = cjson.encode(args)

red = initRedis()

ok, err = red:evalsha(ngx.var.redis_reads_hash, 1, "args", args_json)
if not ok then logErrorAndExit("Error evaluating redis script: ".. err) end

ok, err = red:set_keepalive(10000, 100)
if not ok then ngx.log(ngx.ERR, "Error setting redis keep alive ".. err) end
emptyGif()