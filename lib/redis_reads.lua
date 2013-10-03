local function userRead(id)
  redis.call("INCR", "user_reads_" .. id)
end

local function postRead(id)
  redis.call("INCR", "post_reads_" .. id)
end

userRead(KEYS[2])
postRead(KEYS[1])
