require 'spec_helper'

describe "Login" do
  before :all do
    @user = create :User
  end

  before :all do
    open("http://#{HOST}/logins?user=#{@user.id}")
  end

  it "should increase the user's num of logins by 1" do
    @user.data["logins"].to_i.should eq @user.initial_data["logins"].to_i + 1
  end

end
