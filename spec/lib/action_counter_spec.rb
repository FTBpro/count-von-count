require 'spec_helper'
require 'script_loader'
describe "ActionCounter" do
  before do
    ScriptLoader.load
  end
  context "post reads" do
    it "should increment post reads by 1" do
      expect { `curl "http://localhost:8090/reads?post_id=131&user_slug=shai.k"`}.to change { Integer(`redis-cli get 'post_reads_131'`)}.by(1)
      # Integer(`redis-cli get 'post_reads_131'`).should eq (@old_reads_count + 1)
    end
  end
end
