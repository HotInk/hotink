require 'spec_helper'

describe Account do
  before(:each) do
    @account = Account.create!(Factory.attributes_for(:account))
  end
  
  it { should validate_presence_of(:time_zone).with_message(/must indicate its preferred time zone/) }
  it { should validate_presence_of(:name).with_message(/must have a name/) }
  it { should validate_uniqueness_of(:name).with_message(/must be unique/) }
  it { should have_many(:articles) }
  
end