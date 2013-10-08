args = ngx.req.get_uri_args()
args["week_index"] = os.date("%W",ngx.req.start_time())
local cjson = require "cjson"
local args_json = cjson.encode(args)

-- todo: Move to initRedis func
local redis = require "resty.redis"
local red = redis:new()
red:set_timeout(1000) -- 1 sec
local ok, err = red:connect("127.0.0.1", 6379)
if not ok then
  ngx.say("failed to connect: ", err)
  return
end

local ok, err = red:evalsha(ngx.var.redis_script_hash, 1, "args", args_json)

if ok then
  ngx.say("OK!!! : ", ok)
  return
end
if err then
  ngx.say(err)
  return
end

local ok, err = red:set_keepalive(10000, 100)

if not ok then
  ngx.say("failed to set keepalive: ", err)
  return
end


