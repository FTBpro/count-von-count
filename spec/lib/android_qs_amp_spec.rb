require 'spec_helper'

describe "Android bad Query String with amp;" do
  before :each do
    @user = create :User, id: 100
    @other_user = create :User, id: 200
    open("http://#{HOST}/follow?user=#{@user.id}&amp;other_user=#{@other_user.id}")
  end


  describe "Follow action as a use case" do

    it "should have a correct redis key for user" do
      $redis.keys("*").include?("User_#{@user.id}").should be_true
    end


    it "should have a correct redis key for other user" do
      $redis.keys("*").include?("User_#{@other_user.id}").should be_true
    end
  end
end
