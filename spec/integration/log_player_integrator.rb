require 'ruby-debug'
require 'spec_helper'

def self.spec_config
  @@spec_config ||= YAML.load_file('spec/config/spec_config.yml') rescue {}
end

Spec::Runner.configure do |config|
  if self.spec_config["log_player_integration"]
    config.before(:all) do
      flush_keys
      ScriptLoader.clean_access_log
      ScriptLoader.restart_nginx
    end
    config.after(:all) do
      compare_log_player_values_to_real_time_values
    end
  end

  def compare_log_player_values_to_real_time_values
    run_log_player
    $redis.keys.each do |key|
      if !unrelevant_keys.include?(key)
        if !compare_value(key)
          raise RSpec::Expectations::ExpectationNotMetError, "Log Player Intregration: difference in #{key}"
        end
      end
    end
  end

  def flush_keys
    cache_keys = $redis.keys "*"
    cache_keys = cache_keys.reject { |key| key.match(/^von_count_config/)}
    $redis.del(cache_keys) if cache_keys.any?
    cache_keys = $log_player_redis.keys "*"
    cache_keys = cache_keys.reject { |key| key.match(/^von_count_config/)}
    $log_player_redis.del(cache_keys.reject { |key| key.match(/^von_count_config/)}) if cache_keys.any?
  end

  def unrelevant_keys
    ["von_count_config_live"]
  end

  def compare_value(key)
    if $redis.type(key) == "hash"
      return $redis.hgetall(key) == $log_player_redis.hgetall(key)
    elsif $redis.type(key) == "zset"
      return $redis.zrevrange(key, 0, -1, withscores:true) == $log_player_redis.zrevrange(key, 0, -1, withscores:true)
    elsif $redis.type(key) == "string"
      return $redis.get(key) == $log_player_redis.get(key)
    end
    false
  end

  def run_log_player
    `lua \
    /usr/local/openresty/nginx/count-von-count/lib/log_player.lua \
    /usr/local/openresty/nginx/logs/access.log \
    #{spec_config["redis_host"]} \
    #{spec_config["redis_port"]} \
    #{spec_config["log_player_redis_db"]} \
    `
  end


end
