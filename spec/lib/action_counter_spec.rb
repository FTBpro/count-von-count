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
      `curl "http://#{HOST}/reads?post_id=131&user_id=#{@user_id}&author_id=#{@author_id}"`
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
  end
end
