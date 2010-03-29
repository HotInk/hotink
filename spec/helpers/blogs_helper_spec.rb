require 'spec_helper'

describe BlogsHelper do
  include BlogsHelper
  
  it "should generate slug" do
    generate_slug(nil).should eql(nil)
    generate_slug("").should eql("")
    generate_slug(" a  ").should eql("a")
    generate_slug("A a").should eql("a-a")
    generate_slug("12aa").should eql("12aa")
    
    generate_slug("&").should eql("")
    generate_slug("a12's").should eql("a12s")
    generate_slug("a12@77.com").should eql("a12-77-com")
    generate_slug("a12@@77").should eql("a12-77")
    
    generate_slug("a123@@").should eql("a123")
    generate_slug("@@a123").should eql("a123")
    
    generate_slug("Phở").should eql("phở")
  end
end