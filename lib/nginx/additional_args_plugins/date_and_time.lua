local date_and_time = {}

function date_and_time:init()

end

function date_and_time:addToArgs(args)
  args["day"] = os.date("%d", ngx.req.start_time())
  args["yday"] = os.date("%j", ngx.req.start_time())
  args["week"] = os.date("%W",ngx.req.start_time())
  args["month"] = os.date("%m", ngx.req.start_time())
  args["year"] = os.date("%Y",ngx.req.start_time())

  if args["week"] == "00" then
    args["week"] = "52"
    args["year"] = tostring( tonumber(args["year"]) - 1 )
  end
end

return date_and_time
