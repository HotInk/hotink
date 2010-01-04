require 'spec_helper'

describe Invitation do
  before(:each) do
    @invitation = Factory(:invitation)
  end
  
  it "should belong to the user that created it" do
    should belong_to(:user)
    should validate_presence_of(:user)
  end
  
  it "should be an invitation to use a particular account" do
    should belong_to(:account)
    should validate_presence_of(:account)
  end
  
  it "should only be created with a valid email address" do
    should validate_presence_of(:email)
    should allow_value("chris@hotink.net").for(:email)
    should allow_value("chris+atestwith345@sub.hotink.net").for(:email)
    should_not allow_value("hotink.net").for(:email)
    should_not allow_value("12412").for(:email)
    should_not allow_value("chris@hotink.net.").for(:email)    
  end
  
  describe "when created" do
    before do
      @invite = Factory.build(:invitation)
    end
    
    it "should deliver an invitation email to a new Hot Ink user" do
      Circulation.should_receive(:deliver_invitation).with(@invite.account, @invite)
      @invite.save
    end
  
    it "should deliver a notification email and add an existing Hot Ink user" do
      @existing_user = Factory(:user)
      @invite.email = @existing_user.email
      Circulation.should_receive(:deliver_account_access_notification).with(@invite.account, @invite)
      @invite.save
      @invite.should be_redeemed
      @existing_user.has_role?('staff', @invite.account).should be_true
    end

    it "should generate a token" do
      @invite.save
      @invite.token.should == Digest::SHA1.hexdigest("--#{@invite.email}--#{@invite.created_at.to_s}--")
    end
  
  end

  it "should only be redeemable once" do
    @invitation.redeem!.should be_true
    @invitation.redeem!.should be_false
  end

  it "should use token as its html parameter" do
    @invitation.to_param.should == @invitation.token
  end
end
