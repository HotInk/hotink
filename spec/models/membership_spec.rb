require 'spec_helper'

describe Membership do
  before(:each) do
    @account = Factory(:account)
    @membership = Membership.create!( :account => @account )
  end
  
  it { should belong_to(:account) }
end
