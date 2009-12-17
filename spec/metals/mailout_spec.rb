require 'spec_helper'
require "authlogic/test_case" # include at the top of test_helper.rb
   # run before tests are executed
  

describe Mailout do
  include Rack::Test::Methods
  include Webrat::Matchers
  include Authlogic::TestCase
  
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
    it "should display the mailout form" do
      get "/accounts/#{@account.id}/mailouts/new"
      last_response.should be_ok
      last_response.body.should have_selector("form[action=\"/accounts/#{@account.id}/mailouts\"]")
    end
  end
  
  describe "POST to /accounts/:id/mailouts" do
    it "should create an unsent mailout" do
      # This is long, but it's the Hominid api spec
      @mailer.should_receive(:create_campaign).with(  'regular', { :list_id => 'c18292dd69', :from_email => "test@example.com", :from_name => "test name", :subject => "A test", :to_email => "totest@example.com" }, { :html => "<h1>Test email</h1>" , :test =>"Test email" })
      post "/accounts/#{@account.id}/mailouts", :mailout => { :from_email => "test@example.com", :name => "test name", :subject => "A test", :to_email => "totest@example.com" }
      last_response.should be_redirect
    end
  end
  
  describe "GET to /accounts/:id/mailouts/:mailout" do
    before do
      @campaign = mock("campaign")
      @campaign.stub!(:[])
      @mailer.should_receive(:find_campaign_by_id).with("sample_id").and_return(@campaign)
      get "/accounts/#{@account.id}/mailouts/sample_id"
    end
    
    it "should display a preview of the mailout" do
      last_response.body.should have_selector("iframe[src=\"#{@campaign['archive_url']}\"]")
    end
    it "should display a send button for unsent mailout" do
      @campaign['send_time'].to_s.should == ""
      last_response.body.should have_selector("input[value=\"Send\"]")
    end
  end
  
  describe "POST to /accounts/:id/mailouts/:mailout/send" do
    it "should send an unsent mailout" do
      @campaign = mock("campaign")
      @campaign.stub!(:[])
      @mailer.should_receive(:find_campaign_by_id).with("sample_id").and_return(@campaign)
      @mailer.should_receive(:send)
      
      post "/accounts/#{@account.id}/mailouts/sample_id/send"      
    end
    it "should not resend an already sent mailout" do
      @campaign = mock("campaign")
      @campaign.stub!(:[]).and_return(1)
      @mailer.should_receive(:find_campaign_by_id).with("sample_id").and_return(@campaign)
      @mailer.should_not_receive(:send)
      
      post "/accounts/#{@account.id}/mailouts/sample_id/send"
    end
  end
  
end