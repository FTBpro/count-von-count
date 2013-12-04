local utils = require "utils"

ngx.header["Cache-Control"] = "no-cache"
local args = ngx.req.get_query_args()
args = utils:normalizeKeys(args)
args["action"] = ngx.var.action
args["day"] = os.date("%d", ngx.req.start_time())
args["yday"] = os.date("%j", ngx.req.start_time())
args["week"] = os.date("%W",ngx.req.start_time())
args["month"] = os.date("%m", ngx.req.start_time())
args["year"] = os.date("%Y",ngx.req.start_time())
args["country"] = utils:getCountry()
if args["week"] == "00" then
  args["week"] = "52"
  args["year"] = tostring( tonumber(args["year"]) - 1 )
end
local cjson = require "cjson"
local args_json = cjson.encode(args)
local red = utils:initRedis()

ok, err = red:evalsha(ngx.var.redis_counter_hash, 1, "args", args_json)
if not ok then utils:logErrorAndExit("Error evaluating redis script: ".. err) end

ok, err = red:set_keepalive(10000, 100)
if not ok then utils:logErrorAndExit("Error setting redis keep alive ".. err) end
utils:emptyGif()
