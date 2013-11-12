local utils = require "utils"

local args = ngx.req.get_uri_args()
args["date"] = os.date("%Y-%m-%d",ngx.req.start_time())
local cjson = require "cjson"
local args_json = cjson.encode(args)

local red = utils:initRedis()

local ok, err = red:evalsha(ngx.var.redis_mobile_hash, 1, "args", args_json)

if ok then red:set_keepalive(10000, 100) end

ngx.exec('/_.gif')


