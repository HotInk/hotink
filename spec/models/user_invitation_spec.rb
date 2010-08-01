require 'spec_helper'

describe UserInvitation do
  before(:each) do
    @invitation = Factory(:user_invitation)
  end
  
  it "should be an invitation to use a particular account" do
    should belong_to(:account)
    should validate_presence_of(:account)
  end
  
  it "should validate that it belongs to the user that created it" do
    should validate_presence_of(:user)
  end

  describe "when created" do
    before do
      @invite = Factory.build(:user_invitation)
    end
    
    it "should deliver a user invitation email for a new Hot Ink user" do
      Circulation.should_receive(:deliver_user_invitation).with(@invite.account, @invite)
      @invite.save
    end
  
    it "should deliver a notification email and give account access for an existing Hot Ink user" do
      @existing_user = Factory(:user)
      @invite.email = @existing_user.email
      Circulation.should_receive(:deliver_account_access_notification).with(@invite.account, @invite)
      @invite.save
      @invite.should be_redeemed
      @existing_user.has_role?('staff', @invite.account).should be_true
    end
  
  end
end
