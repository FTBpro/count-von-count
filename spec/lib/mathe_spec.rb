require 'spec_helper'
require 'mathe'

describe Mathe do
  describe :add do
    it "should add well" do
      Mathe.add(1,2).should eq 3
    end
  end
end
