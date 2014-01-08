local utils = require "utils"

ngx.header["Cache-Control"] = "no-cache"
local args = ngx.req.get_query_args()
args = utils:normalizeKeys(args)
args["action"] = ngx.var.action

for i = 1, #request_metadata_parameters_plugins do
  _plugin = require (request_metadata_parameters_plugins[i])
  _plugin:AddtoArgsFromNginx(args)
end

local cjson = require "cjson"
local args_json = cjson.encode(args)
local red = utils:initRedis()

ok, err = red:evalsha(ngx.var.redis_counter_hash, 1, "args", args_json)
if not ok then utils:logErrorAndExit("Error evaluating redis script: ".. err) end

ok, err = red:set_keepalive(10000, 1000)
if not ok then utils:logErrorAndExit("Error setting redis keep alive ".. err) end
utils:emptyGif()
