require 'spec_helper'

describe "Login" do
  before :all do
    @user = create :User
    @user_daily = create :UserDaily, { user: @user.id, day: Time.now.strftime("%d"), month: Time.now.strftime("%m"), year: Time.now.strftime("%Y") }
  end

  before :all do
    open("http://#{HOST}/logins?user=#{@user.id}")
  end

  it "should increase the user's num of logins by 1" do
    @user.data["logins"].to_i.should eq @user.initial_data["logins"].to_i + 1
  end

  describe "UserDaily" do
    it "should increase the daily logins of the user by one" do
      @user_daily.data["logins"].to_i.should eq @user_daily.initial_data["logins"].to_i + 1
    end

    it "should set a TTL for the objects" do
      $redis.ttl(@user_daily.key).should > 0
    end
  end

end
