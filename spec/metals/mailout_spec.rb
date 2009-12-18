require 'spec_helper'  

describe Mailout do
  include Rack::Test::Methods
  include Webrat::Matchers
  
  before do
    @account = Factory(:account)
    
    # Use test doubles for authlogic
    @user = mock("user")
    @user.should_receive(:has_role?).with("staff", @account).and_return(true)
    @session = mock("user_session")
    @session.stub!(:user).and_return(@user)
    UserSession.stub!(:find).and_return(@session)
    
    @mailer = mock("mailer")
    Hominid::Base.stub!(:new).and_return(@mailer)
  end
  
  def app
    Mailout::App
  end
  
  describe "GET to /accounts/:id/mailouts" do
    it "should display all campaigns from Mailchimp" do
      @mailer.should_receive(:campaigns).and_return(Array.new)
      get "/accounts/#{@account.id}/mailouts"
      last_response.should be_ok
    end
  end
  
  describe "GET to /accounts/:id/mailouts/new" do
    before do
      @articles = (1..5).collect { Factory(:published_article, :account => @account) }
      get "/accounts/#{@account.id}/mailouts/new"
    end
    it "should display the mailout form" do
      last_response.should be_ok
      last_response.body.should have_selector("form[action=\"/accounts/#{@account.id}/mailouts\"]")
    end
    
    it "should display most recently published articles for mailout inclusion" do
      last_response.body.should have_selector("ol#articles")
      for article in @articles
        last_response.body.should have_selector("li#article_#{article.id}")
      end
    end
  end
  
  describe "POST to /accounts/:id/mailouts" do
    before do
      @articles = (1..5).collect { Factory(:published_article, :account => @account) }
      @article_ids = @articles.collect { |a| a.id.to_s }
    end
    
    it "should create an unsent mailout" do
      Article.should_receive(:find).with(@article_ids).and_return(@articles)
      
      # This is long, but it's the Hominid api spec
      @mailer.should_receive(:create_campaign).with('regular', { :list_id => 'c18292dd69', :from_email => "test@example.com", :from_name => "test name", :subject => "A test", :to_email => "totest@example.com" }, an_instance_of(Hash) )
      post "/accounts/#{@account.id}/mailouts", :mailout => { :from_email => "test@example.com", :name => "test name", :subject => "A test", :to_email => "totest@example.com", :articles => @article_ids }
      last_response.should be_redirect
    end
  end
  
  describe "GET to /accounts/:id/mailouts/:mailout" do
    before do
      @campaign = mock("campaign")
      @campaign.stub!(:[])
      @sample_content = {"html" => "<h1>HTML sample email test</h1>"}
      @mailer.should_receive(:find_campaign_by_id).with("sample_id").and_return(@campaign)
      @mailer.should_receive(:content).and_return(@sample_content)
      get "/accounts/#{@account.id}/mailouts/sample_id"
    end
    
    it "should display a preview of the mailout" do
      last_response.body.should include(@sample_content["html"])
    end
    it "should display a send button for unsent mailout" do
      @campaign['send_time'].to_s.should == ""
      last_response.body.should have_selector("input[value=\"Send\"]")
    end
  end
  
  describe "POST to /accounts/:id/mailouts/:mailout/send" do
    before do
      @campaign = mock("campaign")
    end
    
    it "should send an unsent mailout" do
      @campaign.should_receive(:[]).with('id').and_return("sample_id")
      @campaign.should_receive(:[]).with('emails_sent').and_return(0)
      @mailer.should_receive(:find_campaign_by_id).with("sample_id").and_return(@campaign)
      @mailer.should_receive(:send)
      
      post "/accounts/#{@account.id}/mailouts/sample_id/send"      
    end
        
    it "should not resend an already sent mailout" do
      @campaign.stub!(:[]).and_return(1)
      @mailer.should_receive(:find_campaign_by_id).with("sample_id").and_return(@campaign)
      @mailer.should_not_receive(:send)
      
      post "/accounts/#{@account.id}/mailouts/sample_id/send"
    end
  end
  
  describe "POST to /accounts/:id/mailouts/:mailout/send_test" do
    it "should send a test email for an unsent mailout" do
      @campaign = mock("campaign")
      @campaign.should_receive(:[]).with('id').twice.and_return("sample_id")
      @campaign.should_receive(:[]).with('emails_sent').and_return(0)
      
      @mailer.should_receive(:find_campaign_by_id).with("sample_id").and_return(@campaign)
      @mailer.should_receive(:send_test).with("sample_id", ["test@test.com", "retest@retest.org"], "html")
      
      post "/accounts/#{@account.id}/mailouts/sample_id/send_test", :emails => "test@test.com,retest@retest.org"
    end
  end
    
  describe "DELETE to /accounts/:id/mailouts/:mailout" do    
    it "should delete the mailout" do
      @mailer.should_receive(:delete).with("sample_id").and_return(true)
      delete "/accounts/#{@account.id}/mailouts/sample_id"
      last_response.should be_redirect
    end
  end
  
end