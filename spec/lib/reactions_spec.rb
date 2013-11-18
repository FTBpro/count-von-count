require 'spec_helper'

describe "Reaction" do
  before :all do
    @user = create :User
    @author = create :User
    @post = create :Post
    @user_daily = create :UserDaily, { user: @user.id, day: Time.now.strftime("%d"), month: Time.now.strftime("%m"), year: Time.now.strftime("%Y") }
    @author_daily = create :UserDaily, { user: @author.id, day: Time.now.strftime("%d"), month: Time.now.strftime("%m"), year: Time.now.strftime("%Y") }
  end

  before :all do
    open("http://#{HOST}/reactions?user=#{@user.id}&post=#{@post.id}&author=#{@author.id}")
  end

  it "should increase the user's num of reactions" do
    @user.data["reactions"].to_i.should eq @user.initial_data["reactions"].to_i + 1
  end

  it "should increase the post's num of reactions" do
    @post.data["reactions"].to_i.should eq @post.initial_data["reactions"].to_i + 1
  end

  it "should increase the author's num of reactions he got" do
    @author.data["reactions_got"].to_i.should eq @author.initial_data["reactions_got"].to_i + 1
  end

  describe "UserDaily" do
    it "should increase the daily num of MWP votes of the user by one" do
      @user_daily.data["reactions"].to_i.should eq @user_daily.initial_data["reactions"].to_i + 1
    end

    it "should increase the daily num of MWP votes he got for the author by one" do
      @author_daily.data["reactions_got"].to_i.should eq @author_daily.initial_data["reactions_got"].to_i + 1
    end

    it "should set a TTL for the objects" do
      $redis.ttl(@user_daily.key).should > 0
      $redis.ttl(@author_daily.key).should > 0
    end
  end

end
