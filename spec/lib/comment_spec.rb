require 'spec_helper'

describe "ActionCounter" do
  describe "Comment Action" do
    before :all do
      @user = create :User
      @author = create :User
      @post = create :Post
      @user_weekly = create :UserWeekly, { user: @author.id, week: Time.now.strftime("%W"), year: Time.now.strftime("%Y") }
      @user_daily = create :UserDaily, { user: @user.id, day: Time.now.strftime("%d"), month: Time.now.strftime("%m"), year: Time.now.strftime("%Y") }
      @author_daily = create :UserDaily, { user: @author.id, day: Time.now.strftime("%d"), month: Time.now.strftime("%m"), year: Time.now.strftime("%Y") }
    end

    before :all do
      open("http://#{HOST}/comments?user=#{@user.id}&author=#{@author.id}&post=#{@post.id}")
    end

    it "should increase the user's num of comments by 1" do
      @user.data["comments"].to_i.should eq @user.initial_data["comments"].to_i + 1
    end

    it "should increase the post's author num of comments he got" do
      @author.data["comments_got"].to_i.should eq @author.initial_data["comments_got"].to_i + 1
    end

    it "should increase the post's num of comments" do
      @post.data["comments"].to_i.should eq @post.initial_data["comments"].to_i + 1
    end

    it "should increase the author's UserWeekly comments count" do
      @user_weekly.data["comments"].to_i.should eq @user_weekly.initial_data["comments"].to_i + 1
    end

    it "author num of comments he got should be equal to the number of comments in his user weekly (assuming there is no data for those objects in the DB before this specs run)" do
      @author.data["comments_got"].should eq @user_weekly.data["comments"]
    end

    describe "UserDaily" do
      it "should increase the daily comments of the user by one" do
        @user_daily.data["comments"].to_i.should eq @user_daily.initial_data["comments"].to_i + 1
      end

      it "should increase the daily comments of the author by one" do
        @author_daily.data["comments_got"].to_i.should eq @author_daily.initial_data["comments_got"].to_i + 1
      end

      it "should set a TTL for the objects" do
        $redis.ttl(@user_daily.key).should > 0
        $redis.ttl(@author_daily.key).should > 0
      end
    end    
  end
end
