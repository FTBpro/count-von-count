require 'spec_helper'
describe "Get" do
  before do
    @user = create :User
    @author= create :User
    open("http://#{HOST}/reads?user=#{@user.id}&author=#{@author.id}")
  end

  def get(query_string)
    JSON.parse(open("http://#{HOST}/get?#{query_string}").read.gsub("\n", "") )
  end

  describe "Header" do
  	it "should have a 'Access-Control-Allow-Origin *' in the response header" do
  	  response = open("http://#{HOST}/get?key=User_#{@user.id}")
  	  response.meta.keys.should include "access-control-allow-origin"
  	  response.meta["access-control-allow-origin"].should == "*"
  	end
  end

  describe "Hash key" do
    describe "single key" do
      it "should return a json with all the attributes of the key when attr params are not defined" do
        hash = get("key=User_#{@user.id}")
        hash.keys.sort.should match_array(["reads"])
      end

      it "should return a json containing only the values defined by the attr array parameter in the query string" do
        hash = get("key=User_#{@user.id}&attr[]=reads&attr[]=logins")
        hash.keys.sort.should match_array(["logins", "reads"])
      end

      context "when attribute doesnt exist" do
        it "should return nil" do
          hash = get("key=User_#{@user.id}&attr[]=reads&attr[]=logins")
          hash["reads"].to_i.should eq 1
          hash.keys.should match_array(["logins", "reads"])
          hash["logins"].should eq nil
        end
      end

      context "when only attribute defined" do
        it "should return only the value of the desired attribute" do
          rslt = open("http://#{HOST}/get?key=User_#{@user.id}&attr=reads").read.gsub("\n", "")
          rslt.should == "1"
        end
      end

      context "as array" do
	      it "should return a json with a single key equal to the requested key and its value as hash" do
	        hash = get("key[]=User_#{@user.id}")
	        hash.keys.should match_array([@user.key])
	        hash[@user.key].keys.should match_array(["reads"])
	      end
	    end
    end
  end

  describe "multiple keys" do
  	describe "without attributes" do
  		it "should return a json with the given keys as keys and for each key a hash with all of its attributes " do
        hash = get("key[]=#{@user.key}&key[]=#{@author.key}")
        hash.keys.should match_array([@user.key, @author.key])
        hash[@user.key].keys.should match_array(["reads"])
        hash[@author.key].keys.should match_array(["reads_got"])
  		end
  	end

  	describe "with attributes" do
  		it "should return a json with the given keys as keys and for each key a hash with all the given attributes" do
  		  hash = get("key[]=#{@user.key}&key[]=#{@author.key}&attr[]=reads&attr[]=logins")
  		  hash.keys.should match_array([@user.key, @author.key])
        hash[@user.key].keys.should match_array(["logins", "reads"])
        hash[@author.key].keys.should match_array(["logins", "reads"])
  		end

      context "multiple attributes" do
        before do
          open("http://#{HOST}/reads?user=#{@author.id}")
        end
        it "should return a json with the given keys as keys and for each key a value for the given attribute (single attribute)" do
          hash = get("key[]=#{@user.key}&key[]=#{@author.key}&attr=reads")
          hash.keys.should match_array([@user.key, @author.key])
          hash[@user.key].should eq "1"
          hash[@author.key].should eq "1"
        end
      end

  		it "should return a json with the given keys as keys and for each key a hash with the given attribute (single attribute as array)" do
  		  hash = get("key[]=#{@user.key}&key[]=#{@author.key}&attr[]=reads")
  		  hash.keys.should match_array([@user.key, @author.key])
        hash[@user.key].keys.should match_array(["reads"])
        hash[@author.key].keys.should match_array(["reads"])
  		end
  	end
  end
end
