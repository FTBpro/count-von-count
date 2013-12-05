require "spec_helper"
describe "Utils" do
  describe "Android bad Query String with amp;" do

    before :each do
      @user = create :User
      @author = create :User
      open("http://#{HOST}/reads?user=#{@user.id}&amp;author=#{@author.id}")
    end

    context "it should replace &amp; with &" do
      it "should have a correct redis key for user" do
        $redis.keys("*").include?(@user.key).should be_true
      end


      it "should have a correct redis key for other user" do
        $redis.keys("*").include?(@author.key).should be_true
      end
    end
  end
end
