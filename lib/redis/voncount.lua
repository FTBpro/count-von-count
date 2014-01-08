-------------- Function to simulate inheritance -------------------------------------
-- local function inheritsFrom( baseClass )
--   local new_class = {}
--   local class_mt = { __index = new_class }

--   if baseClass then
--     setmetatable( new_class, { __index = baseClass } )
--   end

--   return new_class
-- end

---------- Array methods ---------------------------

local function concatToArray(a1, a2)
  for i = 1, #a2 do
    a1[#a1 + 1] = a2[i]
  end
  return a1
end

local function flattenArray(arr)
  local flat = {}
  for i = 1, #arr do
    if type(arr[i]) == "table" then
      local inner_flatten = flattenArray(arr[i])
      concatToArray(flat, inner_flatten)
    else
      flat[#flat + 1] = arr[i]
    end
  end
  return flat
end

local function dupArray(arr)
  local dup = {}
  for i = 1, #arr do
    dup[i] = arr[i]
  end
  return dup
end

-----------------------------------------------------

-------------- Base Class  ---------------------------------------------------------

local Base = {}

function Base:new(_obj_type, ids, _type)
  local redis_key = _obj_type
  for k, id in ipairs(ids) do
    redis_key = redis_key .. "_" .. id
  end
  local baseObj = { redis_key = redis_key, _type = _type, _ids = ids,  _obj_type = _obj_type }
  self.__index = self
  return setmetatable(baseObj, self)
end


function Base:count(key, num)
  local allKeys = flattenArray({ key })
  for i, curKey in ipairs(allKeys) do
    if self._type == "set" then
      redis.call("ZINCRBY", self.redis_key, num, curKey)
    else
      redis.call("HINCRBY", self.redis_key, curKey, num)
    end
  end
end

function Base:expire(ttl)
  if redis.call("TTL", self.redis_key) == -1 then
    redis.call("EXPIRE", self.redis_key, ttl)
  end
end
----------------- Custom Methods -------------------------

function Base:conditionalCount(should_count, key)
  if should_count ~= "0" and should_count ~= "false" then
    self:count(key, 1)
  end
end

function Base:countIfExist(value, should_count,  key)
  if value and value ~= "" and value ~= "null" and value ~= "nil" then
    self:conditionalCount(should_count, key)
  end
end

function Base:sevenDaysCount(should_count, key)
  if should_count ~= "0" and should_count ~= "false" then
    local first_day = tonumber(self._ids[3])
    for day = 0, 6, 1 do
      local curDayObjIds = dupArray(self._ids)
      if (first_day + day) > 365 then
        curDayObjIds[4] = string.format("%03d", (tonumber(curDayObjIds[4]) + 1) )
      end
      local curDayObj = Base:new(self._obj_type, curDayObjIds, self._type)
      curDayObj:count(key, 1)
      curDayObj:expire(1209600)  -- expire in 2 weeks
    end
  end
end

function Base:countAndSetIf(should_count, countKey, redisKey, setKey)
  if should_count ~= "0" and should_count ~= "false" then
    self:count(countKey, 1)
    local setCount = redis.call("ZCOUNT", self.redis_key, "-inf", "+inf")
    redis.call("HSET", redisKey, setKey, setCount)
  end
end
----------------------------------------------------------


------------- Helper Methods ------------------------

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


-- parse key and replace "place holders" with their value from tbl.
-- matching replace values in tbl can be arrays, in such case an array will be returned with all the possible keys combinations
local function addValuesToKey(tbl, key)
  local rslt = { key }
  local match = key:match("{[%w_]*}")

  while match do
    local subStrings = flattenArray({ tbl[match:sub(2, -2)] })
    local tempResult = {}
    for i, subStr in ipairs(subStrings) do
      local dup = dupArray(rslt)
      for j, existingKey in ipairs(dup) do
        local curKey = existingKey:gsub(match, subStr)
        dup[j] = curKey
       end
       concatToArray(tempResult, dup)
    end
    rslt = tempResult
    if #rslt > 0 then
      match = rslt[1]:match("{[%w_]*}")
    else
      match = nil
    end
  end

  if #rslt == 1 then
    return rslt[1]
  else
    return rslt
  end
end


--------------------------------------------------
local mode = ARGV[2] or "live"
local arg = ARGV[1]
local params = cjson.decode(arg)
local config =  cjson.decode(redis.call("get", "von_count_config_".. mode))
local action = params["action"]
local defaultMethod = { change = 1, custom_functions = {} }
local action_config = config[action]


if action_config then
  for obj_type, methods in pairs(action_config) do
    for i, defs in ipairs(methods) do
      setmetatable(defs, { __index = defaultMethod })

      local ids = getValueByKeys(params, defs["id"])
      local _type = defs["type"] or "hash"

      local obj = Base:new(obj_type, ids, _type)

      if defs["count"] then
        local key = addValuesToKey(params, defs["count"])
        local change = defs["change"]
        obj:count(key, change)
      end

      for j, custom_function in ipairs(defs["custom_functions"]) do
        local function_name = custom_function["name"]
        local args = {}
        for z, arg in ipairs(custom_function["args"]) do
          local arg_value = addValuesToKey(params, arg)
          table.insert(args, arg_value)
        end
        obj[function_name](obj, unpack(args))
      end

      if defs["expire"] then
        obj:expire(defs["expire"])
      end
    end
  end
end

