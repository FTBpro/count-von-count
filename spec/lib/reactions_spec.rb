require 'spec_helper'

describe "Reaction" do
  before :all do
    @user = create :User
    @author = create :User
    @post = create :Post
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

end
