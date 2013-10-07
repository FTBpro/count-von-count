------------------- User Class --------------------------------
local User = {}

function User:new(_id)
	local newUser = { redis_key = "user_" .. _id }
  	self.__index = self              
  	return setmetatable(newUser, self)
end

function User:read()
	redis.call("HINCRBY", self.redis_key, "reads", 1)
end

function User:gotRead()
	redis.call("HINCRBY", self.redis_key, "been_read", 1)
end
----------------------------------------------------------------

local params = cjson.decode(ARGV[1])

local author = User:new(params["author_id"])
author:gotRead()

local user = User:new(params["user_id"])
user:read()

return params["author_id"]
