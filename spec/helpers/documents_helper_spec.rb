require 'spec_helper'

describe DocumentsHelper do
  include DocumentsHelper
  
  it "should extract Time object from parameter hash" do
    extract_time({  :month =>"1", 
                    :minute=>"31", 
                    :hour=>"11", 
                    :day=>"26", 
                    :year=>"2010"
                }).should == Time.local(2010, 1, 26, 11, 31)
    extract_time(nil).should == nil
  end
end