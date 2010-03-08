require 'spec_helper'

describe AccountsHelper do
  include AccountsHelper
  
  it "find height from ImageMagick geometry string" do
    geometry_string_height("222x").should be_blank
    geometry_string_height("x555").should == "555"
    geometry_string_height("333x777").should == "777"
  end
  
  it "find width from ImageMagick geometry string" do
    geometry_string_width("222x").should == "222"
    geometry_string_width("x555").should be_blank
    geometry_string_width("333x777").should == "333"
  end
end
