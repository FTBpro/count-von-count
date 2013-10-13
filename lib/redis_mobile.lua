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

function MobileActivity:pn_action(action_type)
  if self:valid_action(action_type) then
    redis.call("INCR", "pn_" .. action_type .. "_" .. self.locale .. "_team_" .. self.team_id .. "_" .. self.date )
    redis.call("INCR", "pn_" .. action_type .. "_" .. self.date )
  end
end

function MobileActivity:valid_action(action_type)
  local PN_ACTION_TYPES = { "received_post", "clicked_post", "opened_post", "received_match", "clicked_match", "opened_match" }
  for k, v in pairs(PN_ACTION_TYPES) do
    if v == action_type then return true end
  end
  return false
end

local params = cjson.decode(ARGV[1])
local mobileActivity = MobileActivity:new(params["id"], params["locale"], params["team_id"], params["date"], params["article_pn"], params["match_pn"])
local action = params["action"]
local pn_type = params["pn_type"]


if      action == "active" then mobileActivity:markActive()
elseif  action == "pn"     then mobileActivity:pn_action(pn_type)
end

