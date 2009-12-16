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
      @mailer.should_receive(:campaigns)
      get "/accounts/#{@account.id}/mailouts"
    end
    
    it "should render a mailouts page" do
      get "/accounts/#{@account.id}/mailouts"
      last_response.should be_ok
    end
  end
  
  describe "GET to /accounts/:id/mailouts/new" do
    it "should display the mailout form"
  end
  
  describe "GET to /accounts/:id/mailouts" do
    it "should create an unsent mailout"
  end
  
  describe "GET to /accounts/:id/mailouts/:mailout" do
    it "should display a preview of the mailout"
    it "should display a send button for unsent mailout"
  end
  
  describe "POST to /accounts/:id/mailouts/:mailout/send" do
    it "should send an unsent mailout"
    it "should not resend an already sent mailout"
  end
  
  
end