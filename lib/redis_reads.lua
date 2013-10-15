-- ------------------- User Class --------------------------------
-- local ACTION_POINTS = {
--   reads = 2,
--   reads_got = 1,
--   comments = 50,
--   comments_got = 100,
--   shares = 30,
--   likes = 30,
--   tweets = 30,
--   shares_got = 50,
--   likes_got = 50,
--   tweets_got = 50 
-- }
-- local User = {}

-- function User:new(_id)
-- 	local newUser = { redis_key = "user_" .. _id }
--   self.__index = self
--   return setmetatable(newUser, self)
-- end

-- function User:action(action)
--   redis.call("HINCRBY", self.redis_key, action, 1)
--   -- self:addPoints(action)
-- end

-- function User:gotAction(action)
--   redis.call("HINCRBY", self.redis_key, action .. "_got", 1)
--   -- self:addPoints(action)
-- end

-- function User:addPoints(action)
--   local points = ACTION_POINTS[action]
--   if points then 
--     redis.call("HINCRBY", self.redis_key, "points", points)
--   end
-- end


-- ------------------- Post Class --------------------------------
-- local Post = {}

-- function Post:new(_id)
--   local newPost = {redis_key = "post_" .. _id}
--   self.__index = self
--   return setmetatable(newPost, self)
-- end

-- function Post:action(action)
--   redis.call("HINCRBY", self.redis_key, action, 1)
-- end

-- ------------------- UserWeekly Class --------------------------------
-- local UserWeekly = {}

-- function UserWeekly:new(user_id, week_index)
--   local userWeekly = {redis_key = "user_" .. user_id .. "_week_" .. week_index}
--   self.__index = self
--   return setmetatable(userWeekly, self)
-- end

-- function UserWeekly:read()
--   redis.call("HINCRBY", self.redis_key, "reads", 1)
-- end

-- ----------------------------------------------------------------
-- local params = cjson.decode(ARGV[1])
-- local action = params["action"]

-- if action == "reads" then
--   local weekIndex = params["week_index"]
--   local userWeekly = UserWeekly:new(params["author_id"], weekIndex)
--   userWeekly:read()
-- end

-- if action == "reads" or action == "comments" or action == "shares" or action == "likes" or action == "tweets" then
--   local author = User:new(params["author_id"])
--   author:gotAction(action)

--   local user = User:new(params["user_id"])
--   user:action(action)

--   local post = Post:new(params["post_id"])
--   post:action(action)  
-- end  
