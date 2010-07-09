require 'spec_helper'

describe PagesHelper do
  include PagesHelper
  
  it "should build an ordered array of pages with child pages following their parent page" do
    account = Factory(:account)
    page1 = Factory(:page, :name => "alabama", :account => account)
    page2 = Factory(:page, :name => "arkansas", :account => account)
    child1 = Factory(:page, :parent => page1, :name => "birmingham", :account => account)
    child2 = Factory(:page, :parent => page2, :name => "hope", :account => account)
    child3 = Factory(:page, :parent => page2, :name => "little-rock", :account => account)
    grandchild1 = Factory(:page, :parent => child2, :name => "bill-clinton", :account => account)
    
    page_form_options_collection(account).should == [page1, child1, page2, child2, grandchild1, child3]
  end
  
end
