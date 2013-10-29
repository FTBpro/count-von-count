require 'spec_helper'

describe "Expire test" do

  before :all do
    open("http://#{HOST}/expire_test")
  end

  it "should set a ttl to the key" do
    $redis.ttl("ExpireTest").should > 0
  end

  it "should not increase the ttl of the key" do
    ttl = $redis.ttl("ExpireTest")
    sleep(2)
    open("http://#{HOST}/expire_test")
    $redis.ttl("ExpireTest").should < ttl
  end

end
