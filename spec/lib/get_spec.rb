require 'spec_helper'
describe "Get" do
  before :all do
    @user = create :User
    @author = create :User
    @post = create :Post
    league_id = rand(10)
    team_id = rand(20)
    user_id = rand(2000)
    @locale = "en"
    @league_weekly = create :LeagueWeekly, { league: league_id, locale: @locale, week: Time.now.strftime("%W"), year: Time.now.strftime("%Y") }
    @league_monthly = create :LeagueMonthly, { league: league_id, locale: @locale, month: Time.now.strftime("%m"), year: Time.now.strftime("%Y") }
    @team_weekly = create :TeamWeekly, { team: team_id, locale: @locale, week: Time.now.strftime("%W"), year: Time.now.strftime("%Y") }
    @team_monthly = create :TeamMonthly, { team: team_id, locale: @locale, month: Time.now.strftime("%m"), year: Time.now.strftime("%Y") }
    @league_weekly_leaderboard = create :LeagueWeeklyLeaderboard, { league: league_id, locale: @locale, week: Time.now.strftime("%W"), year: Time.now.strftime("%Y") }
    @league_monthly_leaderboard = create :LeagueMonthlyLeaderboard, { league: league_id, locale: @locale, month: Time.now.strftime("%m"), year: Time.now.strftime("%Y") }
    @team_weekly_leaderboard = create :TeamWeeklyLeaderboard, { team: team_id, locale: @locale, week: Time.now.strftime("%W"), year: Time.now.strftime("%Y") }
    @team_monthly_leaderboard = create :TeamMonthlyLeaderboard, { team: team_id, locale: @locale, month: Time.now.strftime("%m"), year: Time.now.strftime("%Y") }
    @user_daily = create :UserDaily, { user: @user.id, day: Time.now.strftime("%d"), month: Time.now.strftime("%m"), year: Time.now.strftime("%Y") }
    @author_daily = create :UserDaily, { user: @author.id, day: Time.now.strftime("%d"), month: Time.now.strftime("%m"), year: Time.now.strftime("%Y") }
  end

  before :all do
    @user_id = @author.id
    @week = Time.now.strftime("%W")
    @year = Time.now.strftime("%Y")
    @user_weekly_key = "UserWeekly_#{@user_id}_#{@week}_#{@year}"
    @user_weekly_demographics_key = "UserWeeklyDemographics_#{@user_id}_#{@week}_#{@year}"
    @user_weekly_data = Hash.new(0)
    @user_weekly_data.merge!($redis.hgetall @user_weekly_key)
    @user_weekly_demographics_data = Hash.new(0)
    @user_weekly_demographics_data.merge!($redis.hgetall @user_weekly_demographics_key)
  end

  before :all do
    open("http://#{HOST}/reads?post=#{@post.id}&user=#{@user.id}&author=#{@author.id}&league=#{@league_weekly.ids[:league]}&team=#{@team_weekly.ids[:team]}&locale=#{@locale}&ulb=1&plb=1")
    open("http://#{HOST}/reads?post=#{@post.id.to_i + 1}&user=#{@author.id}&author=#{@user.id}&league=#{@league_weekly.ids[:league]}&team=#{@team_weekly.ids[:team]}&locale=#{@locale}&ulb=1&plb=1")
    open("http://#{HOST}/logins?user=#{@user.id}")
  end

  def get(query_string)
    JSON.parse( open("http://#{HOST}/get?#{query_string}").read.gsub("\n", "") )
  end

  describe "Header" do
  	it "should have a 'Access-Control-Allow-Origin *' in the response header" do
  	  response = open("http://#{HOST}/get?key=User_#{@user.id}")
  	  response.meta.keys.should include "access-control-allow-origin"
  	  response.meta["access-control-allow-origin"].should == "*"
  	end
  end

  describe "Hash key" do
    describe "single key" do
      it "should return a json with all the attributes of the key when attr params are not defined" do
        hash = get("key=User_#{@user.id}")
        hash.keys.sort.should match_array(["logins", "reads", "reads_got"])
      end

      it "should return a json containing only the values defined by the attr array parameter in the query string" do
        hash = get("key=User_#{@user.id}&attr[]=reads&attr[]=logins")
        hash.keys.sort.should match_array(["logins", "reads"])
      end

      it "should return nil for attributes that dont exist" do
        hash = get("key=User_#{@author.id}&attr[]=reads&attr[]=logins")
        hash["reads"].to_i.should eq 1
        hash.keys.should match_array(["logins", "reads"])
        hash["logins"].should eq nil
      end

      it "should only the value of the desired attribute if only one is defined" do
        rslt = open("http://#{HOST}/get?key=User_#{@user.id}&attr=reads").read.gsub("\n", "")
        rslt.should == "1"
      end

      describe "as array" do
	      it "should return a json with a single key equal to the requested key and its value as hash" do
	        hash = get("key[]=User_#{@user.id}")
	        hash.keys.should match_array([@user.key])
	        hash[@user.key].keys.should match_array(["logins", "reads", "reads_got"])
	      end
	    end
    end

    describe "multiple keys" do
    	describe "without attributes" do
    		it "should return a json with the given keys as keys and for each key a hash with all of its attributes " do
	        hash = get("key[]=#{@user.key}&key[]=#{@author.key}")
	        hash.keys.should match_array([@user.key, @author.key])
	        hash[@user.key].keys.should match_array(["logins", "reads", "reads_got"])
	        hash[@author.key].keys.should match_array(["reads", "reads_got"])
    		end
    	end

    	describe "with attributes" do
    		it "should return a json with the given keys as keys and for each key a hash with all the given attributes" do
    		  hash = get("key[]=#{@user.key}&key[]=#{@author.key}&attr[]=reads&attr[]=logins")
    		  hash.keys.should match_array([@user.key, @author.key])
	        hash[@user.key].keys.should match_array(["logins", "reads"])
	        hash[@author.key].keys.should match_array(["logins", "reads"])
    		end

    		it "should return a json with the given keys as keys and for each key a value for the given attribute (single attribute)" do
    		  hash = get("key[]=#{@user.key}&key[]=#{@author.key}&attr=reads")
    		  hash.keys.should match_array([@user.key, @author.key])
	        hash[@user.key].should eq "1"
	        hash[@author.key].should eq "1"
    		end

    		it "should return a json with the given keys as keys and for each key a hash with the given attribute (single attribute as array)" do
    		  hash = get("key[]=#{@user.key}&key[]=#{@author.key}&attr[]=reads")
    		  hash.keys.should match_array([@user.key, @author.key])
	        hash[@user.key].keys.should match_array(["reads"])
	        hash[@author.key].keys.should match_array(["reads"])
    		end
    	end
    end
  end
end
