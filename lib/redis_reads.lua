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

------------------- Post Class --------------------------------
local Post = {}

function Post:new(_id)
  local newPost = {redis_key = "post_" .. _id}
  self.__index = self
  return setmetatable(newPost, self)
end

function Post:read()
  redis.call("HINCRBY", self.redis_key, "reads", 1)
end

------------------- UserWeekly Class --------------------------------
local UserWeekly = {}

function UserWeekly:new(user_id, week_index)
  local userWeekly = {redis_key = "user_" .. user_id .. "_week_" .. week_index}
  self.__index = self
  return setmetatable(userWeekly, self)
end

function UserWeekly:read()
  redis.call("HINCRBY", self.redis_key, "reads", 1)
end

----------------------------------------------------------------
local params = cjson.decode(ARGV[1])

local author = User:new(params["author_id"])
author:gotRead()

local user = User:new(params["user_id"])
user:read()

local post = Post:new(params["post_id"])
post:read()
local weekIndex = params["week_index"]

local userWeekly = UserWeekly:new(params["user_id"], weekIndex)
userWeekly:read()
