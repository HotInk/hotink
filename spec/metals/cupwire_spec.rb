require 'spec_helper'

describe Cupwire do
  include Rack::Test::Methods
  include Webrat::Matchers  
  
  def app
    Cupwire
  end
  
  describe "with a variety of articles and accounts in the archive" do
    before(:each) do
      @accounts = (1..3).collect{ Factory(:account) }
      @accounts.each{ |a| 5.times { Factory(:basic_article, :account => a) } }
    end
    
    it "should display all the articles" do
      get '/stream'
      last_response.body.should have_selector("ol#stream_articles")
      for article in Article.all
          last_response.body.should have_selector("#article_#{article.id}")
      end
    end
  end
  
end