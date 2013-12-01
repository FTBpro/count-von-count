require 'spec_helper'

describe "Post Created" do
  before :all do
    @user = create :User
    @post = create :Post
    @league_id = rand(20)
    @team_id = rand(100)
    @locale = "en"
    @user_daily = create :UserDaily, { user: @user.id, day: Time.now.strftime("%d"), month: Time.now.strftime("%m"), year: Time.now.strftime("%Y") }
    @user_weekly = create :UserWeekly, { user: @user.id, week: Time.now.strftime("%W"), year: Time.now.strftime("%Y") }
    @league_counters = create :LeagueCounters, { id: @league_id }
    @league_writers = create :LeagueWriters, { id: @league_id }
    @team_counters = create :TeamCounters, { id: @team_id }
    @team_original_counters = create :TeamCounters , {id: @team_id, locale: @locale}
    @team_writers = create :TeamWriters, { id: @team_id }
  end

  before :all do
    open("http://#{HOST}/post_create?user=#{@user.id}&post=#{@post.id}&league=#{@league_id}&team=#{@team_id}&league_count=true&locale=#{@locale}&writers_count=true&ulb=false")
  end

  it "should increase the user's num of posts created by 1" do
    @user.data["post_create"].to_i.should eq @user.initial_data["post_create"].to_i + 1
  end

  it "should increase the user's weekly num of posts created" do
    @user_weekly.data["post_create"].to_i.should eq @user_weekly.initial_data["post_create"].to_i + 1
  end

  describe "UserDaily" do
    it "should increase the daily logins of the user by one" do
      @user_daily.data["post_create"].to_i.should eq @user_daily.initial_data["post_create"].to_i + 1
    end

    it "should set a TTL for the objects" do
      $redis.ttl(@user_daily.key).should > 0
    end
  end

  describe "LeagueCounters" do
    describe "posts" do
      it "should increase the league posts count if league_count is not false" do
        @league_counters.data["posts"].to_i.should eq @league_counters.initial_data["posts"].to_i + 1
      end

      it "should not increase the league posts count if league_count is false" do
        open("http://#{HOST}/post_create?user=#{@user.id}&post=#{@post.id}&league=#{@league_id}&team=#{@team_id + 1}&league_count=0&writers_count=true&locale=#{@locale}&ulb=false")
        @league_counters.data["posts"].to_i.should eq @league_counters.initial_data["posts"].to_i + 1
      end
    end

    describe "writers" do
      before :all do
        @current_data = @league_counters.data
      end

      it "should not increase the number of writers for the league if its not a new writer" do
        open("http://#{HOST}/post_create?user=#{@user.id.to_i}&post=#{@post.id}&league=#{@league_id}&team=#{@team_id + 1}&league_count=true&writers_count=true&locale=#{@locale}&ulb=false")
        @league_counters.data["writers"].to_i.should eq @current_data["writers"].to_i
      end

      it "should not increase the number of writers for the league if its a new writer but writers_count is false" do
        open("http://#{HOST}/post_create?user=#{@user.id.to_i + 1}&post=#{@post.id}&league=#{@league_id}&team=#{@team_id + 1}&league_count=true&writers_count=false&locale=#{@locale}&ulb=false")
        @league_counters.data["writers"].to_i.should eq @current_data["writers"].to_i
      end

      it "should increase the number of writers for the league if its a new writer" do
        open("http://#{HOST}/post_create?user=#{@user.id.to_i + 1}&post=#{@post.id}&league=#{@league_id}&team=#{@team_id + 1}&league_count=true&writers_count=true&locale=#{@locale}&ulb=false")
        @league_counters.data["writers"].to_i.should eq @current_data["writers"].to_i + 1
      end
    end
  end

  describe "LeagueWriters" do
    it "should add 1 to the user who created the post" do
      @league_writers.set["user_#{@user.id}"].to_i.should == @league_writers.initial_set["user_#{@user.id}"].to_i + 3  # greater by 3 because of previous spec who does another call
    end

    it "should not add 1 to the user who created the post if writers_count is false" do
      open("http://#{HOST}/post_create?user=#{@user.id}&post=#{@post.id}&league=#{@league_id}&team=#{@team_id + 1}&league_count=true&locale=#{@locale}&writers_count=false&ulb=false")
      @league_writers.set["user_#{@user.id}"].to_i.should == @league_writers.initial_set["user_#{@user.id}"].to_i + 3  # greater by 3 because of previous spec who does another call
    end
  end

  describe "TeamCounters" do
    describe "posts" do
      it "should increase the team posts count if league_count is not false" do
        @team_counters.data["posts"].to_i.should eq @team_counters.initial_data["posts"].to_i + 1
      end

      it "should not increase the team posts count if league_count is false" do
        open("http://#{HOST}/post_create?user=#{@user.id}&post=#{@post.id}&league=#{@league_id}&team=#{@team_id}&league_count=0&writers_count=true&locale=#{@locale}&ulb=false")
        @team_counters.data["posts"].to_i.should eq @team_counters.initial_data["posts"].to_i + 1
      end
    end

    describe "writers" do
      before :all do
        @current_data = @team_counters.data
        @current_original_data = @team_original_counters.data
      end

      it "should not increase the number of writers for the team if its not a new writer" do
        open("http://#{HOST}/post_create?user=#{@user.id.to_i}&post=#{@post.id}&league=#{@league_id}&team=#{@team_id}&league_count=true&writers_count=true&locale=#{@locale}&ulb=false")
        @team_counters.data["writers"].to_i.should eq @current_data["writers"].to_i
      end

      it "should not increase the number of writers for the team if its a new writer but writers_count is false" do
        open("http://#{HOST}/post_create?user=#{@user.id.to_i + 1}&post=#{@post.id}&league=#{@league_id}&team=#{@team_id}&league_count=true&writers_count=false&locale=#{@locale}&ulb=false")
        @team_counters.data["writers"].to_i.should eq @current_data["writers"].to_i
      end

      it "should increase the number of writers for the team if its a new writer" do
        open("http://#{HOST}/post_create?user=#{@user.id.to_i + 1}&post=#{@post.id}&league=#{@league_id}&team=#{@team_id}&league_count=true&locale=#{@locale}&writers_count=true&ulb=false")
        @team_counters.data["writers"].to_i.should eq @current_data["writers"].to_i + 1
      end
      context "original_writers" do
        it "should increase the number of original writers if ulb parameter is not false and the user is a new writer" do
          open("http://#{HOST}/post_create?user=#{@user.id.to_i + 2}&post=#{@post.id}&league=#{@league_id}&team=#{@team_id}&league_count=true&writers_count=true&locale=#{@locale}&ulb=true")
          @team_original_counters.data["original_writers"].to_i.should eq @current_original_data["original_writers"].to_i + 1
        end
        it "should not increase the number of original writers if ulb parameter false and the user is a new writer" do
          open("http://#{HOST}/post_create?user=#{@user.id.to_i + 2}&post=#{@post.id}&league=#{@league_id}&team=#{@team_id}&league_count=true&writers_count=true&locale=#{@locale}&ulb=false")
          @team_original_counters.data["original_writers"].to_i.should eq @current_original_data["original_writers"].to_i + 1
        end
      end
    end
  end

  describe "TeamWriters" do
    it "should add 1 to the user who created the post" do
      @team_writers.set["user_#{@user.id}"].to_i.should == @team_writers.initial_set["user_#{@user.id}"].to_i + 3  # greater by 3 because of previous spec who does another call
    end

    it "should not add 1 to the user who created the post if writers_count is false" do
      open("http://#{HOST}/post_create?user=#{@user.id}&post=#{@post.id}&league=#{@league_id}&team=#{@team_id}&league_count=true&locale=#{@locale}&writers_count=false")
      @team_writers.set["user_#{@user.id}"].to_i.should == @team_writers.initial_set["user_#{@user.id}"].to_i + 3  # greater by 3 because of previous spec who does another call
    end
  end

  describe "post_remove" do
    it "should decrease the user's number of post_create" do
      post_create_count = @user.data["post_create"].to_i
      open("http://#{HOST}/post_remove?user=#{@user.id}")
      @user.data["post_create"].to_i.should eq post_create_count - 1
    end
  end
end
