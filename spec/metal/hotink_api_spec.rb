require 'spec_helper'

describe HotinkApi do
  include Rack::Test::Methods
  
  def app
    HotinkApi
  end
  
  describe "Articles API" do
    before do
      @account = Factory(:account)
    end
      
    describe "GET to /accounts/:account_id/articles/:id.xml" do      
      it "should return an XML representation of a published article" do
        @article = Factory(:detailed_article, :account => @account)
        get "/accounts/#{@account.id}/articles/#{@article.to_param}.xml"
        
        last_response.should be_ok
        last_response.headers['Content-Type'].should == "text/xml"
        last_response.body.should == @article.to_xml
      end
      
      it "should not return an unpublished article" do
        @draft_article = Factory(:draft_article, :account => @account)
        @scheduled_article = Factory(:scheduled_article, :account => @account)
        
        get "/accounts/#{@account.id}/articles/#{@draft_article.to_param}.xml"
        last_response.should be_not_found
        
        get "/accounts/#{@account.id}/articles/#{@scheduled_article.to_param}.xml"
        last_response.should be_not_found        
      end
    end
    
    describe "GET to /accounts/:account_id/articles.xml" do
      before do
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
        first_article = @recently_published_articles.first
        second_article = @recently_published_articles.second        
        get "/accounts/#{@account.id}/articles.xml", :ids => [first_article.id, second_article.id]
        
        last_response.should be_ok
        last_response.headers['Content-Type'].should == "text/xml"
        last_response.body.should == @account.articles.published.all(:conditions => { :id => [first_article.id, second_article.id] }).to_xml
      end
      
      it "should find articles by section id, if requested" do
        category = Factory(:category, :account => @account)
        articles = (1..3).collect{ Factory(:detailed_article, :section => category, :account => @account) }
        get "/accounts/#{@account.id}/articles.xml", :section_id => category.id
        
        last_response.should be_ok
        last_response.headers['Content-Type'].should == "text/xml"
        last_response.body.should == @account.articles.published.by_published_at(:desc).paginate(:page => 1, :per_page => 20, :conditions => { :section_id => category.id }).to_xml
      end
      
      it "should find articles by tag" do
        get "/accounts/#{@account.id}/articles.xml", :tagged_with => "flagged"
        
        last_response.should be_ok
        last_response.headers['Content-Type'].should == "text/xml"
        last_response.body.should == @account.articles.tagged_with('flagged', :on => :tags).published.by_published_at(:desc).paginate(:page => 1, :per_page => 20).to_xml        
      end
    end
    
    describe "GET to /accounts/:account_id/issues.xml" do
      before do
        @issues = (1..5).collect { |n| Factory(:issue, :date => n.days.ago,:account => @account) }
        @processing_issue = Factory(:issue_being_processed, :account => @account)
      end
      
      it "should return an array of published issues" do
        get "/accounts/#{@account.id}/issues.xml"
        
        last_response.should be_ok
        last_response.headers['Content-Type'].should == "text/xml"
        
        @account.issues.processed.should_not include(@processing_issue)
        last_response.body.should == @account.issues.processed.paginate(:page => 1, :per_page => 15, :order => "date DESC").to_xml
      end
    end
    
    describe "GET to /accounts/:account_id/issues/id.xml" do
      it "should return an XML respresentation of the article" do
        @issue = Factory(:issue, :account => @account)
        get "/accounts/#{@account.id}/issues/#{@issue.id}.xml"
        
        last_response.should be_ok
        last_response.headers['Content-Type'].should == "text/xml"
        last_response.body.should == @issue.to_xml
      end
      
      it "should not return a processing issue" do
        @processing_issue = Factory(:issue_being_processed, :account => @account)
        get "/accounts/#{@account.id}/issues/#{@processing_issue.id}.xml"
        
        last_response.should be_not_found
      end
    end
    
    describe "GET to /accounts/:account_id/issues/id/articles.xml" do
      before do
        @issue = Factory(:issue, :account => @account)
        @published_articles = (1..3).collect{ Factory(:detailed_article, :account => @account, :issues => [@issue]) }
      end
      
      it "should return all of this issues published articles" do
        get "/accounts/#{@account.id}/issues/#{@issue.id}/articles.xml"
        
        last_response.should be_ok
        last_response.headers['Content-Type'].should == "text/xml"
        last_response.body.should == @issue.articles.published.by_published_at(:desc).to_xml
      end
      
      it "should not return unpublished articles" do
        @unpublished_article = Factory(:draft_article, :account => @account, :issues => [@issue]) 
        get "/accounts/#{@account.id}/issues/#{@issue.id}/articles.xml"
        
        last_response.body.should == @issue.articles.published.by_published_at(:desc).to_xml
      end
        
      it "should return only articles from a certain section, if requested" do
        category = Factory(:category, :account => @account)
        category_articles = (1..4).collect{ Factory(:detailed_article, :account => @account, :issues => [@issue], :section => category) }      
        get "/accounts/#{@account.id}/issues/#{@issue.id}/articles.xml", :section_id => category.id
        
        last_response.body.should == @issue.articles.in_section(category).by_date_published.to_xml  
      end
    end
    
    describe "GET to /accounts/:account_id/sections.xml" do
      before do
        @sections = (1..5).collect { Factory(:category, :account => @account) }
        @inactive_section = Factory(:category, :account => @account, :active => false)
        @subsection = Factory(:category, :account => @account, :parent => @sections.first)
      end
      
      it "should return a list of active sections" do
        get "/accounts/#{@account.id}/sections.xml"
        
        last_response.should be_ok
        last_response.headers['Content-Type'].should == "text/xml"
        last_response.body.should == @sections.to_xml
      end        
    end
  end
  
end