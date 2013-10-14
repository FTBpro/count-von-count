------------------- User Class --------------------------------
local User = {}

function User:new(_id)
	local newUser = { redis_key = "user_" .. _id }
  self.__index = self
  return setmetatable(newUser, self)
end

function User:action(action)
  redis.call("HINCRBY", self.redis_key, action, 1)
end

function User:gotAction(action)
  redis.call("HINCRBY", self.redis_key, action .. "_got", 1)
end


------------------- Post Class --------------------------------
local Post = {}

function Post:new(_id)
  local newPost = {redis_key = "post_" .. _id}
  self.__index = self
  return setmetatable(newPost, self)
end

function Post:action(action)
  redis.call("HINCRBY", self.redis_key, action, 1)
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
local action = params["action"]

if action == "reads" then
  local weekIndex = params["week_index"]
  local userWeekly = UserWeekly:new(params["author_id"], weekIndex)
  userWeekly:read()
end

if action == "reads" or action == "comments" or action == "shares" then
  local author = User:new(params["author_id"])
  author:gotAction(action)

  local user = User:new(params["user_id"])
  user:action(action)

  local post = Post:new(params["post_id"])
  post:action(action)  
end  
