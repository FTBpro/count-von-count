require 'ruby-debug'
Spec::Runner.configure do |config|
  config.before(:all) do
    $redis.flushdb
    $log_player_redis.flushdb
    ScriptLoader.set_config
    ScriptLoader.clean_access_log
    ScriptLoader.restart_nginx
  end
  config.after(:all) do
    compare_log_player_values_to_real_time_values
  end

  def compare_log_player_values_to_real_time_values
    run_log_player
    $redis.keys.each do |key|
      if !unrelevant_keys.include?(key)
        if !compare_value(key)
          p key
          true.should be false
        end
      end
    end
  end

  def unrelevant_keys
    ["action_counter_config_live"]
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
    `/usr/local/openresty/lua/bin/lua /usr/local/openresty/nginx/action-counter/lib/log_player.lua /usr/local/openresty/nginx/logs/access.log #{ScriptLoader.log_player_reads_hash} #{ScriptLoader.log_player_mobile_hash} 1`
  end
end
