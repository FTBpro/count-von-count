require 'spec_helper'
require 'script_loader'
describe "ActionCounter" do
  HOST = "127.0.0.1"
  before :all do
    ScriptLoader.load
    @redis = Redis.new(host: HOST, port: "6379")
  end

  describe "Read Action" do
    before :all do
      @user_id = 5
      @user_key = "user_#{@user_id}"
      @user_data = Hash.new(0)
      @user_data.merge!(@redis.hgetall @user_key)
    end

    before :all do
      @author_id = 12
      @author_key = "user_#{@author_id}"
      @author_data = Hash.new(0)
      @author_data.merge!(@redis.hgetall @author_key)
    end

    before :all do
      @post_id = 240786
      @post_key = "post_#{@post_id}"
      @post_data = Hash.new(0)
      @post_data.merge!(@redis.hgetall @post_key)
    end

    before :all do
      @user_id = 5
      @week_index = Time.now.strftime("%W")
      @user_weekly_key = "user_#{@user_id}_week_#{@week_index}"
      @user_weekly_data = Hash.new(0)
      @user_weekly_data.merge!(@redis.hgetall @user_weekly_key)
    end

    before :all do
      `curl "http://#{HOST}/reads?post_id=#{@post_id}&user_id=#{@user_id}&author_id=#{@author_id}"`
    end

    describe "User" do
      it "should increase the reads of the user by one" do
        @redis.hget(@user_key, "reads").to_i.should eq @user_data["reads"].to_i + 1
      end
    end

    describe "Author" do
      it "should increase the post's author num of time he's been read" do
        @redis.hget(@author_key, "been_read").to_i.should eq @author_data["been_read"].to_i + 1
      end
    end

    describe "Post" do
      it "should increase the post reads counter" do
        @redis.hget(@post_key, "reads").to_i.should eq @post_data["reads"].to_i + 1
      end
    end

    describe "UserWeekly" do
      it "should increase reads counter" do
        @redis.hget(@user_weekly_key, "reads").to_i.should eq @user_weekly_data["reads"].to_i + 1
      end
    end
  end
end
