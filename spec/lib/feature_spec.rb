require 'spec_helper'

describe "Login" do
  before :all do
    @channels = ["site", "mobile", "telegraph"]
    @user = create :User
    @category = "Lists"
    @locale = "en"
    @category_monthly_featured = create :CategoryMonthlyFeatured, { category: @category, locale: @locale, month: Time.now.strftime("%m"), year: Time.now.strftime("%Y") }
    @other_channel = "stam"
  end

  before :all do
    open("http://#{HOST}/feature?user=#{@user.id}&locale=#{@locale}&countcategory=1&category=#{@category}&" + @channels.map { |c| "channel[]=#{c}"}.join("&") )
    # url = "http://#{HOST}/feature?user=#{@user.id}&" + @channels.map { |c| "channel[]=#{c}"}.join("&") 
  end

  describe "User" do
    it "should increase the user's num of featured posts according to the given channels" do
      @channels.each do |channel|  
        @user.data["feature_#{channel}"].to_i.should eq @user.initial_data["feature_#{channel}"].to_i + 1
      end
    end

    it "should increase the user's num of featured posts according to the given channel" do
      open("http://#{HOST}/feature?user=#{@user.id}&locale=#{@locale}&countcategory=1&category=funny&channel=#{@other_channel}")
      @user.data["feature_#{@other_channel}"].to_i.should eq @user.initial_data["feature_#{@other_channel}"].to_i + 1
      @channels.each do |channel|  
        @user.data["feature_#{channel}"].to_i.should eq @user.initial_data["feature_#{channel}"].to_i + 1
      end
    end
  end


  describe "CategoryMonthlyFeatured" do
    it "should increase the user num of featured posts in the given category" do
      @category_monthly_featured.set["user_#{@user.id}"].should eq @category_monthly_featured.initial_set["user_#{@user.id}"] + 1
    end

    it "should not count if there is no category" do
      keys_count = $redis.keys("*").size
      open("http://#{HOST}/feature?user=#{@user.id}&locale=#{@locale}&countcategory=1&category=&channel=#{@other_channel}")
      $redis.keys("*").size.should eq keys_count
    end

    it "should not count if 'countcategory' parameter is false (or 0)" do
      keys_count = $redis.keys("*").size
      open("http://#{HOST}/feature?user=#{@user.id}&locale=#{@locale}&countcategory=0&category=#{@category}&channel=#{@other_channel}")
      @category_monthly_featured.set["user_#{@user.id}"].should eq @category_monthly_featured.initial_set["user_#{@user.id}"] + 1
    end    
  end

end
