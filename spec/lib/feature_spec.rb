require 'spec_helper'

describe "Login" do
  before :all do
    @channels = ["site", "mobile", "telegraph"]
    @user = create :User
  end

  before :all do
    open("http://#{HOST}/feature?user=#{@user.id}&" + @channels.map { |c| "channel[]=#{c}"}.join("&") )
    url = "http://#{HOST}/feature?user=#{@user.id}&" + @channels.map { |c| "channel[]=#{c}"}.join("&") 
  end

  it "should increase the user's num of featured posts according to the given channels" do
    @channels.each do |channel|  
      @user.data["feature_#{channel}"].to_i.should eq @user.initial_data["feature_#{channel}"].to_i + 1
    end
  end

  it "should increase the user's num of featured posts according to the given channel" do
    other_channel = "stam"
    open("http://#{HOST}/feature?user=#{@user.id}&channel=#{other_channel}")
    @user.data["feature_#{other_channel}"].to_i.should eq @user.initial_data["feature_#{other_channel}"].to_i + 1
    @channels.each do |channel|  
      @user.data["feature_#{channel}"].to_i.should eq @user.initial_data["feature_#{channel}"].to_i + 1
    end
  end

end
