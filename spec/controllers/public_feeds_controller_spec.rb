require 'spec_helper'

describe PublicFeedsController do
  before do
    @account = Factory(:account)
    Account.stub!(:find).and_return(@account)
  end
  
  describe "GET to show" do
    before do
      @scheduled_articles = (1..2).collect{ Factory(:scheduled_article, :account => @account )}
      @published_articles = (1..2).collect{ |n | Factory(:published_article, :account => @account, :published_at => 5.days.ago + n.hours )}
      @unpublished_articles = (1..2).collect{ Factory(:article, :account => @account )}
    
      get :show
    end
   
    it { should respond_with(:success) }
    it { should assign_to(:articles).with(@published_articles.reverse) }  
    it { should respond_with_content_type(:xml) }    
  end

end
