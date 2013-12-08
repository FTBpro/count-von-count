package.cpath = "/usr/local/openresty/lualib/?.so;" .. package.cpath
package.path = "/usr/local/openresty/nginx/Count-von-Count/lib/nginx/additional_args_plugins/?.lua;" .. package.path
local logFilePath = arg[1]
local database_index = arg[2] or 0
local cjson = require "cjson"

function setConfig()
  config_file = "/usr/local/openresty/nginx/Count-von-Count/config/voncount.config"
  f = io.popen("cat " .. config_file .. " | tr -d '\n' | tr -d ' '")
  content = f:read('*a')
  conf = cjson.encode(content)
  os.execute("redis-cli -n " .. database_index .. " set von_count_config_record " .. conf)
end

local redisScriptHash
function getRedisCountingHash()
  vars_conf_path = "/usr/local/openresty/nginx/conf/vars.conf"
  for line in io.lines(vars_conf_path) do
    if line:match("$redis_counter_hash") then
      for i in (line:gmatch("%S+")) do
        redisScriptHash = i
      end
    end
  end
  redisScriptHash = redisScriptHash:sub(0, -2)
end

function parseQueryArgs(queryArgs)
  params = {}
  for k,v in queryArgs:gmatch("([%w_]+%[?%]?)=([^&]+)") do
    if k:match("[[]]") then
      local key = k:gsub("[[]]", "")
      --key = k:gsub("amp;", "")
      if params[key] then
        table.insert(params[key], v)
      else
        params[key] = {v}
      end
    else
      params[k] = v
    end
  end
  return params
end

function parseArgs(line)
  ip, request_time, query_args = line:match("^([^%s]+).*%[(.*)].*GET%s*(.*)%s* HTTP")
  args = parseQueryArgs(query_args)
  args["action"] = query_args:match("%/(.*)%?")

  for i = 1, #additional_args_plugins do
  _plugin = require (additional_args_plugins[i])
  _plugin:AddToArgsFromLogPlayer(args, line)
  end
  return args
end

function initAdditionalArgsPlugins()
  additional_args_plugins = require "additonal_args_supported_plugins"
  for i = 1, #additional_args_plugins do
    _plugin = require (additional_args_plugins[i])
    _plugin:init()
  end
end

function playLine(line)
  args = parseArgs(line)
  args_json = "'" .. cjson.encode(args) .. "'"
  os.execute("redis-cli -n " .. database_index .. " evalsha " .. redisScriptHash .. " 2 args mode " .. args_json .. " record")
end

-------------------------------
setConfig()
getRedisCountingHash()

initAdditionalArgsPlugins()


for line in io.lines(logFilePath) do
  print("Playing line: " .. line)
  local status, err = pcall(playLine, line)
  if not status then
    print("Error!!! " .. err)
  end
end
