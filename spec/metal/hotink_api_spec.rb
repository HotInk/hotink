require 'spec_helper'

describe HotinkApi do
  include Rack::Test::Methods
  
  def app
    HotinkApi
  end
  
  describe "Articles API" do
      
    describe "GET to /accounts/:account_id/articles/:id.xml" do
      before do
        @article = Factory(:detailed_article)
        get "/accounts/#{@article.account.id}/articles/#{@article.to_param}.xml"
      end
      
      it "should return an XML representation of the article" do
        last_response.should be_ok
        last_response.headers['Content-Type'].should == "text/xml"
        last_response.body.should == @article.to_xml
      end
    end
    
    describe "GET to /accounts/:account_id/articles.xml" do
      before do
        @account = Factory(:account)
        @recently_published_articles = (1..2).collect{ |n| Factory(:detailed_article, :published_at => n.hours.ago, :account => @account) }
        @just_published_article = Factory(:detailed_article, :account => @account)
      end
      
      it "should return an XML array of only published articles" do
        draft = Factory(:draft_article, :account => @account)
        scheduled = Factory(:scheduled_article, :account => @account)
        get "/accounts/#{@account.id}/articles.xml"
        
        last_response.should be_ok
        last_response.headers['Content-Type'].should == "text/xml"
        last_response.body.should == @account.articles.published.by_date_published(:desc).paginate(:page => 1, :per_page => 20).to_xml
      end
      
      it "should paginate returned articles" do
        page = 2
        per_page = 5
        @paginated_articles = (1..10).collect{ Factory(:detailed_article, :account => @account) }
        get "/accounts/#{@account.id}/articles.xml?page=#{page}&per_page=#{per_page}"
        
        last_response.should be_ok
        last_response.headers['Content-Type'].should == "text/xml"
        last_response.body.should == @account.articles.published.by_date_published(:desc).paginate(:page => page, :per_page => per_page).to_xml
      end
      
      it "should return specific articles instead, if requested" do
        article = @recently_published_articles.first
        get "/accounts/#{@account.id}/articles.xml?ids[]=#{article.id}"
        
        last_response.should be_ok
        last_response.headers['Content-Type'].should == "text/xml"
        last_response.body.should == @account.articles.published.all(:conditions => { :id => [article.id] }).to_xml
      end
      
      it "should find articles by section id, if requested" do
        category = Factory(:category, :account => @account)
        articles = (1..3).collect{ Factory(:detailed_article, :section => category, :account => @account) }
        get "/accounts/#{@account.id}/articles.xml?section_id=#{category.id}"
        
        last_response.should be_ok
        last_response.headers['Content-Type'].should == "text/xml"
        last_response.body.should == @account.articles.published.by_published_at(:desc).paginate(:page => 1, :per_page => 20, :conditions => { :section_id => category.id }).to_xml
      end
    end
    
  end
  
end