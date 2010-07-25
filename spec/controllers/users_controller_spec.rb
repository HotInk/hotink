require 'spec_helper'

describe UsersController do
  before do
    @account = Factory(:account)
    controller.stub!(:current_subdomain).and_return(@account.name)
    
    @user = Factory(:user)
    @user.has_role "staff", @account
    controller.stub!(:current_user).and_return(@user)
  end
  
  describe "GET to edit" do
    before do
      get :edit, :id => @user.id
    end
    
    it { should assign_to(:user).with(@user) }
    it { should respond_with_content_type(:html) }
  end
  
  describe "PUT to update" do
   context "with XHR request" do
     
      context "with valid user attributes" do
        before do
          xhr :put, :update, :id => @user.id, :user => { :email => "this-isa-new@add-ress.com" }
        end
  
        it { should respond_with(:ok) }
        it "should update user" do
          should assign_to(:user)
          assigns(:user).email.should == "this-isa-new@add-ress.com"
        end
      end
      
      context "with invalid user attributes" do
        before do
          xhr :put, :update, :id => @user.id, :user => { :email => "" }
        end
      
        it { should assign_to(:user)} 
        it { should render_template('edit') }
      end
      
      context "with HTML request" do
        before do
          @account = Factory(:account)
          @user.has_role('staff', @account)
          put :update, :id => @user.id, :user => { :email => "this-isa-new@add-ress.com" }
        end

        it { should set_the_flash.to("User updated.") }
        it { should respond_with(:redirect) }
        it "should update user" do
          should assign_to(:user)
          assigns(:user).email.should == "this-isa-new@add-ress.com"
        end
      end
      
    end
  end
  
  describe "PUT to promote with XHR request" do
    before do
      @promoted_user = Factory(:user)
      @promoted_user.has_role('staff', @account)
      
      @user.has_role('staff', @account)
      @user.has_role('manager', @account)
      xhr :put, :promote, :id => @promoted_user.id
    end
    
    it { should respond_with(:success) }
    it { should assign_to(:account).with(@account) }
    it "should promote user" do
      should assign_to(:user).with(@promoted_user)
      assigns(:user).reload.should have_role('editor', @account)
    end
  end 
  
  describe "PUT to demote with XHR request" do
    before do
      @user.has_role('admin')
      @demoted_user = Factory(:user)

      @demoted_user.has_role('staff', @account)
      @demoted_user.has_role('manager', @account)

      xhr :put, :demote, :id => @demoted_user.id
    end
    
    it "should demote user" do
      should assign_to(:user).with(@demoted_user)
      assigns(:user).should have_role('editor', @account)
      assigns(:user).should_not have_role('manager', @account)
    end
  end
  
  describe "DELETE to letgo with XHR request" do
    before do
      @user.has_role('admin')
      @fired_user = Factory(:user)
      @fired_user.has_role('staff', @account)

      xhr :put, :letgo, :id => @fired_user.id
    end
    
    it "should remove user from account" do
      should assign_to(:user).with(@fired_user)
      assigns(:user).should_not have_role('staff', @account)
    end
  end
  
  describe "PUT to deputize with XHR request" do
    before do
      @user.has_role('admin')
      @deputized_user = Factory(:user)
      @account = Factory(:account)

      xhr :put, :deputize, :id => @deputized_user.id
    end
    
    it "should remove user from account" do
      should assign_to(:user).with(@deputized_user)
      assigns(:user).should have_role('admin')
    end
  end
end
