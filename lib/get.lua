local args = ngx.req.get_uri_args()
local redis = require "resty.redis"
local red = redis:new()
red:set_timeout(1000) -- 1 sec
red:connect("127.0.0.1", 6379)

local cjson = require "cjson"
local value = red:hgetall(args["key"])
local hash = red:array_to_hash(value)
local response = cjson.encode(hash)
ngx.say(response)
