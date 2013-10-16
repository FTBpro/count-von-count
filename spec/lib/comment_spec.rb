require 'spec_helper'

describe "ActionCounter" do
  describe "Comment Action" do
    before :all do
      @user = create :User
      @author = create :User
      @post = create :Post
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
  end
end
