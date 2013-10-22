local args = ngx.req.get_uri_args()
local redis = require "resty.redis"
local red = redis:new()
red:set_timeout(1000) -- 1 sec
red:connect("127.0.0.1", 6379)

local cjson = require "cjson"
local key = args["key"]

local response = ""
if red:type(key) == "hash" then
  local value = red:hgetall(key)
  local hash = red:array_to_hash(value)
  response = cjson.encode(hash)
else
  local value = red:zrevrange(key, 0, -1, "withscores")
  response = cjson.encode(value)
end
ngx.say(response)
