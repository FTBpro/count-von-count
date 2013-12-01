require 'spec_helper'
describe "ActionCounter" do

  before :all do
    @user = create :User
    @author = create :User
    @post = create :Post
    @user_weekly = create :UserWeekly, { user: @author.id, week: Time.now.strftime("%W"), year: Time.now.strftime("%Y") }
    @user_daily = create :UserDaily, { user: @user.id, day: Time.now.strftime("%d"), month: Time.now.strftime("%m"), year: Time.now.strftime("%Y") }
    @author_daily = create :UserDaily, { user: @author.id, day: Time.now.strftime("%d"), month: Time.now.strftime("%m"), year: Time.now.strftime("%Y") }
  end

  describe "Share Action" do
    before :all do
      open("http://#{HOST}/shares?user=#{@user.id}&author=#{@author.id}&post=#{@post.id}")
    end

    it "should increase the user's num of shares by 1" do
      @user.data["shares"].to_i.should eq @user.initial_data["shares"].to_i + 1
    end

    it "should increase the post's author num of shares he got" do
      @author.data["shares_got"].to_i.should eq @author.initial_data["shares_got"].to_i + 1
    end

    it "should increase the posts num of shares by 1" do
      @post.data["shares"].to_i.should eq @post.initial_data["shares"].to_i + 1
    end

    it "should increase the author's UserWeekly shares count" do
      @user_weekly.data["shares"].to_i.should eq @user_weekly.initial_data["shares"].to_i + 1
    end

    it "author num of shares he got should be equal to the number of shares in his user weekly (assuming there is no data for those objects in the DB before this specs run)" do
      @author.data["shares_got"].should eq @user_weekly.data["shares"]
    end

    describe "UserDaily" do
      it "should increase the daily shares of the user by one" do
        @user_daily.data["shares"].to_i.should eq @user_daily.initial_data["shares"].to_i + 1
      end

      it "should increase the daily shares of the author by one" do
        @author_daily.data["shares_got"].to_i.should eq @author_daily.initial_data["shares_got"].to_i + 1
      end

      it "should set a TTL for the objects" do
        $redis.ttl(@user_daily.key).should > 0
        $redis.ttl(@author_daily.key).should > 0
      end
    end
  end

  describe "Like Action" do
    before :all do
      open("http://#{HOST}/likes?user=#{@user.id}&author=#{@author.id}&post=#{@post.id}")
    end

    it "should increase the user's num of likes by 1" do
      @user.data["likes"].to_i.should eq @user.initial_data["likes"].to_i + 1
    end

    it "should increase the post's author num of likes he got" do
      @author.data["likes_got"].to_i.should eq @author.initial_data["likes_got"].to_i + 1
    end

    it "should increase the posts num of likes by 1" do
      @post.data["likes"].to_i.should eq @post.initial_data["likes"].to_i + 1
    end

    it "should increase the author's UserWeekly likes count" do
      @user_weekly.data["likes"].to_i.should eq @user_weekly.initial_data["likes"].to_i + 1
    end

    it "author num of likes he got should be equal to the number of likes in his user weekly (assuming there is no data for those objects in the DB before this specs run)" do
      @author.data["likes_got"].should eq @user_weekly.data["likes"]
    end

    describe "UserDaily" do
      it "should increase the daily likes of the user by one" do
        @user_daily.data["likes"].to_i.should eq @user_daily.initial_data["likes"].to_i + 1
      end

      it "should increase the daily likes of the author by one" do
        @author_daily.data["likes_got"].to_i.should eq @author_daily.initial_data["likes_got"].to_i + 1
      end

      it "should set a TTL for the objects" do
        $redis.ttl(@user_daily.key).should > 0
        $redis.ttl(@author_daily.key).should > 0
      end
    end
  end

  describe "Tweet Action" do
    before :all do
      open("http://#{HOST}/tweets?user=#{@user.id}&author=#{@author.id}&post=#{@post.id}")
    end

    it "should increase the user's num of tweets by 1" do
      @user.data["tweets"].to_i.should eq @user.initial_data["tweets"].to_i + 1
    end

    it "should increase the post's author num of tweets he got" do
      @author.data["tweets_got"].to_i.should eq @author.initial_data["tweets_got"].to_i + 1
    end

    it "should increase the posts num of tweets by 1" do
      @post.data["tweets"].to_i.should eq @post.initial_data["tweets"].to_i + 1
    end

    it "should increase the author's UserWeekly tweets count" do
      @user_weekly.data["tweets"].to_i.should eq @user_weekly.initial_data["tweets"].to_i + 1
    end

    it "author num of tweets he got should be equal to the number of tweets in his user weekly (assuming there is no data for those objects in the DB before this specs run)" do
      @author.data["tweets_got"].should eq @user_weekly.data["tweets"]
    end

    describe "UserDaily" do
      it "should increase the daily tweets of the user by one" do
        @user_daily.data["tweets"].to_i.should eq @user_daily.initial_data["tweets"].to_i + 1
      end

      it "should increase the daily tweets of the author by one" do
        @author_daily.data["tweets_got"].to_i.should eq @author_daily.initial_data["tweets_got"].to_i + 1
      end

      it "should set a TTL for the objects" do
        $redis.ttl(@user_daily.key).should > 0
        $redis.ttl(@author_daily.key).should > 0
      end
    end
  end

  describe "gplus" do
    before :all do
      open("http://#{HOST}/gplus?user=#{@user.id}&author=#{@author.id}&post=#{@post.id}")
    end

    it "should increase the user's num of gplus by 1" do
      @user.data["gplus"].to_i.should eq @user.initial_data["gplus"].to_i + 1
    end

    it "should increase the post's author num of gplus he got" do
      @author.data["gplus_got"].to_i.should eq @author.initial_data["gplus_got"].to_i + 1
    end

    it "should increase the posts num of gplus by 1" do
      @post.data["gplus"].to_i.should eq @post.initial_data["gplus"].to_i + 1
    end

    it "should increase the author's UserWeekly gplus count" do
      @user_weekly.data["gplus"].to_i.should eq @user_weekly.initial_data["gplus"].to_i + 1
    end

    it "author num of gplus he got should be equal to the number of gplus in his user weekly (assuming there is no data for those objects in the DB before this specs run)" do
      @author.data["gplus_got"].should eq @user_weekly.data["gplus"]
    end

    describe "UserDaily" do
      it "should increase the daily gplus of the user by one" do
        @user_daily.data["gplus"].to_i.should eq @user_daily.initial_data["gplus"].to_i + 1
      end

      it "should increase the daily gplus of the author by one" do
        @author_daily.data["gplus_got"].to_i.should eq @author_daily.initial_data["gplus_got"].to_i + 1
      end

      it "should set a TTL for the objects" do
        $redis.ttl(@user_daily.key).should > 0
        $redis.ttl(@author_daily.key).should > 0
      end
    end
  end
end
