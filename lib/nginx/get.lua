local utils = require "utils"
local cjson = require "cjson"

local args = utils:normalizeKeys( ngx.req.get_query_args() )
local red = utils:initRedis()
local key = args["key"]
local attributes = args["attr"]
local from = args["from"] or 0
local to = args["to"] or -1


function getValues(key, attributes)
	local value
	if red:type(key) == "hash" then
		if attributes then
			if type(attributes) == "table" then
				values = red:hmget(key, unpack(attributes))
				value = {}
				for i = 1, #attributes, 1  do
					table.insert(value, attributes[i])
					table.insert(value, values[i])
				end
			else
				value = red:hget(key, attributes)
			end
		else
			value = red:hgetall(key)
		end
	else
		value = red:zrevrange(key, from, to, "withscores")
	end

	if type(value) == "table" then 
		value = red:array_to_hash(value)
	end
	return value
end

local response
if type(key) == "table" then
	response = {}
	for i, curKey in ipairs(key) do
		response[curKey] = getValues(curKey, attributes)
	end
else
	response = getValues(key, attributes)
end

if type(response) == "table" then
	response = cjson.encode(response)
end
ngx.say(response)
