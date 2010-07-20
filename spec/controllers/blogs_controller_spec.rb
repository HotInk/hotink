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
    it { should assign_to(:inactive_blogs).with(@inactive_blogs) }    
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
    end

    context "no search query specified" do
      before do
        @published = (1..3).collect{ Factory(:detailed_entry, :blog => @blog) }
        @drafts = (1..3).collect{ Factory(:draft_entry, :account => @account, :blog => @blog) }
        @scheduled = (1..3).collect{ |n| Factory(:scheduled_entry, :published_at => (Time.now + n.minutes), :account => @account, :blog => @blog) }
        get :show, :account_id => @account.id, :id => @blog.id
      end
    
      it { should assign_to(:blog).with(@blog) }
      it "should assign the appropriate entries" do
        should assign_to(:entries).with_kind_of(WillPaginate::Collection)
        assigns(:entries).to_a.should == @published
        assigns(:drafts).to_a.should == @drafts
        assigns(:scheduled).to_a.should == @scheduled
      end    
      it { should respond_with(:success) }
    end    
    
    context "searching for specific entries" do
      before do
        @searched_entries = (1..3).collect{ Factory(:detailed_entry, :account => @account, :blog => @blog) }
        @other_entries = (1..3).collect{ Factory(:detailed_entry, :account => @account, :blog => @blog) }
        Entry.should_receive(:search).with( "test query", :with=>{ :account_id => @account.id, :blog_id => @blog.id }, :page => 1, :per_page => 20, :include => [:authors, :mediafiles]).and_return(@searched_entries)
        get :show, :account_id => @account.id, :id => @blog.id, :search => "test query"
      end
      
      it { should assign_to(:entries).with(@searched_entries) }
      it { should respond_with(:success) }
    end
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
  
  describe "GET to manage_contributors" do
    before do
      @blog = Factory(:blog, :account => @account)
      get :manage_contributors, :account_id => @account.id, :id => @blog.id
    end
    
    it { should respond_with(:success) }
    it { should assign_to(:blog).with(@blog) }
    it { should respond_with_content_type(:html) }
  end

  describe "PUT to add_contributor" do
    before do
      @blog = Factory(:blog, :account => @account)
      @user = Factory(:user)
      xhr :put, :add_contributor, :account_id => @account.id, :id => @blog.id, :user => @user.id
    end
    
    it "should make the current user a contributor" do
      @blog.contributors.should include(@user)
    end
    it { should respond_with(:redirect) }
  end
  
  describe "PUT to remove_contributor" do
    before do
      @blog = Factory(:blog, :account => @account)
      @user = Factory(:user)
      @blog.make_editor(@user)
      
      xhr :put, :remove_contributor, :account_id => @account.id, :id => @blog.id, :user => @user.id
    end
    
    it "should remove the user from the blog" do
      @blog.contributors.should_not include(@user)
    end
    it { should respond_with(:redirect) }
  end
  
  describe "PUT to promote_contributor" do
    before do
      @blog = Factory(:blog, :account => @account)
      @user = Factory(:user)
      @blog.contributors << @user
      
      xhr :put, :promote_contributor, :account_id => @account.id, :id => @blog.id, :user => @user.id
    end
    
    it "should make the user an editor of the blog" do
      @blog.editors.should include(@user)
    end
    it { should respond_with(:redirect) }
  end
  
  describe "PUT to demote_contributor" do
    before do
      @blog = Factory(:blog, :account => @account)
      @user = Factory(:user)
      @blog.make_editor(@user)
      
      xhr :put, :demote_contributor, :account_id => @account.id, :id => @blog.id, :user => @user.id
    end
    
    it "should make editor of the blog into a contributor" do
      @blog.editors.should_not include(@user)
      @blog.contributors.should include(@user)
    end
    it { should respond_with(:redirect) }
  end
end
