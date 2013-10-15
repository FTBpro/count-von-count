require 'spec_helper'
require 'script_loader'
describe "ActionCounter" do

  before :all do
    @user = create :User
    @author = create :User
    @post = create :Post
  end       

  describe "Share Action" do
    before :all do
      `curl "http://#{HOST}/shares?user_id=#{@user.id}&author_id=#{@author.id}&post_id=#{@post.id}"`
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
  end

  describe "Like Action" do
    before :all do
      `curl "http://#{HOST}/likes?user_id=#{@user.id}&author_id=#{@author.id}&post_id=#{@post.id}"`
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
  end

  describe "Tweet Action" do
    before :all do
      `curl "http://#{HOST}/tweets?user_id=#{@user.id}&author_id=#{@author.id}&post_id=#{@post.id}"`
    end

    it "should increase the user's num of likes by 1" do
      @user.data["tweets"].to_i.should eq @user.initial_data["tweets"].to_i + 1
    end

    it "should increase the post's author num of shares he got" do
      @author.data["tweets_got"].to_i.should eq @author.initial_data["tweets_got"].to_i + 1
    end

    it "should increase the posts num of shares by 1" do
      @post.data["tweets"].to_i.should eq @post.initial_data["tweets"].to_i + 1
    end
  end
end
