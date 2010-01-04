require 'spec_helper'

describe AccountInvitation do
  before(:each) do
    @invitation = Factory(:account_invitation)
  end

  describe "when created" do
    before do
      @invite = Factory.build(:account_invitation)
    end
    
    it "should deliver an account invitation email for a new Hot Ink user" do
      Circulation.should_receive(:deliver_account_invitation).with(@invite)
      @invite.save
    end 
  end
end
