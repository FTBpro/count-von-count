require 'spec_helper'
require 'open-uri'
describe "ActionCounter" do
  describe "Read Action" do
    before :all do
      @user = create :User
      @author = create :User
      @post = create :Post
    end

    before :all do
      @user_id = @author.id
      @week_index = Time.now.strftime("%W")
      @user_weekly_key = "user_#{@user_id}_week_#{@week_index}"
      @user_weekly_data = Hash.new(0)
      @user_weekly_data.merge!($redis.hgetall @user_weekly_key)
    end

    before :all do
      open("http://#{HOST}/reads?post_id=#{@post.id}&user_id=#{@user.id}&author_id=#{@author.id}")
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
end
