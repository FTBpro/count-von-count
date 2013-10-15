-------------- Function to simulate inheritance -------------------------------------
local function inheritsFrom( baseClass )
  local new_class = {}
  local class_mt = { __index = new_class }

  if baseClass then
    setmetatable( new_class, { __index = baseClass } )
  end

  return new_class
end

-------------- Base Class  ---------------------------------------------------------

local Base = {}

function Base:new(_type, _id)
  local baseObj = { redis_key = _type .. "_" .. _id, type = _type, id = _id }
  self.__index = self
  return setmetatable(baseObj, self)
end

function Base:default(action)
  redis.call("HINCRBY", self.redis_key, action, 1)
end

function Base:got(action)
  redis.call("HINCRBY", self.redis_key, action .. "_got", 1)
end

-----------------------------------------------------------------------

-- local UserWeekly = inheritsFrom( Base )

-- -- local Temp = inheritsFrom( Base )

-- function UserWeekly:new(user_id, week_index)
--   local userWeekly = {redis_key = "user_" .. user_id .. "_week_" .. week_index}
--   self.__index = self
--   return setmetatable(userWeekly, self)
-- end


------------ Declaration of all Classes -------------------------------

local classes = { Base = Base }

-- local action = "reads"
-- local config = { reads = { User = { { id = "user_id", action = "default" }, { id = "author_id", action = "got" } }, UserWeekly = { { id = { "user_id", "week_index" }, action = "default" } } } }

-- local params = { user_id = 567, week_index = 2, author_id = 50 }


-- return an array with all the values in tbl that match the given keys array
local function getValueByKeys(tbl, keys)
  local values = {}
  if type(keys) == "table" then
    for i, key in ipairs(keys) do
      table.insert(values, tbl[key])
    end
  else
    table.insert(values, tbl[keys])
  end
  return values
end


local params = cjson.decode(ARGV[1])
local config = cjson.decode(ARGV[2])
local action = params["action"]


local action_config = config[action]
if action_config then
  for obj_type, methods in pairs(action_config) do
    for i, defs in ipairs(methods) do
      local ids = getValueByKeys(params, defs["id"])
      local methodName = defs["action"]
      local obj
      local klass = classes[obj_type]
      if klass == nil then 
        obj = Base:new(obj_type, unpack(ids))
      else
        obj = klass:new(unpack(ids))
      end
      if type(Base[methodName]) == "function" then  -- currently, all of Base methods receive one parameter, which is the action 
        obj[methodName](obj, action)
       else
         obj[methodName](obj)  --currently, when invoking a "custom" method (not a method of Base) then it cannot receive arguments
       end
    end
  end
end
