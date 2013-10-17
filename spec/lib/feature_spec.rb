require 'spec_helper'

describe "Login" do
  before :all do
    @channel = "site"
    @user = create :User
  end

  before :all do
    open("http://#{HOST}/feature?user=#{@user.id}&channel=#{@channel}")
  end

  it "should increase the user's num of featured posts according to the given channel" do
    @user.data["feature_#{@channel}"].to_i.should eq @user.initial_data["feature_#{@channel}"].to_i + 1
  end

  it "should increase the user's num of featured posts according to the given channel" do
    other_channel = "mobile"
    open("http://#{HOST}/feature?user=#{@user.id}&channel=#{other_channel}")
    @user.data["feature_#{other_channel}"].to_i.should eq @user.initial_data["feature_#{other_channel}"].to_i + 1
    @user.data["feature_#{@channel}"].to_i.should eq @user.initial_data["feature_#{@channel}"].to_i + 1   #depends on previous test
  end

end
