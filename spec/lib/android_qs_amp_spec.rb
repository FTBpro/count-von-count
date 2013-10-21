require 'spec_helper'

describe "Android bad Query String with amp;" do
  before :all do
    @user = create :User
    @other_user = create :User
  end


  describe "Follow action as a use case" do
    before :all do
      open("http://#{HOST}/follow?user=#{@user.id}&amp;other_user=#{@other_user.id}")
    end

    it "should have a correct redis key for other user" do
      $redis.keys("*").include?("User_#{@user.id}").should be_true
    end


    it "should have a correct redis key for other user" do
      $redis.keys("*").include?("User_#{@other_user.id}").should be_true
    end
  end
end
