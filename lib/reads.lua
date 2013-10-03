local args = ngx.req.get_uri_args()
local postId = args["post_id"];
local userSlug = args["user_slug"];
local redis = require "resty.redis"
local red = redis:new()

red:set_timeout(1000) -- 1 sec
local ok, err = red:connect("127.0.0.1", 6379)
if not ok then
  ngx.say("failed to connect: ", err)
  return
end

local postReadsKey = "post_reads_" .. postId
local userReadsKey = "user_reads_" .. userSlug
-- ngx.say(postReadsKey)
-- ok, err = red:incr(postReadsKey)
-- red::incr(postReadsKey)

local ok, err = red:evalsha(ngx.var.redis_script_hash, 2, postId, userSlug)
if ok then
  ngx.say("OK!!!")
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


