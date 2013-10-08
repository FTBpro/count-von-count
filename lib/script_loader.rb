class ScriptLoader
  def self.load
    hash = `redis-cli SCRIPT LOAD "$(cat "lib/redis_reads.lua")"`.strip
    File.open("../conf/vars.conf", 'w') {|f| f.write("set $redis_script_hash #{hash};") }
    `echo "Reminder1" | sudo -S nginx -s reload`
    sleep 1
  end
end
