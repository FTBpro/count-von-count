require 'spec_helper'

describe "Follow/Unfollow" do
  before :all do
    @user = create :User
    @other_user = create :User
  end


  describe "Follow" do
    before :all do
      open("http://#{HOST}/follow?user=#{@user.id}&other_user=#{@other_user.id}")
    end

    it "should increase the user's num of follow by 1" do
      @user.data["follow"].to_i.should eq @user.initial_data["follow"].to_i + 1
    end

    it "should increase the user's num of follow_actions_total by 1" do
      @user.data["follow_actions_total"].to_i.should eq @user.initial_data["follow_actions_total"].to_i + 1
    end

    it "should increase the other user's num of followers by 1" do
      @other_user.data["followers"].to_i.should eq @other_user.initial_data["followers"].to_i + 1
    end

    it "should increase the other user's num of followers_actions_total by 1" do
      @other_user.data["followers_actions_total"].to_i.should eq @other_user.initial_data["followers_actions_total"].to_i + 1
    end
  end

  describe "Unfollow" do  #depends on the "Follow" specs
    before :all do
      open("http://#{HOST}/unfollow?user=#{@user.id}&other_user=#{@other_user.id}")
    end

    it "should decrease the user's num of follow by 1" do
      @user.data["follow"].to_i.should eq @user.initial_data["follow"].to_i 
    end

    it "should not decrease the user's num of follow_actions_total" do
      @user.data["follow_actions_total"].to_i.should eq @user.initial_data["follow_actions_total"].to_i + 1
    end

    it "should decrease the other user's num of followers by 1" do
      @other_user.data["followers"].to_i.should eq @other_user.initial_data["followers"].to_i
    end

    it "should not decrease the other user's num of followers_actions_total" do
      @other_user.data["followers_actions_total"].to_i.should eq @other_user.initial_data["followers_actions_total"].to_i + 1   
    end    
  end
end
