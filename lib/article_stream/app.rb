require 'sinatra/base'

module ArticleStream 
  class App < Sinatra::Base
    set :views, File.dirname(__FILE__) + '/views'
    
    helpers do
      include ActionView::Helpers::TextHelper
      include ActionView::Helpers::DateHelper
      include ActionView::Helpers::JavaScriptHelper
      include ActionView::Helpers::TagHelper
      def markdown(text)
        Markdown.new(text).to_html
      end
      
      def paginate(articles)
        unless articles.total_entries <= articles.per_page
          html_output = "<div class=\"pagination\">"
          if articles.current_page > 1
            html_output += "<a href=\"/stream?page=#{articles.current_page - 1}\" class=\"prev_page\" rel=\"prev\">&laquo; Previous</a>" 
          end
          if articles.current_page < (articles.total_entries/articles.per_page + 1)
            html_output += "<a href=\"/stream?page=#{articles.current_page + 1}\" class=\"next_page\" rel=\"next\">Next &raquo;</a>" 
          end
          html_output += "</div>"
        end
      end
      
    end
    
    get '/stream/?' do
      @articles = Article.status_matches('published').by_published_at(:desc).paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 15 )
      erb :stream
    end
    
    get '/stream/by_account' do
      @accounts = Account.all
      erb :stream_by_account
    end
        
    get '/stream/articles/:id' do
      @article = Article.find(params[:id])
      @checkout = @article.pickup
      erb :article
    end
    
    post '/stream/articles/:id/checkout' do
      @article = Article.find(params[:id])
      @checkout = Checkout.new
      @checkout.original_article = @article
      
      @duplicate_article = @article.clone
      @duplicate_article.authors_list = @article.authors_list
      @duplicate_article.account_id = options.owner_account_id
      @duplicate_article.status = nil
      @duplicate_article.section = nil
      
      Checkout.transaction do
        @duplicate_article.save
        @checkout.duplicate_article = @duplicate_article
        @checkout.save 
      end
      
      redirect "/stream/articles/#{@article.id}"
    end  
    
  end
end