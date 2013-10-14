require 'spec_helper'
require 'script_loader'
describe "ActionCounter" do
  describe "Comment Action" do
    before :all do
      @user = create :user
      @author = create :user
      @post = create :post
    end

    before :all do
      puts "http://#{HOST}/comments?user_id=#{@user.id}&author_id=#{@author.id}"
      puts `curl "http://#{HOST}/comments?user_id=#{@user.id}&author_id=#{@author.id}&post_id=#{@post.id}"`
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
  end
end
