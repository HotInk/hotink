require 'spec_helper'

describe ArticleStream do
  include Rack::Test::Methods
  include Webrat::Matchers
  
  before do
    @account = Factory(:account)      
    Account.stub!(:find).and_return(@account)
    
    # Use test doubles for authlogic
    @user = mock("user")
    @user.stub!(:has_role?).and_return(true)
    @user.stub!(:login).and_return("Test")
    @user.stub!(:id).and_return(1)
    User.should_receive(:find).with(1).and_return(@user)
  end
  
  def app
    ArticleStream::App
  end
  
  describe "GET to /stream" do
    it "should only display published articles" do
      visible_article = Factory(:published_article, :published_at => 1.day.ago, :bodytext => "")
      invisible_article = Factory(:article)
      get '/stream'
      last_response.body.should have_selector("#article_#{visible_article.id}")
      last_response.body.should_not have_selector("#article_#{invisible_article.id}")
    end
  end
  
  describe "GET to /stream/articles/:id" do
    before(:each) do
      @article = Factory(:detailed_article)
      get "/stream/articles/#{@article.id}"
    end
    
    it "should display the article details" do
      last_response.body.should include(@article.title)
      last_response.body.should include(@article.subtitle)
      last_response.body.should include(@article.authors_list)
      last_response.body.should include(@article.published_at.to_s(:standard))
      last_response.body.should include(Markdown.new(@article.bodytext).to_html)
    end
  end
  
  describe "GET to /team" do
    before(:each) do
      @users = (1..3).collect do |n|
        user = mock("team member")
        user.should_receive(:id).twice.and_return(n)
        user.should_receive(:name).and_return("Team Member ##{n}")
        user.should_receive(:email).and_return("team#{n}@testemail.com")
        user
      end
      @account.should_receive(:has_staff).and_return(@users)
      get "/team", {}, :checkpoint_user_id => 1
    end
    
    it "should show each team member" do
      @users.each do |u|
        last_response.body.should have_selector("#user_#{u.id}")
      end
    end
  end
  
end