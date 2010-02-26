require 'spec_helper'

describe ApplicationHelper do
  include ApplicationHelper
  
  it "should neatly truncate long strings as required" do
        truncate_words('one two three', 4).should == 'one two three'
        truncate_words('one two three', 2).should == 'one two...'
        truncate_words('one two three').should == 'one two three'
        truncate_words('Two small (13&#8221; x 5.5&#8221; x 10&#8221; high) baskets fit inside one large basket (13&#8221; x 16&#8221; x 10.5&#8221; high) with cover.', 15).should == 
            'Two small (13&#8221; x 5.5&#8221; x 10&#8221; high) baskets fit inside one large basket (13&#8221;...'
  end
  
end
