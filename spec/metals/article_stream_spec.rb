require 'spec_helper'

describe ArticleStream do
  include Rack::Test::Methods
  include Webrat::Matchers  
  
  def app
    ArticleStream::App
  end
  
  describe "GET to /stream" do
    it "should only display published articles" do
      visible_article = Factory(:published_article)
      invisible_article = Factory(:article)
      get '/stream'
      last_response.body.should have_selector("#article_#{visible_article.id}")
      last_response.body.should_not have_selector("#article_#{invisible_article.id}")
    end
    
    it "should display most recent articles first"
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
  
end