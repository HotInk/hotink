require 'spec_helper'

describe ListsController do
  before do
    @account = Factory(:account)
    controller.stub!(:current_subdomain).and_return(@account.name)
    
    @current_user = Factory(:user)
    @current_user.promote_to_admin
    controller.stub!(:current_user).and_return(@current_user)
  end
  
  describe "GET to index" do
    before do
      @lists = (1..3).collect{ Factory(:list, :account => @account) }
      get :index
    end
    
    it { should assign_to(:lists).with(@list) }
    it { should respond_with(:success) }
    it { should render_with_layout(:hotink) }
    it { should respond_with_content_type(:html) }
  end
   
  describe "GET to new" do
    before do
      @articles = (1..3).collect{ Factory(:published_article, :account => @account) }
      
      get :new
    end
    it { should assign_to(:list).with_kind_of(List) }
    it { should assign_to(:articles).with(@articles) }
    it { should respond_with(:success) }
    it { should respond_with_content_type(:html) }
  end
  
  describe "POST to create" do
    context "with valid attributes" do
      before do
        post :create,  :list => { :name => "My list" }
      end
    
      it { should respond_with(:redirect) }
      it { should assign_to(:list).with_kind_of(List) }
      it "should create list" do
        assigns(:list).should_not be_new_record
        assigns(:list).name.should eql("My list")
      end
    end
    
    context "with invalid attributes" do
      before do
        @articles = (1..3).collect{ Factory(:published_article, :account => @account) }
        post :create,  :list => { :name => "Chris's list" }
      end
      
      it { should respond_with(:success) }
      it { should render_template(:new) }
      it { should assign_to(:articles).with(@articles) }
      it { should assign_to(:list).with_kind_of(List) }
      it "should not create list" do
        assigns(:list).should be_new_record
      end
    end
  end
  
  describe "GET to edit" do
     before do
       @articles = (1..3).collect{ Factory(:published_article, :account => @account) }
       @list = Factory(:list, :account => @account)
     end

     context "by list's owner" do
       before do
         @list.owner = @current_user
         get :edit, :id => @list.id
       end

       it { should assign_to(:articles).with(@articles) }
       it { should respond_with(:success) }
       it { should assign_to(:list).with(@list) }
     end

     context "by administrator" do
       before do
         @current_user.promote_to_admin
         get :edit, :id => @list.id
       end

       it { should assign_to(:list).with(@list) }
     end

     context "by user prohibited from editing article" do
       before do
         @current_user.has_no_role "admin"
         get :edit, :id => @list.id
       end

       it { should respond_with(:unauthorized) }
     end
  end
  
  describe "PUT to update" do
    before do
      @list = Factory(:list, :owner => @current_user, :account => @account)
    end
    
    context "with valid attributes" do
      before do
        put :update, :id => @list.id, :list => { :name => "Testing update" }
      end
    
      it { should respond_with(:redirect) }
      it { should assign_to(:list).with(@list) }
      it "should update list" do
        @list.reload.name.should == "Testing update"
      end
    end
    
    context "with invalid attributes" do
      before do
        @articles = (1..3).collect{ Factory(:published_article, :account => @account) }
        put :update, :id => @list.id, :list => { :name => nil }
      end
    
      it { should assign_to(:articles).with(@articles) }
      it { should render_template(:edit) }
      it { should respond_with(:success) }
      it { should assign_to(:list).with(@list) }
      it { should render_template(:edit)}
    end
    
    describe "with no document ids, empties list" do
      before do
        @list.documents = (1..3).collect { Factory(:document, :account => @account) }
        put :update, :id => @list.id, :list => { :name => "Testing update" }
      end
      
      it "should empty list" do
        @list.documents.reload.should be_blank
      end
    end
  end
  
  describe "DELETE to destroy" do
    before do
      @list = Factory(:list, :account => @account)
      @current_user.promote_to_admin
      delete :destroy, :id => @list.id
    end
    
    it { should respond_with(:redirect) }
    it "should destroy the list" do
      lambda { List.find(@list.id)}.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
