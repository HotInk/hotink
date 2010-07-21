require 'spec_helper'

describe UserInvitationsController do
  before do
     @account = Factory(:account)
   end
   
  describe "POST to create" do
    before do
      @user = Factory(:user)
      @user.has_role('staff', @account)
      @user.has_role('manager', @account)
      controller.stub!(:current_user).and_return(@user)
    end
    
    context "to a valid email address" do
      before do  
        post :create, :account_id => @account.id, :invitation => { :email => "a-valid@email.address.com" }
      end

      it { should respond_with(:success) }
      it { should set_the_flash.to("User contacted and added to your account") }
      it "should issue a valid invitation" do
        should assign_to(:invite).with_kind_of(UserInvitation)
        assigns(:invite).should_not be_new_record
        assigns(:invite).user.should == @user
        assigns(:invite).account.should == @account
      end
    end
    
    context "to an invalid email address" do
      before do   
        post :create, :account_id => @account.id, :invitation => { :email => "not-a-valid-email.address.com" }
      end

      it { should respond_with(:success) }
      it { should set_the_flash.to("Can't work with that. It's not a valid email.") }
      it "should not issue an invitation" do
        should assign_to(:invite).with_kind_of(UserInvitation)
        assigns(:invite).should be_new_record
      end
    end
  end
  
  describe "GET to edit" do
    before do
      @invite = Factory(:user_invitation, :account => @account)
    end
    
    context "with a valid invitation" do
      before do
        get :edit, :account_id => @account.id, :id => @invite.token
      end
      
      it { should respond_with(:success) }
      it { should assign_to(:invite).with(@invite) }
      it { should render_template(:edit) }
      it { should render_with_layout(:login) }
      it "should create a new user for the invite" do
        assigns(:user).email.should == @invite.email
      end
    end
    context "with a redeemed invitation" do
      before do
        @invite.redeem!
        get :edit, :account_id => @account.id, :id => @invite.token
      end
      
      it { should assign_to(:invite).with(@invite) }
      it { should respond_with(:redirect) }
    end
  end

  describe "PUT to update" do
    before do
      @invite = Factory(:user_invitation)
    end
    
    context "with valid user parameters" do
      before do
        put :update, :account_id => @invite.account.id, :id => @invite.token, :user => Factory.attributes_for(:user)
      end
      
      it { should respond_with(:redirect) }
      it { should set_the_flash.to("Please login to confirm your credentials.") }
      it "should create user with appropriate account permissions" do
        should assign_to(:user).with_kind_of(User)
        assigns(:user).should_not be_new_record
        assigns(:user).should have_role('staff', @invite.account)
      end
      it "should redeem invite" do
        should assign_to(:invite).with(@invite)
        @invite.reload.should be_redeemed
      end
    end
      
    context "with invalid user parameters" do
      before do
        put :update, :account_id => @invite.account.id, :id => @invite.token, :user => Factory.attributes_for(:user, :email => "")
      end
      
      it { should render_template(:edit) }
      it "should not create user" do
        should assign_to(:user).with_kind_of(User)
        assigns(:user).should be_new_record
      end
      it "should not redeem invite" do
        should assign_to(:invite).with(@invite)
        @invite.reload.should_not be_redeemed
      end
    end
    
    context "with an already redeemed invitation" do
      before do
        @invite.redeem!
        put :update, :account_id => @invite.account.id, :id => @invite.token
      end
      
      it { should respond_with(:redirect) }
      it { should_not assign_to(:user) }
    end
  end

  describe "DELETE to destory" do
    before do
      @user = Factory(:user)
      @user.has_role('staff', @account)
      @user.has_role('manager', @account)
      controller.stub!(:current_user).and_return(@user) 
      
      @invite = Factory(:user_invitation, :account => @account) 
      delete :destroy, :account_id => @account.id, :id => @invite.token
    end
    
    it { should assign_to(:invite).with(@invite) }
    it "should delete the invitation" do
      lambda { UserInvitation.find(@invite.id) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end