require 'spec_helper'

describe Author do
  before(:each) do
    @author = Author.create!(Factory.attributes_for(:author))
  end
  
  it { should belong_to(:account) }
  it { should validate_presence_of(:account).with_message(/must have an account/) }
  it { should validate_presence_of(:name).with_message(/must have a name/) }
  it { should validate_uniqueness_of(:name).scoped_to(:account_id) }
  
  it "should convert to liquid for use in templates" do
    @author.to_liquid.should == { 'name' => @author.name, 'id' => @author.id }
  end
end