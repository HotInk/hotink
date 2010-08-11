require 'spec_helper'

describe PagesController do
  before do
    @account = Factory(:account)
    controller.stub!(:current_subdomain).and_return(@account.name)
    
    @current_user = Factory(:user)
    @current_user.has_role('staff', @account)    
    @current_user.has_role('manager', @account)
    controller.stub!(:current_user).and_return(@current_user)
  end
  
  describe "GET to index" do
    before do
      @pages = (1..3).collect{ Factory(:page, :account => @account) }
      child_pages = (1..3).collect{ Factory(:page, :parent => @pages.first, :account => @account) }
      get :index
    end
    
    it { should respond_with(:success) }
    it { should assign_to(:pages).with(@pages) }
  end
  
  describe "GET to new" do
    describe "for a new main page" do
      before do
        get :new
      end
      
      it { should respond_with(:success) }
      it "should initialize a new main page" do
        should assign_to(:page).with_kind_of(Page)
        assigns(:page).parent.should be_blank
      end
    end
  
    describe "for a new child page" do
      before do
        @parent = Factory(:page, :account => @account)
        get :new, :parent_id => @parent.id
      end
      
      it { should respond_with(:success) }
      it "should initialize a new main page" do
        should assign_to(:page).with_kind_of(Page)
        assigns(:page).parent.should eql(@parent)
      end
    end
  end

  describe "POST to create" do
    before do
     post :create, :page => Factory.attributes_for(:page)
    end
    
    it { should respond_with(:redirect) }
    it "should create a page" do
      should assign_to(:page).with_kind_of(Page)
      assigns(:page).should_not be_new_record
    end
  end
  
  describe "GET to edit" do
    before do
      @page = Factory(:page, :account => @account)
      get :edit, :id => @page.id
    end
    it { should respond_with(:success) }
    it { should assign_to(:page).with(@page) }
  end
  
  describe "PUT to update" do
    context "with valid attributes" do
      before do
        @page = Factory(:page, :account => @account)
        @new_parent = Factory(:page, :account => @account)
        put :update, :id => @page.id, :page => { :name => "new-page-name", :parent_id => @new_parent.id }
      end
    
      it { should respond_with(:redirect) }
      it "should update the page" do
        should assign_to(:page).with(@page)
        assigns(:page).name.should eql("new-page-name")
        assigns(:page).parent.should eql(@new_parent)
      end
    end
    
    context "with invalid attributes" do
      before do
        @page = Factory(:page, :account => @account)
        @new_parent = Factory(:page, :account => @account)
        put :update, :id => @page.id, :page => { :name => "bad page name", :parent_id => @new_parent.id }
      end
    
      it { should respond_with(:success) }
      it "should not update the page" do
        should assign_to(:page).with(@page)
        assigns(:page).reload.name.should_not eql("new-page-name")
        assigns(:page).reload.parent.should_not eql(@new_parent)
      end
    end
  end
  
  describe "DELETE to destroy" do
    before do 
      @page = Factory(:page, :account => @account)
      delete :destroy, :id => @page.id
    end
      
    it { should respond_with(:redirect) }
    it "should delete the page" do
      lambda{ Page.find(@page.id)}.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
