local MobileActivity = {}

function MobileActivity:new(id_, locale_, team_id_, date_, article_pn_, match_pn_)
	local mobileActivity = { id = id_, locale = locale_, team_id = team_id_, date = date_, article_pn = article_pn_, match_pn = match_pn_ }
  self.__index = self
  return setmetatable(mobileActivity, self)
end

function MobileActivity:markActive()
  redis.call("SETBIT", "mobile_activity_" .. self.locale .. "_team_" .. self.team_id .. "_article_pn_" .. self.article_pn .. "_" .. self.date, self.id, 1)
  redis.call("SETBIT", "mobile_activity_" .. self.locale .. "_team_" .. self.team_id .. "_match_pn_" .. self.match_pn .. "_" .. self.date, self.id, 1)
  redis.call("SETBIT", "mobile_activity_" .. "article_pn_" .. self.article_pn .. "_" .. self.date, self.id, 1)
  redis.call("SETBIT", "mobile_activity_" .. "match_pn_" .. self.match_pn .. "_" .. self.date, self.id, 1)
end

function MobileActivity:pn_received()
  redis.call("INCR", "pn_received_" .. self.locale .. "_team_" .. self.team_id .. "_" .. self.date )
  redis.call("INCR", "pn_received_" .. self.date )  
end

function MobileActivity:pn_clicked()
  redis.call("INCR", "pn_clicked_" .. self.locale .. "_team_" .. self.team_id .. "_" .. self.date )
  redis.call("INCR", "pn_clicked_" .. self.date )
end

function MobileActivity:pn_opened()
  redis.call("INCR", "pn_opened_" .. self.locale .. "_team_" .. self.team_id .. "_" .. self.date )
  redis.call("INCR", "pn_opened_" .. self.date )
end


local params = cjson.decode(ARGV[1])
local mobileActivity = MobileActivity:new(params["id"], params["locale"], params["team_id"], params["date"], params["article_pn"], params["match_pn"])
local action = params["action"]

if      action == "active"      then mobileActivity:markActive()
elseif  action == "pn_received" then mobileActivity:pn_received()
elseif  action == "pn_clicked"  then mobileActivity:pn_clicked()
elseif  action == "pn_opened"   then mobileActivity:pn_opened()
end

