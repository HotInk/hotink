require 'spec_helper'

describe NetworksController do
  before do
    @account = Factory(:account)
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
    it { should assign_to(:memberships).with(@memberships) }
    it "should load articles from all member accounts accounts" do
      @member_articles.each{ |article| assigns(:articles).should include(article) }
      @nonmember_articles.each{ |article| assigns(:articles).should_not include(article) }
    end
  end
  
end