local utils = require "utils"
local red = utils:initRedis()
ok, err = red:ping()
if not ok then
  ngx.say("Failed to connect to Redis")
else
  ngx.say(ok)
end
