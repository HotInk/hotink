require 'spec_helper'

describe NetworksController do
  before do
    @account = Factory(:account)
    controller.stub!(:current_subdomain).and_return(@account.name)
    
    @current_user = Factory(:user)
    @current_user.promote_to_admin
    controller.stub!(:current_user).and_return(@current_user)
  end
  
  describe "GET to show" do
    before do
      @memberships = (1..3).collect{ Factory(:membership, :network_owner => @account) }
      @member_articles = @memberships.collect { |membership| Factory(:published_article, :account => membership.account) }
      @nonmember_articles = (1..2).collect{ Factory(:published_article) }
      get :show, :account_id => @account.id
    end
    
    it { should respond_with(:success) }
    it { should render_with_layout(:hotink) }
    it { should assign_to(:memberships).with(@memberships) }
    it "should load articles from all member accounts accounts" do
      @member_articles.each{ |article| assigns(:articles).should include(article) }
      @nonmember_articles.each{ |article| assigns(:articles).should_not include(article) }
    end
  end
  

  describe "GET to search" do
    before do
      @memberships = (1..3).collect{ Factory(:membership, :network_owner => @account) }
      @articles = @memberships.collect { |membership| Factory(:published_article, :account => membership.account) }
    end
    
    context "with a query" do
      before do
        @searched_articles = @memberships.collect { |membership| Factory(:published_article, :title => "Experimental testing", :account => membership.account) }
        Article.should_receive(:search).and_return(@searched_articles)
        get :search, :q => "Experimental testing"
      end
    
       it { should respond_with(:success) }
       it { should respond_with_content_type(:html) }
       it { should render_template(:search) }
       it { should render_with_layout(:hotink) }
       it { should assign_to(:search_query).with("Experimental testing") }
       it { should assign_to(:articles).with(@searched_articles) }
    end
    
    context "with no query" do
      before do
        get :search
      end
      
      it { should respond_with(:success) }
      it { should render_template(:search) }
      it { should assign_to(:articles).with([]) }
    end
  end
  
  describe "GET to show_article" do
    context "with a network article" do
      before do
        @membership = Factory(:membership, :network_owner => @account)
        @article = Factory(:published_article, :account => @membership.account)
        get :show_article, :id => @article.id
      end
    
      it { should respond_with(:success) }
      it { should assign_to(:article).with(@article) }
    end
  end
  
  describe "POST to checkout_article" do
    before do
      @membership = Factory(:membership, :network_owner => @account)
      @article = Factory(:published_article, :account => @membership.account)
      post :checkout_article, :id => @article.id
    end
    
    it { should respond_with(:redirect) }
    it { should set_the_flash }
    it "should make network copy" do
      @account.should have_network_copy_of(@article)
    end
  end
  
  describe "GET to show_members" do
    before do
      @accounts = (1..2).collect{ Factory(:account) }
      get :show_members
    end
    
    it { should respond_with(:success) }
    it { should assign_to(:accounts).with(@accounts) }
  end
  
  describe "POST to update_members" do
    before do
      @accounts = (1..3).collect{ Factory(:account) }
      post :update_members, :member_ids => @accounts[0..1].collect{|a| a.id }
    end
    
    it { should respond_with(:redirect) }
    it "should make accounts into network members" do
      @accounts[0..1].each do |member_account|
        @account.network_members.should include(member_account)
      end
    end
  end
end