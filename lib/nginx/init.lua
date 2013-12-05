additional_args_plugins = require "additonal_args_supported_plugins"
for i = 1, #additional_args_plugins do
  _plugin = require (additional_args_plugins[i])
  _plugin:init()
end
