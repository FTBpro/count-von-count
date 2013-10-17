require 'spec_helper'

describe "MWP Vote" do
  before :all do
    @user = create :User
  end

  before :all do
    open("http://#{HOST}/votes_mwp?user=#{@user.id}")
  end

  it "should increase the user's num of MWP votes by 1" do
    @user.data["votes_mwp"].to_i.should eq @user.initial_data["votes_mwp"].to_i + 1
  end

end
