require 'spec_helper'

describe Membership do
  before(:each) do
    @network_owner = Factory(:account)
    @account = Factory(:account)
    @membership = Membership.create!( :account => @account, :network_owner => @network_owner )
  end
  
  it { should belong_to(:account) }
  it { should validate_presence_of(:account) }
  
  it { should belong_to(:network_owner) }
  it { should validate_presence_of(:network_owner) }
end
