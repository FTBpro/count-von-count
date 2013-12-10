request_metadata_parameters_plugins = require "registered_plugins"
for i = 1, #request_metadata_parameters_plugins do
  _plugin = require (request_metadata_parameters_plugins[i])
  _plugin:init()
end

local utils = require "utils"
utils:loadSystemConfig()
