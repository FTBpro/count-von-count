require 'yaml'
require 'json'
class ScriptLoader
  class << self
    attr_accessor :log_player_reads_hash, :log_player_mobile_hash
  end
  def self.load(test_env = false)
    set_config
    load_scripts_to_log_player_test_db if test_env
    File.open("../conf/vars.conf", 'w') { |f| f.write(<<-VARS
      set $redis_counter_hash #{action_counter_script_hash};
      set $redis_mobile_hash #{mobile_script_hash};
      VARS
      ) }
    restart_nginx
  end

  def self.action_counter_script_hash
    @action_counter_script_hash ||= `redis-cli SCRIPT LOAD "$(cat "lib/redis/actioncounter.lua")"`.strip
  end

  def self.mobile_script_hash
    @mobile_hash ||= `redis-cli SCRIPT LOAD "$(cat "lib/redis/mobile.lua")"`.strip
  end

  def self.load_scripts_to_log_player_test_db
    @log_player_reads_hash ||= `redis-cli -n 1 SCRIPT LOAD "$(cat "lib/redis/actioncounter.lua")"`.strip
    @log_player_mobile_hash ||= `redis-cli -n 1 SCRIPT LOAD "$(cat "lib/redis/mobile.lua")"`.strip
  end

  def self.set_config
    redis = Redis.new(host: HOST, port: "6379")
    config = `cat config/actioncounter.config | tr -d '\n' | tr -d ' '`
    redis.set("action_counter_config_live", config)
    log_player_redis = Redis.new(host: HOST, port: "6379", db: 1)
    log_player_redis.set("action_counter_config_record", config)
  end

  def self.restart_nginx
    `echo "#{personal_settings['sudo_password']}" | sudo -S nginx -s reload`
    sleep 1
  end

  def self.clean_access_log
    `rm -f /usr/local/openresty/nginx/logs/access.log`
  end

  def self.personal_settings
    @@settings ||= YAML.load_file("config/personal.yml") rescue {}
  end

end
