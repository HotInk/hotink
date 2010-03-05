require 'spec_helper'

describe PasswordResetsController do
  
  describe "GET to new" do
    before do
      get :new
    end
    
    it { should respond_with(:success) }
    it { should respond_with_content_type(:html) }
  end
  
  describe "POST to create" do
   context "with valid user email" do
      before do
        @user = Factory(:user)
        post :create, :email => @user.email
      end
    
      it { should assign_to(:user).with(@user) }
      it { should respond_with(:success) }
      it { should respond_with_content_type(:html) }
      it { should render_template('success') }
    end
    
    context "with invalid user email" do
      before do
        post :create, :email => "someguy@send-me-access.com"
      end
    
      it { should_not assign_to(:user) }
      it { should respond_with(:not_found) }
      it { should respond_with_content_type(:html) }
      it { should render_template('new') }
    end
  end
  
  describe "GET to edit" do
    before do
      @user = Factory(:user)
      @user.reset_perishable_token!
      get :edit, :id => @user.perishable_token
    end
    
    it { should respond_with(:success) }
    it { should respond_with_content_type(:html) }
  end
  
  describe "PUT to update" do
    before do
      @user = Factory(:user)
      @user.reset_perishable_token!
    end
    
    context "with matching password and confirmation" do
      before do
        put :update, :id => @user.perishable_token, :user => { :password => "heyooooooooo", :password_confirmation => "heyooooooooo" }
      end
    
      it { should assign_to(:user).with(@user) }
      it { should set_the_flash.to("Password successfully updated") }
      it { should respond_with(:redirect) }
    end
    
    context "with mismatched password and confirmation" do
      before do
        put :update, :id => @user.perishable_token, :user => { :password => "heyooooooooo", :password_confirmation => "what an awful password. how will you remember how many o's there are?" }
      end
    
      it { should assign_to(:user).with(@user) }
      it { should respond_with(:bad_request) }
      it { should respond_with_content_type(:html) }
      it { should render_template('edit') }
    end
  end
  
end
