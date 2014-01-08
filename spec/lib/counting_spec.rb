require 'spec_helper'
require 'ruby-debug'
describe "Counting" do
  before :each do
    @user = create :User, id: 10
    @author = create :User, id: 30
    @post = create :Post, id: 100
  end

  describe "reads action" do

    describe "User Hash" do
      before do
        open("http://#{HOST}/reads?post=#{@post.id}&user=#{@user.id}&author=#{@author.id}")
      end
      it "should increase the reads of the user by one" do
        @user.should_plus_1("reads")
      end

      describe "Author" do
        it "should increase the post's author num of time he's been read" do
          @author.should_plus_1("reads_got")
        end
      end
    end

    describe "Post Hash" do
      before do
        open("http://#{HOST}/reads?post=#{@post.id}")
      end
      it "should increase the post reads counter" do
        @post.should_plus_1("reads")
      end
    end

    describe "UserDaily Hash" do
      before do
        @user_daily = create :UserDaily, { user: @user.id, day: Time.now.strftime("%d"), month: Time.now.strftime("%m"), year: Time.now.strftime("%Y") }
        open("http://#{HOST}/reads?user=#{@user.id}")
      end
      it "should increase the daily reads of the user by one" do
        @user_daily.should_plus_1("reads")
      end

      it "should set a TTL for the objects" do
        $redis.ttl(@user_daily.key).should > 0
      end
    end

    # describe "AuthorWeeklyDemographics Hash" do
    #   before do
    #     @author_weekly_demographics = create :UserWeeklyDemographics, {user: @author.id, week: Time.now.strftime("%W"), year: Time.now.strftime("%Y")}
    #     open("http://#{HOST}/reads?author=#{@author.id}")
    #   end
    #   it "should increase reads counter" do
    #     @author_weekly_demographics.should_plus_1("--")
    #   end
    # end
  end

  describe "comments action" do
    before :each do
      open("http://#{HOST}/comments?user=#{@user.id}&author=#{@author.id}")
    end

    describe "User Hash" do
      it "should increase the user's num of comments by 1" do
        @user.should_plus_1("comments")
      end

      describe "Author" do
        it "should increase the post's author num of comments he got" do
          @author.should_plus_1("comments_got")
        end
      end
    end

    describe "Post Hash" do
      before :each do
        open("http://#{HOST}/comments?post=#{@post.id}")
      end
      it "should increase the post's num of comments" do
        @post.should_plus_1("comments")
      end
    end
  end

  describe "post_create action" do
    # before do
    #   open("http://#{HOST}/post_create?user=#{@user.id}")
    # end
    # it "should increase the user's num of posts created by 1" do
    #   @user.should_plus_1("post_create")
    # end

    # describe "TeamCounters" do
    #   #TODO: Add spec
    # end

    # describe "TeamWriters" do
    #   #TODO: Add spec
    # end
  end

  describe "post_remove action" do
    before do
      open("http://#{HOST}/post_remove?user=#{@user.id}")
    end
    it "should decrease the user's number of post_create" do
      @user.should_minus_1("post_create")
    end
  end
end
