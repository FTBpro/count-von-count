

local config_str = "{\"reads\":{\"User\":[{\"id\":\"user_id\",\"action\":\"default\"},{\"id\":\"author_id\",\"action\":\"got\"}],\"Post\":[{\"id\":\"post_id\",\"action\":\"default\"}],\"UserWeekly\":[{\"id\":[\"user_id\",\"week_index\"],\"action\":\"default\"}]},\"comments\":{\"User\":[{\"id\":\"user_id\",\"action\":\"default\"},{\"id\":\"author_id\",\"action\":\"got\"}],\"Post\":[{\"id\":\"post_id\",\"action\":\"default\"}]}}"
local config = cjson.decode(config_str)
local params = cjson.decode(ARGV[1])
local action = params["action"]

local action_config = config[action]
if action_config then

end

