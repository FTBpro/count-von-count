class ScriptLoader
  def self.load
    reads_hash = `redis-cli SCRIPT LOAD "$(cat "lib/redis_reads.lua")"`.strip
    mobile_hash = `redis-cli SCRIPT LOAD "$(cat "lib/redis_mobile.lua")"`.strip
    File.open("../conf/vars.conf", 'w') { |f| f.write(<<-VARS
      set $redis_reads_hash #{reads_hash};
      set $redis_mobile_hash #{mobile_hash};
      VARS
      ) }
    `echo "nuUcwm4k" | sudo -S nginx -s reload`
    sleep 1
  end
end
