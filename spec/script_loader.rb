require 'yaml'
require 'json'
require 'ruby-debug'
class ScriptLoader
  class << self
    attr_accessor :log_player_reads_hash
  end
  def self.load
    set_config
    load_scripts_to_log_player_test_db if self.spec_config["log_player_integration"]
    File.open("/usr/local/openresty/nginx/conf/vars.conf", 'w') { |f| f.write(<<-VARS
      set $redis_counter_hash #{von_count_script_hash};
      VARS
      ) }
    restart_nginx
  end

  def self.von_count_script_hash
    @von_count_script_hash ||= `redis-cli SCRIPT LOAD "$(cat "lib/redis/voncount.lua")"`.strip
  end


  def self.load_scripts_to_log_player_test_db
    @log_player_reads_hash ||= `redis-cli -n #{self.spec_config["log_player_redis_db"]} SCRIPT LOAD "$(cat "lib/redis/voncount.lua")"`.strip
  end

  def self.set_config
    redis = Redis.new(host: HOST, port: "6379")
    config = `cat spec/config/voncount.config | tr -d '\n' | tr -d ' '`
    redis.set("von_count_config_live", config)
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

  def self.spec_config
    @@spec_config ||= YAML.load_file('spec/config/spec_config.yml') rescue {}
  end
end
