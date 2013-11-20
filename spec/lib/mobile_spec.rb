require 'spec_helper'

describe "Mobile" do

  before :each do
    @date = Date.today.strftime("%Y-%m-%d")
    @params = { id: 1, locale: "en", team_id: 23, article_pn: 1, match_pn: 1 }
  end

  def hash_to_query_string(hash)
    hash.map { |k,v| "#{k}=#{v}" }.join("&")
  end

  describe "Active" do
    before :each do
      @params[:action] = "active"
      @end_point = "http://#{HOST}/mobile?#{hash_to_query_string(@params)}"
      @key_prefix = "mobile_activity"
      @key_prefix_long = "mobile_activity_#{@params[:locale]}_team_#{@params[:team_id]}"
      open(@end_point)
    end

    it "should set the bit in the map according to the device id, date, locale and team" do
      $redis.getbit("#{@key_prefix_long}_article_pn_#{@params[:article_pn]}_#{@date}", @params[:id]).should eq 1
      $redis.getbit("#{@key_prefix_long}_article_pn_#{@params[:match_pn]}_#{@date}", @params[:id]).should eq 1
    end

    it "should set the bit in the general map according to the device id and date" do
      $redis.getbit("#{@key_prefix}_article_pn_#{@params[:article_pn]}_#{@date}", @params[:id]).should eq 1
      $redis.getbit("#{@key_prefix}_article_pn_#{@params[:match_pn]}_#{@date}", @params[:id]).should eq 1
    end

    describe "Using same bitmap" do
      before :each do
        @params[:id] = "7"
        @end_point = "http://#{HOST}/mobile?#{hash_to_query_string(@params)}"
        $redis.bitcount("#{@key_prefix_long}_article_pn_#{@params[:article_pn]}_#{@date}").should eq 1
        $redis.bitcount("#{@key_prefix_long}_article_pn_#{@params[:match_pn]}_#{@date}").should eq 1
        $redis.bitcount("#{@key_prefix}_article_pn_#{@params[:article_pn]}_#{@date}").should eq 1
        $redis.bitcount("#{@key_prefix}_article_pn_#{@params[:match_pn]}_#{@date}").should eq 1
        open(@end_point)
      end

      it "should set the bit in the same map as in previous spec, but for a different bit" do
        $redis.bitcount("#{@key_prefix_long}_article_pn_#{@params[:article_pn]}_#{@date}").should eq 2
        $redis.bitcount("#{@key_prefix_long}_article_pn_#{@params[:match_pn]}_#{@date}").should eq 2
        $redis.bitcount("#{@key_prefix}_article_pn_#{@params[:article_pn]}_#{@date}").should eq 2
        $redis.bitcount("#{@key_prefix}_article_pn_#{@params[:match_pn]}_#{@date}").should eq 2
      end
    end
  end


  describe "Push Notification" do
    before :each do
      @params[:action] = "pn"
    end

    describe "with valid pn_type parameter" do
      before :each do
        @params[:pn_type] = "received_post"
        @end_point = "http://#{HOST}/mobile?#{hash_to_query_string(@params)}"
      end

      it "should increase by 1 the PN Received counter according to the device id, date, locale and team" do
        key = "pn_#{@params[:pn_type]}_#{@params[:locale]}_team_#{@params[:team_id]}_#{@date}"
        value = $redis.get(key) || 0
        open(@end_point)
        $redis.get(key).to_i.should eq value.to_i + 1
      end

      it "should increase by 1 the general PN Received counter according to the device id, date" do
        key = "pn_#{@params[:pn_type]}_#{@date}"
        value = $redis.get(key) || 0
        open(@end_point)
        $redis.get(key).to_i.should eq value.to_i + 1
      end
    end

    describe "with invalid pn_type parameter" do
      before :each do
        @params[:pn_type] = "bla"
        @end_point = "http://#{HOST}/mobile?#{hash_to_query_string(@params)}"
      end

      it "should not increase by 1 the PN Received counter according to the device id, date, locale and team" do
        key = "pn_#{@params[:pn_type]}_#{@params[:locale]}_team_#{@params[:team_id]}_#{@date}"
        value = $redis.get(key) || 0
        open(@end_point)
        $redis.get(key).to_i.should eq value.to_i
      end

      it "should not increase by 1 the general PN Received counter according to the device id, date" do
        key = "pn_#{@params[:pn_type]}_#{@date}"
        value = $redis.get(key) || 0
        open(@end_point)
        $redis.get(key).to_i.should eq value.to_i
      end
    end
  end

  describe "expire" do
    it "should have a ttl of 1 month for all mobile related keys" do
      keys = $redis.keys("mobile_*") + $redis.keys("pn_*")
      keys.each do |key|
        $redis.ttl(key).should > 0
      end
    end
  end

end
