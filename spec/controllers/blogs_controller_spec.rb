require 'spec_helper'

describe BlogsController do
  before do
    @account = Factory(:account)
    controller.stub!(:login_required).and_return(true)
  end
  
  describe "GET to index" do
    before do
      @active_blogs = (1..3).collect{ Factory(:blog, :account => @account, :status => true) }
      @inactive_blogs = (1..3).collect{ Factory(:blog, :account => @account, :status => false) }  
      
      get :index, :account_id => @account.id
    end
    
    it { should assign_to(:active_blogs).with(@active_blogs) }
    it { should assign_to(:active_blogs).with(@active_blogs) }    
    it { should respond_with(:success) }
    it { should respond_with_content_type(:html) }
  end
  
  describe "GET to new" do
    before do
      get :new, :account_id => @account.id
    end
    
    it { should assign_to(:blog).with_kind_of(Blog) }
    it { should respond_with(:success) }
    it { should respond_with_content_type(:html) }
  end
  
  describe "POST to create" do
    before do
      @user = Factory(:user)
      controller.stub!(:current_user).and_return(@user)
    end
    
    context "with valid blog attributes" do
      before do
        post :create, :account_id => @account.id, :blog => Factory.attributes_for(:blog)
      end
    
      it { should assign_to(:blog).with_kind_of(Blog) }
      it "should make the current user both editor and contributor" do
        @user.should have_role('contributor', assigns(:blog))
        @user.should have_role('editor', assigns(:blog))
      end
      it { should respond_with(:redirect) }
    end
    
    context "with invalid blog attributes" do
      before do
        post :create, :account_id => @account.id, :blog => Factory.attributes_for(:blog, :title => "")
      end
    
      it { should assign_to(:blog).with_kind_of(Blog) }
      it { should respond_with(:bad_request) }
      it { should respond_with_content_type(:html) }
    end
  end
  
  describe "GET to show" do
    before do
      @blog = Factory(:blog, :account => @account)
      @entries = (1..3).collect{ Factory(:detailed_entry, :blogs=>[@blog]) }
      get :show, :account_id => @account.id, :id => @blog.id
    end
    
    it { should assign_to(:blog).with(@blog) }
    it "should assign the appropriate entries" do
      should assign_to(:entries).with_kind_of(WillPaginate::Collection)
      assigns(:entries).to_a.should == @entries
    end    
    it { should respond_with(:success) }
  end
  
  describe "GET to edit" do
    before do
      @blog = Factory(:blog, :account => @account)
      post :edit, :account_id => @account.id, :id => @blog.id
    end
    
    it { should assign_to(:blog).with(@blog) }
    it { should respond_with(:success) }
  end
  
  describe "PUT to update" do
    context "with valid HTML request" do
      before do
        @blog = Factory(:blog, :account => @account)
        put :update, :account_id => @account.id, :id => @blog.id, :blog => { :title => "Some blog this is" }
      end
      
      it { should assign_to(:blog).with(@blog) }
      it { should respond_with(:redirect) }
      it "should update the blog" do
        @blog.reload.title.should == "Some blog this is"
      end
    end
    
    context "with invalid request" do
      before do
         @blog = Factory(:blog, :account => @account)
         put :update, :account_id => @account.id, :id => @blog.id, :blog => { :title => "" }
       end

       it { should assign_to(:blog).with(@blog) }
       it { should respond_with(:bad_request) }
       it { should render_template(:edit) }
    end
  end
  
  describe "PUT to add_user" do
    before do
      @blog = Factory(:blog, :account => @account)
      @user = Factory(:user)
      @user.has_role('staff', @account)
      xhr :put, :add_user, :account_id => @account.id, :id => @blog.id, :user => @user.id
    end
    
    it "should make the current user both editor and contributor" do
      @user.should have_role('contributor', assigns(:blog))
    end
    it { should respond_with_content_type(:js) }
  end
  
  
  describe "PUT to remove_user" do
    before do
      @blog = Factory(:blog, :account => @account)
      @user = Factory(:user)
      @user.has_role('staff', @account)
      @user.has_role('contributor', @blog)
      @user.has_role('editor', @blog)
      
      xhr :put, :remove_user, :account_id => @account.id, :id => @blog.id, :user => @user.id
    end
    
    it "should remove the user from the blog" do
      @user.should_not have_role('contributor', assigns(:blog))
      @user.should_not have_role('editor', assigns(:blog))
    end
    it { should respond_with_content_type(:js) }
  end
  
  describe "PUT to promote_user" do
    before do
      @blog = Factory(:blog, :account => @account)
      @user = Factory(:user)
      @user.has_role('staff', @account)
      @user.has_role('contributor', @blog)
      
      xhr :put, :promote_user, :account_id => @account.id, :id => @blog.id, :user => @user.id
    end
    
    it "should make the user an editor of the blog" do
      @user.should have_role('editor', assigns(:blog))
    end
    it { should respond_with_content_type(:js) }
  end
end
