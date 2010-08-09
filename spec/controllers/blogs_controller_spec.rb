require 'spec_helper'

describe BlogsController do
  before do
    @account = Factory(:account)
    controller.stub!(:current_subdomain).and_return(@account.name)
 
    @current_user = Factory(:user)
    @current_user.has_role("staff", @account)
    controller.stub!(:current_user).and_return(@current_user)  
  end
  
  describe "GET to index" do
    before do
      @active_blogs = (1..3).collect{ Factory(:blog, :account => @account, :status => true) }
      @inactive_blogs = (1..3).collect{ Factory(:blog, :account => @account, :status => false) }  
      
      get :index
    end
    
    it { should assign_to(:active_blogs).with(@active_blogs) }
    it { should assign_to(:inactive_blogs).with(@inactive_blogs) }    
    it { should respond_with(:success) }
    it { should respond_with_content_type(:html) }
  end
  
  describe "GET to new" do
    before do
      @current_user.has_role("manager", @account)
      get :new
    end
    
    it { should assign_to(:blog).with_kind_of(Blog) }
    it { should respond_with(:success) }
    it { should respond_with_content_type(:html) }
  end
  
  describe "POST to create" do
    before do
      @current_user.has_role("manager", @account)
    end
    
    context "with valid blog attributes" do
      before do
        post :create, :blog => Factory.attributes_for(:blog)
      end
    
      it { should assign_to(:blog).with_kind_of(Blog) }
      it "should make the current user both editor and contributor" do
        @current_user.should have_role('contributor', assigns(:blog))
        @current_user.should have_role('editor', assigns(:blog))
      end
      it { should respond_with(:redirect) }
    end
    
    context "with invalid blog attributes" do
      before do
        post :create, :blog => Factory.attributes_for(:blog, :title => "")
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
        @published = (1..3).collect{ |n| Factory(:detailed_entry, :account => @account, :published_at => (Time.now - 1.day - n.minutes), :blog => @blog) }
        @drafts = (1..3).collect{ |n| Factory(:draft_entry, :updated_at => n.days.ago, :blog => @blog) }
        @scheduled = (1..3).collect{ |n| Factory(:scheduled_entry, :published_at => (Time.now + 1.day - n.minutes), :account => @account, :blog => @blog) }
        get :show, :id => @blog.id
      end
    
      it { should assign_to(:blog).with(@blog) }
      it "should assign the appropriate entries" do
        should assign_to(:entries).with_kind_of(WillPaginate::Collection)
        should assign_to(:entries).with(@drafts + @scheduled + @published)
      end    
      it { should respond_with(:success) }
    end    
    
    context "searching for specific entries" do
      before do
        @searched_entries = (1..3).collect{ Factory(:detailed_entry, :account => @account, :blog => @blog) }
        @other_entries = (1..3).collect{ Factory(:detailed_entry, :account => @account, :blog => @blog) }
        Entry.should_receive(:search).with( "test query", :with=>{ :account_id => @account.id, :blog_id => @blog.id }, :page => 1, :per_page => 20, :order => "published_at desc", :include => [:authors, :mediafiles]).and_return(@searched_entries)
        get :show, :id => @blog.id, :search => "test query"
      end
      
      it { should assign_to(:entries).with(@searched_entries) }
      it { should respond_with(:success) }
    end
  end
  
  describe "GET to edit" do
    before do
      @blog = Factory(:blog, :account => @account)
      post :edit, :id => @blog.id
    end
    
    it { should assign_to(:blog).with(@blog) }
    it { should respond_with(:success) }
  end
  
  describe "PUT to update" do
    context "with valid HTML request" do
      before do
        @blog = Factory(:blog, :account => @account)
        put :update, :id => @blog.id, :blog => { :title => "Some blog this is" }
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
         put :update, :id => @blog.id, :blog => { :title => "" }
       end

       it { should assign_to(:blog).with(@blog) }
       it { should respond_with(:bad_request) }
       it { should render_template(:edit) }
    end
  end
  
  describe "blog contributors" do
    before do
      @blog = Factory(:blog, :account => @account)
      @current_user.has_role("editor", @blog)
    end
    
    describe "GET to manage_contributors" do
      before do
        get :manage_contributors, :id => @blog.id
      end
    
      it { should respond_with(:success) }
      it { should assign_to(:blog).with(@blog) }
      it { should respond_with_content_type(:html) }
    end

    describe "PUT to add_contributor" do
      before do
        @user = Factory(:user)
        put :add_contributor, :id => @blog.id, :user => @user.id
      end
    
      it "should make the current user a contributor" do
        @blog.contributors.should include(@user)
      end
      it { should respond_with(:redirect) }
    end
  
    describe "PUT to remove_contributor" do
      before do
        @user = Factory(:user)
        @blog.make_editor(@user)
      
        put :remove_contributor, :id => @blog.id, :user => @user.id
      end
    
      it "should remove the user from the blog" do
        @blog.contributors.should_not include(@user)
      end
      it { should respond_with(:redirect) }
    end
  
    describe "PUT to promote_contributor" do
      before do
        @user = Factory(:user)
        @blog.contributors << @user
      
        put :promote_contributor, :id => @blog.id, :user => @user.id
      end
    
      it "should make the user an editor of the blog" do
        @blog.editors.should include(@user)
      end
      it { should respond_with(:redirect) }
    end
  
    describe "PUT to demote_contributor" do
      before do
        @user = Factory(:user)
        @blog.make_editor(@user)
      
        put :demote_contributor, :id => @blog.id, :user => @user.id
      end
    
      it "should make editor of the blog into a contributor" do
        @blog.editors.should_not include(@user)
        @blog.contributors.should include(@user)
      end
      it { should respond_with(:redirect) }
    end
  end
end
