require 'yaml'
require 'json'
class ScriptLoader
  def self.load
    reads_hash = `redis-cli SCRIPT LOAD "$(cat "lib/actioncounter.lua")"`.strip
    mobile_hash = `redis-cli SCRIPT LOAD "$(cat "lib/redis_mobile.lua")"`.strip
    config = `cat config/actioncounter.config | tr -d '\n' | tr -d ' '`
    redis = Redis.new(host: HOST, port: "6379")
    redis.set("action_counter_config_live", config)
    File.open("../conf/vars.conf", 'w') { |f| f.write(<<-VARS
      set $redis_counter_hash #{reads_hash};
      set $redis_mobile_hash #{mobile_hash};
      set $config '#{config}';
      VARS
      ) }
    `echo "Reminder1" | sudo -S nginx -s reload`
    sleep 1
  end
end

# ScriptLoader.load
