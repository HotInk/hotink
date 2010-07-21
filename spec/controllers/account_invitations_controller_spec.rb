require 'spec_helper'

describe AccountInvitationsController do
  
  describe "POST to create" do
    before do
      @user = Factory(:user)
      @user.has_role('admin')
      controller.stub!(:current_user).and_return(@user) 
      @accounts = (1..3).collect{ Factory(:account) }
    end
    
    context "to a valid email address" do
        before do   
          post :create, :invitation => { :email => "a-valid@email.address.com", :type => 'AccountInvitation' }
        end
        
        it { should respond_with(:success) }
        it { should assign_to(:accounts).with(@accounts) }
        it { should set_the_flash.to("Account invitation sent.")}
        it "should issue a valid invitation" do
          should assign_to(:invite).with_kind_of(AccountInvitation)
          assigns(:invite).should_not be_new_record
          assigns(:invite).user.should == @user
        end
    end
    
    context "to an invalid email address" do
      before do   
        post :create, :invitation => { :email => "an-invalid-email", :type => 'AccountInvitation' }
      end
      
      it { should set_the_flash.to("Can't work with that. It's not a valid email.") }
      it "should not create an invitation" do
        assigns(:invite).should be_new_record
      end
    end
  end

  describe "GET to edit" do
    context "with an account invitation" do
      before do
        @invite = Factory(:account_invitation)
        get :edit, :id => @invite.token
      end
      
      it { should respond_with(:success) }
      it { should assign_to(:invite).with(@invite) }
      it { should render_template(:edit) }
      it { should render_with_layout(:login) }
      it "should create a new user for the invite" do
        should assign_to(:user).with(@user)
        assigns(:user).email.should == @invite.email
      end
    end
    
    context "with a redeemed invitation" do
      before do
        @invite = Factory(:account_invitation)
        @invite.redeem!
        get :edit, :id => @invite.token
      end
      
      it { should assign_to(:invite).with(@invite) }
      it { should respond_with(:redirect) }
    end
  end
  
  describe "PUT to update" do
    context "with a valid account invitation" do
      before do
        @invite = Factory(:account_invitation)
      end
  
      context "as a new user" do
         context "with valid account and user parameters" do
           before do
             put :update, :id => @invite.token, :account => Factory.attributes_for(:account), :user => Factory.attributes_for(:user)
           end

           it { should set_the_flash.to("Your account has been created! Please login to confirm your user credentials.") }
           it { should respond_with(:redirect) }
           it "should create an account" do
             should assign_to(:account).with_kind_of(Account)
             assigns(:account).should_not be_new_record
           end
           it "should create user with appropriate account permissions" do
             should assign_to(:user).with_kind_of(User)
             assigns(:user).should_not be_new_record
             assigns(:user).should have_role('staff', assigns(:account))
             assigns(:user).should have_role('manager', assigns(:account))
           end
           it "should redeem invite" do
             should assign_to(:invite).with(@invite)
             @invite.reload.should be_redeemed
           end
         end

         context "with valid account and invalid user parameters" do
           before do
             put :update, :id => @invite.token, :account => Factory.attributes_for(:account), :user => Factory.attributes_for(:user, :email => "")
           end

           it { should respond_with(:success) }
           it { should render_template('account_invitations/edit') }
           it "should not create an account" do
             should assign_to(:account).with_kind_of(Account)
             assigns(:account).should be_new_record
           end
           it "should not create user" do
             should assign_to(:user).with_kind_of(User)
             assigns(:user).should be_new_record
           end
           it "should not redeem invite" do
             should assign_to(:invite).with(@invite)
             @invite.reload.should_not be_redeemed
           end
         end

         context "with invalid account and valid user parameters" do
           before do
             put :update, :id => @invite.token, :account => Factory.attributes_for(:account, :name => ""), :user => Factory.attributes_for(:user)
           end

           it { should respond_with(:success) }
           it { should render_template('account_invitations/edit') }
           it "should not create an account" do
             should assign_to(:account).with_kind_of(Account)
             assigns(:account).should be_new_record
           end
           it "should not create user" do
             should assign_to(:user).with_kind_of(User)
             assigns(:user).should be_new_record
           end
           it "should not redeem invite" do
             should assign_to(:invite).with(@invite)
             @invite.reload.should_not be_redeemed
           end
         end
      end

      context "as an existing user" do
         before do
           @user = Factory(:user)
         end
     
         context "with valid account parameters" do
           before do
             put :update, :id => @invite.token, :account => Factory.attributes_for(:account), :user_id => @user.id
           end

           it { should set_the_flash.to("Your account has been created! Please login to confirm your user credentials.") }
           it { should respond_with(:redirect) }
           it "should create an account" do
             should assign_to(:account).with_kind_of(Account)
             assigns(:account).should_not be_new_record
           end
           it "should assign appropriate account permissions to user" do
             should assign_to(:user).with(@user)
             @user.should have_role('staff', assigns(:account))
             @user.should have_role('manager', assigns(:account))
           end
           it "should redeem invite" do
             should assign_to(:invite).with(@invite)
             @invite.reload.should be_redeemed
           end
         end
       end
     end
     
    context "with an already redeemed invitation" do
      before do
        @invite = Factory(:account_invitation)
        @invite.redeem!
        put :update, :id => @invite.token
      end

      it { should respond_with(:redirect) }
    end
  end

  describe "DELETE to destroy" do
    before do
      @user = Factory(:user)
      @user.has_role('admin')
      controller.stub!(:current_user).and_return(@user) 
      @invite = Factory(:account_invitation)
      
      delete :destroy, :id => @invite.token
    end
    
    it { should assign_to(:invite).with(@invite) }
    it "should delete the invitation" do
      lambda { AccountInvitation.find(@invite.id) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end