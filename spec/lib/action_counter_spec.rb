require 'spec_helper'

describe "ActionCounter" do
  before :all do
    `ruby lib/load_nginx_lua_script.rb`
  end
  before do
    @old_reads_count = Integer(`redis-cli get 'post_reads_131'`)
    `curl "http://localhost:8090/reads?post_id=131&user_slug=shai.k"`
  end
  context "post reads" do
    it "should increment post reads by 1" do
      Integer(`redis-cli get 'post_reads_131'`).should eq (@old_reads_count + 1)
    end
  end
end
