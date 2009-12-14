require 'sinatra/base'

module ArticleStream 
  class App < Sinatra::Base
    set :views, File.dirname(__FILE__) + '/views'
    helpers do
      include ActionView::Helpers::DateHelper
      def markdown(text)
        Markdown.new(text).to_html
      end
    end
    
    get '/stream/?' do
      @articles = Article.status_matches('published')
      erb :stream
    end
    
    get '/stream/articles/:id' do
      @article = Article.find(params[:id])
      erb :article
    end
    
    
  end
end