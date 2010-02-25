require 'spec_helper'

describe ArticlesController do
  before do
    @account = Factory(:account)
    controller.stub!(:login_required).and_return(true)
  end
  
  describe "GET to index" do
    context "with no articles" do
      before do
        get :index, :account_id => @account.id
      end
      
      it { should respond_with(:success) }
      it { should respond_with_content_type(:html) }
      it { should render_with_layout(:hotink) }
      it { should assign_to(:articles).with([]) }
    end
    
    context "with draft, scheduled and published articles" do
      before do
        @drafts = (1..3).collect{ Factory(:draft_article, :account => @account) }
        @scheduled = (1..3).collect{ Factory(:scheduled_article, :account => @account) }
        @published = (1..3).collect{ Factory(:detailed_article, :account => @account) }
        
        get :index, :account_id => @account.id
      end
      
      it { should respond_with(:success) }
      
      it { should assign_to(:drafts).with(@drafts) }
      it { should assign_to(:scheduled).with(@scheduled) }
      it { should assign_to(:articles).with(@published) }
    end
    
    context "searching for specific articles" do
      before do
        @searched_articles = (1..3).collect{ Factory(:detailed_article, :account => @account) }
        @other_articles = (1..3).collect{ Factory(:detailed_article, :account => @account) }
        Article.should_receive(:search).with( "test query", :with=>{ :account_id => @account.id }, :page => 1, :per_page => 20, :include => [:authors, :mediafiles, :section]).and_return(@articles)
        get :index, :account_id => @account.id, :search => "test query"
      end
      
      it { should respond_with(:success) }
    end
  end

  describe "GET to show" do
    before do
      @article = Factory(:article, :account => @account)
      get :show, :account_id => @account.id, :id => @article.id
    end
    
    it { should respond_with(:success) }
    it { should assign_to(:article).with(@article) }
  end
  
  describe "GET to edit" do
    before do
      @article = Factory(:article, :account => @account)
    end
    
    context "by article's owner" do
      before do
        @user = Factory(:user)
        @article.owner = @user
        controller.stub!(:current_user).and_return(@user)
        get :edit, :account_id => @account.id, :id => @article.id
      end
      
      it { should respond_with(:success) }
    end
    
    context "by administrator" do
      before do
        @user = Factory(:user)
        @user.has_role("admin")
        controller.stub!(:current_user).and_return(@user)
        get :edit, :account_id => @account.id, :id => @article.id
      end
      
      it { should respond_with(:success) }
    end
    
    context "by account manager" do
      before do
        @user = Factory(:user)
        @user.has_role("manager", @account)
        controller.stub!(:current_user).and_return(@user)
        get :edit, :account_id => @account.id, :id => @article.id
      end
      
      it { should respond_with(:success) }
    end
    
    context "by user prohibited from editing article" do
      before do
        get :edit, :account_id => @account.id, :id => @article.id
      end
      
      it { should respond_with(:redirect) }
    end
  end

  describe "GET to new" do
    before do
      @user = Factory(:user)
      controller.stub!(:current_user).and_return(@user)
      
      get :new, :account_id => @account.id
    end
    
    it { should assign_to(:article).with_kind_of(Article) }
    it { should respond_with(:redirect) }
  end
  
  describe "POST to update" do
    before do
      @article = Factory(:article, :account => @account)
    end
    
    context "by user prohibited from updating article" do
      before do
        post :update, :account_id => @account.id, :id => @article.id, :article => { :title => "Whoa there. Title time." }
      end
      
      it { should assign_to(:article).with(@article) }
      it { should respond_with(:redirect) }
    end
  end

  describe "DELETE to destory" do
    before do
      @article = Factory(:article, :account => @account)
    end
    
    context "by account manager" do
      before do
        @user = Factory(:user)
        @user.has_role("manager", @account)
        controller.stub!(:current_user).and_return(@user)
        delete :destroy, :account_id => @account.id, :id => @article.id
      end
      
      it { should respond_with(:redirect) }
      it "should delete the article" do
        lambda { Article.find(@article.id) }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
    
    context "by user prohibited from deleting article" do
      before do
        delete :destroy, :account_id => @account.id, :id => @article.id
      end
      
      it { should respond_with(:redirect) }
      it "should not delete the article" do
        Article.find(@article.id).should == @article
      end
    end
  end
end
