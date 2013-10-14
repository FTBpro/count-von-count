require 'spec_helper'
require 'script_loader'
describe "ActionCounter" do
  describe "Share Action" do
    before :all do
      @user = create :user
      @author = create :user
      @post = create :post
    end       

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
      @post.data["shares"].to_i.should eq @post.initial_data["shares_got"].to_i + 1
    end
  end
end
