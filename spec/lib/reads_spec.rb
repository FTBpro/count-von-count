require 'spec_helper'
describe "Read Action" do
  before :all do
    @user = create :User
    @author = create :User
    @post = create :Post
    league_id = rand(10)
    team_id = rand(20)
    @locale = "en"
    @league_weekly = create :LeagueWeekly, { league: league_id, locale: @locale, week: Time.now.strftime("%W"), year: Time.now.strftime("%Y") }
    @league_monthly = create :LeagueMonthly, { league: league_id, locale: @locale, month: Time.now.strftime("%m"), year: Time.now.strftime("%Y") }
    @team_weekly = create :TeamWeekly, { team: team_id, locale: @locale, week: Time.now.strftime("%W"), year: Time.now.strftime("%Y") }
    @team_monthly = create :TeamMonthly, { team: team_id, locale: @locale, month: Time.now.strftime("%m"), year: Time.now.strftime("%Y") }
    @league_weekly_leaderboard = create :LeagueWeeklyLeaderboard, { league: league_id, locale: @locale, week: Time.now.strftime("%W"), year: Time.now.strftime("%Y") }
    @league_monthly_leaderboard = create :LeagueMonthlyLeaderboard, { league: league_id, locale: @locale, month: Time.now.strftime("%m"), year: Time.now.strftime("%Y") }
    @team_weekly_leaderboard = create :TeamWeeklyLeaderboard, { team: team_id, locale: @locale, week: Time.now.strftime("%W"), year: Time.now.strftime("%Y") }
    @team_monthly_leaderboard = create :TeamMonthlyLeaderboard, { team: team_id, locale: @locale, month: Time.now.strftime("%m"), year: Time.now.strftime("%Y") }
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
  end

  describe "User" do
    it "should increase the reads of the user by one" do
      @user.data["reads"].to_i.should eq @user.initial_data["reads"].to_i + 1
    end
  end

  describe "Author" do
    it "should increase the post's author num of time he's been read" do
      @author.data["reads_got"].to_i.should eq @author.initial_data["reads_got"].to_i + 1
    end
  end

  describe "Post" do
    it "should increase the post reads counter" do
      @post.data["reads"].to_i.should eq @post.initial_data["reads"].to_i + 1
    end
  end

  describe "UserWeekly" do
    it "should increase reads counter" do
      $redis.hget(@user_weekly_key, "reads").to_i.should eq @user_weekly_data["reads"].to_i + 1
    end
  end

   describe "UserWeeklyDemographics" do
    it "should increase reads counter" do
      $redis.hget(@user_weekly_demographics_key, "N/A").to_i.should eq @user_weekly_demographics_data["N/A"].to_i + 1
    end
  end

  describe "LeagueWeekly" do
    it "should increase the post's read count for the given league and the current week and year" do
      @league_weekly.set["post_#{@post.id}"].to_i.should eq @league_weekly.initial_set["post_#{@post.id}"].to_i + 1
    end
  end

  describe "LeagueMonthly" do
    it "should increase the post's read count for the given league and the current month and year" do
      @league_monthly.set["post_#{@post.id}"].to_i.should eq @league_monthly.initial_set["post_#{@post.id}"].to_i + 1
    end
  end

  describe "TeamWeekly" do
    it "should increase the post's read count for the given team and the current week and year" do
      @team_weekly.set["post_#{@post.id}"].to_i.should eq @team_weekly.initial_set["post_#{@post.id}"].to_i + 1
    end
  end

  describe "TeamMonthly" do
    it "should increase the post's read count for the given league and the current month and year" do
      @team_monthly.set["post_#{@post.id}"].to_i.should eq @team_monthly.initial_set["post_#{@post.id}"].to_i + 1
    end
  end

  describe "LeagueWeeklyLeaderboard" do
    it "should increase the author's reads count in the leaderboard for the given league and current week and year" do
      @league_weekly_leaderboard.set["user_#{@author.id}"].to_i.should eq @league_weekly_leaderboard.initial_set["user_#{@author.id}"].to_i + 1
    end
  end

  describe "LeagueMontlyLeaderboard" do
    it "should increase the author's reads count in the leaderboard for the given league and current month and year" do
      @league_monthly_leaderboard.set["user_#{@author.id}"].to_i.should eq @league_monthly_leaderboard.initial_set["user_#{@author.id}"].to_i + 1
    end
  end

  describe "TeamWeeklyLeaderboard" do
    it "should increase the author's reads count in the leaderboard for the given team and current week and year" do
      @team_weekly_leaderboard.set["user_#{@author.id}"].to_i.should eq @team_weekly_leaderboard.initial_set["user_#{@author.id}"].to_i + 1
    end
  end

  describe "TeamMontlyLeaderboard" do
    it "should increase the author's reads count in the leaderboard for the given team and current month and year" do
      @team_monthly_leaderboard.set["user_#{@author.id}"].to_i.should eq @team_monthly_leaderboard.initial_set["user_#{@author.id}"].to_i + 1
    end
  end

  describe "Team/League Weekly/Monthly" do
    it "should increase the counts for the same league objects as above, although the other params have changed" do
      open("http://#{HOST}/reads?post=#{@post.id}&user=#{rand(100)}&author=#{rand(100)}&league=#{@league_weekly.ids[:league]}&team=#{rand(20)}&locale=#{@locale}&ulb=1&plb=1")
      @league_weekly.set["post_#{@post.id}"].to_i.should eq @league_weekly.initial_set["post_#{@post.id}"].to_i + 2
      @league_monthly.set["post_#{@post.id}"].to_i.should eq @league_monthly.initial_set["post_#{@post.id}"].to_i + 2
    end

    it "should increase the counts for the same team objects as above, although the other params have changed" do
      open("http://#{HOST}/reads?post=#{@post.id}&user=#{rand(100)}&author=#{rand(100)}&league=#{rand(20)}&team=#{@team_weekly.ids[:team]}&locale=#{@locale}&ulb=1&plb=1")
      @team_monthly.set["post_#{@post.id}"].to_i.should eq @team_monthly.initial_set["post_#{@post.id}"].to_i + 2
      @team_weekly.set["post_#{@post.id}"].to_i.should eq @team_weekly.initial_set["post_#{@post.id}"].to_i + 2
    end
  end

  describe "Users Leaderboards custom count" do
    before :all do
      @league_weekly_leaderboard_data = @league_weekly_leaderboard.set
      @league_monthly_leaderboard_data = @league_monthly_leaderboard.set
      @team_weekly_leaderboard_data = @team_weekly_leaderboard.set
      @team_monthly_leaderboard_data = @team_monthly_leaderboard.set
      open("http://#{HOST}/reads?post=#{@post.id}&user=#{@user.id}&author=#{@author.id}&league=#{@league_weekly.ids[:league]}&team=#{@team_weekly.ids[:team]}&locale=#{@locale}&ulb=0&plb=1")
    end

    it "should not increase the author's reads count in the leaderboard for the given league and current week and year" do
      @league_weekly_leaderboard.set["user_#{@author.id}"].to_i.should eq @league_weekly_leaderboard_data["user_#{@author.id}"]
    end

    it "should not increase the author's reads count in the leaderboard for the given league and current month and year" do
      @league_monthly_leaderboard.set["user_#{@author.id}"].to_i.should eq @league_monthly_leaderboard_data["user_#{@author.id}"]
    end    

    it "should not increase the author's reads count in the leaderboard for the given league and current week and year" do
      @team_weekly_leaderboard.set["user_#{@author.id}"].to_i.should eq @team_weekly_leaderboard_data["user_#{@author.id}"]
    end

    it "should not increase the author's reads count in the leaderboard for the given league and current month and year" do
      @team_monthly_leaderboard.set["user_#{@author.id}"].to_i.should eq @team_monthly_leaderboard_data["user_#{@author.id}"]
    end    
  end


  describe "Posts Leaderboards custom count" do
    before :all do
      @league_weekly_data = @league_weekly.set
      @league_monthly_data = @league_monthly.set
      @team_weekly_data = @team_weekly.set
      @team_monthly_data = @team_monthly.set
      open("http://#{HOST}/reads?post=#{@post.id}&user=#{@user.id}&author=#{@author.id}&league=#{@league_weekly.ids[:league]}&team=#{@team_weekly.ids[:team]}&locale=#{@locale}&ulb=1&plb=0")
    end

    it "should not increase the author's reads count in the leaderboard for the given league and current week and year" do
      @league_weekly.set["post_#{@post.id}"].to_i.should eq @league_weekly_data["post_#{@post.id}"]
    end

    it "should not increase the author's reads count in the leaderboard for the given league and current month and year" do
      @league_monthly.set["post_#{@post.id}"].to_i.should eq @league_monthly_data["post_#{@post.id}"]
    end    

    it "should not increase the author's reads count in the leaderboard for the given league and current week and year" do
      @team_weekly.set["post_#{@post.id}"].to_i.should eq @team_weekly_data["post_#{@post.id}"]
    end

    it "should not increase the author's reads count in the leaderboard for the given league and current month and year" do
      @team_monthly.set["post_#{@post.id}"].to_i.should eq @team_monthly_data["post_#{@post.id}"]
    end    
  end


  describe "get" do
    ## Those specs are not really related to the 'Read Action', i'm just using the data from the specs above...
    it "should return the data from redis for the post data" do
      post_data = URI.parse("http://#{HOST}/get?key=#{@post.key}").read
      rslt = JSON.parse(post_data)
      rslt.should be_a(Hash)
      rslt.keys.should include("reads")
    end

    it "should return the data from redis for the reading user" do
      post_data = URI.parse("http://#{HOST}/get?key=#{@user.key}").read
      rslt = JSON.parse(post_data)
      rslt.should be_a(Hash)
      rslt.keys.should include("reads")
    end

    it "should return the data from redis for the author user" do
      post_data = URI.parse("http://#{HOST}/get?key=#{@author.key}").read
      rslt = JSON.parse(post_data)
      rslt.should be_a(Hash)
      rslt.keys.should include("reads_got")
    end
  end
end
