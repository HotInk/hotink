require 'spec_helper'

describe Mailout do
  include Rack::Test::Methods
  include Webrat::Matchers
  
  before do
    @account = Factory(:account)
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
    it "should create an unsent mailout"
  end
  
  describe "GET to /accounts/:id/mailouts/:mailout" do
    before do
      @campaign = mock("campaign")
      @campaign.stub!(:[]).and_return("stubbed_info")
      @mailer.should_receive(:find_campaign_by_id).with("sample_id").and_return(@campaign)
      get "/accounts/#{@account.id}/mailouts/sample_id"
    end
    
    it "should display a preview of the mailout" do
      last_response.body.should have_selector("iframe[src=\"#{@campaign['archive_url']}\"]")
    end
    it "should display a send button for unsent mailout"
  end
  
  describe "POST to /accounts/:id/mailouts/:mailout/send" do
    it "should send an unsent mailout"
    it "should not resend an already sent mailout"
  end
  
end