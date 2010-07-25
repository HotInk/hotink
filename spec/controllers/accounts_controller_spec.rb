require 'spec_helper'

describe AccountsController do
    
  describe "GET to new" do
    context "when no accounts exists" do
      before do
        get :new
      end
      
      it { should assign_to(:account).with_kind_of(Account) }
      it { should assign_to(:user).with_kind_of(User) }
      it { should respond_with(:success) }
      it { should respond_with_content_type(:html) }
      it { should render_with_layout('login') }
      it { should render_template('accounts/first_account_form') }
    end
    
    context "when accounts exist" do
      before do
        @accounts = (1..3).collect{ Factory(:account) }
        get :new
      end
      
      it { should_not assign_to(:account) }
      it { should_not assign_to(:user) }
      it { should respond_with(:not_found) }
    end
  end
  
  describe "POST to create" do
    context "when accounts exist" do
      before do
        @accounts = (1..3).collect{ Factory(:account) }
        post :create, :account => Factory.attributes_for(:account), :user => Factory.attributes_for(:user)
      end
      
      it { should_not assign_to(:account) }
      it { should_not assign_to(:user) }
      it { should respond_with(:not_found) }
    end
    
    context "when no accounts exist" do
      context "with valid parameters" do
        before do
          post :create, :account => Factory.attributes_for(:account), :user => Factory.attributes_for(:user)
        end
      
        it { should set_the_flash.to("Welcome to Hot Ink!") }
        it { should respond_with(:redirect) }
        it "should create root account" do
          should assign_to(:account).with_kind_of(Account)
          assigns(:account).should_not be_new_record
        end
        it "should create the admin user" do
          should assign_to(:user).with_kind_of(User)
          assigns(:user).should_not be_new_record
          assigns(:user).should have_role('admin')
          assigns(:user).should have_role('staff', @account)
          assigns(:user).should have_role('manager', @account)
        end
      end
      
      context "with invalid user parameters" do
        before do
          post :create, :account => Factory.attributes_for(:account), :user => Factory.attributes_for(:user, :email => "")
        end
      
        it { should respond_with_content_type(:html) }
        it { should render_with_layout('login') }
        it { should render_template('accounts/first_account_form') }
        it "should not create an account or a user" do
          assigns(:user).should be_new_record
          assigns(:account).should be_new_record
        end
      end
      
      context "with invalid account parameters" do
        before do
          post :create, :account => Factory.attributes_for(:account, :name => ""), :user => Factory.attributes_for(:user)
        end
      
        it { should respond_with_content_type(:html) }
        it { should render_with_layout('login') }
        it { should render_template('accounts/first_account_form') }
        it "should not create an account or a user" do
          assigns(:user).should be_new_record
          assigns(:account).should be_new_record
        end
      end
    end
  end
  
  
  describe "GET to index" do
    before do
      controller.stub!(:login_required).and_return(true)
      @account = Factory(:account)
      @user = Factory(:user)
      controller.stub!(:current_user).and_return(@user)
      
      @user.has_role("manager", @account)
      
      get :index
    end
    
    it { should respond_with(:redirect) }
  end
  
  describe "GET to show" do
    before do
      controller.stub!(:login_required).and_return(true)
      @account = Factory(:account)
      get :show, :id => @account.id
    end
    
    it { should respond_with(:redirect) }
  end
  
  describe "GET to edit" do
    before do
      controller.stub!(:login_required).and_return(true)
      @account = Factory(:account)
    end
    
    context "as account manager" do
      before do
        @user = Factory(:user)
        @user.has_role("manager", @account)
        controller.stub!(:current_user).and_return(@user)
        
        @user_invitations = (1..3).collect{ Factory(:user_invitation, :account => @account) }
        get :edit, :id => @account.id
      end

      it { should assign_to(:account).with(@account) }
      it { should_not assign_to(:accounts) }
      it { should respond_with(:success) }
      it { should respond_with_content_type(:html) }
    end
    
    context "as admin" do
      before do
        controller.stub!(:login_required).and_return(true)
        @user = Factory(:user)
        @user.has_role("admin")
        controller.stub!(:current_user).and_return(@user)
        3.times { Factory(:account) }
        
        get :edit, :id => @account.id
      end
      
      it { should assign_to(:accounts).with(Account.all) }
    end
    
    context "as unauthorized user" do
      before do
        get :edit, :id => @account.id
      end

      it { should respond_with(:redirect) }
    end
  end
  
  describe "PUT to update" do    
    before do
      controller.stub!(:login_required).and_return(true)
      @account = Factory(:account)
    end
    
    context "as account manager" do
      before do
        @user = Factory(:user)
        @user.has_role("manager", @account)
        controller.stub!(:current_user).and_return(@user)
      end
      
      context "with valid parameters" do
        before do
          put :update, :id => @account.id, :account => { :time_zone => "Pacific Time (US & Canada)" }
        end
      
        it { should set_the_flash.to("Account updated") }
        it { should assign_to(:account).with(@account) }
        it { should respond_with(:success) }
      end
    end
  end
  
end
