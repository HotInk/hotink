require 'sinatra/base'

module ArticleStream 
  class App < Sinatra::Base
    include Authlogic::ControllerAdapters::SinatraAdapter::Adapter::Implementation
    
    set :owner_account_id, Proc.new { Account.find(:first).id }
    set :views, File.dirname(__FILE__) + '/views'
        
    helpers do
      include ActionView::Helpers::TextHelper
      include ActionView::Helpers::DateHelper
      include ActionView::Helpers::JavaScriptHelper
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::AssetTagHelper
      include ActionView::Helpers::UrlHelper      
      include ApplicationHelper
      
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
    
      def current_user
        puts session.inspect
        session[:checkpoint_user_id].nil? ? nil : User.find(session[:checkpoint_user_id])
      end
    end
    
    def protect_against_forgery?
      false
    end
    
    def load_session 
        @account = Account.find(options.owner_account_id)
        Time.zone = @account.time_zone
        @current_user = current_user
        unless @current_user && (@current_user.has_role?("manager", @account) || @current_user.has_role?("editor", account) || @current_user.has_role?("admin"))
          redirect '/sso/login'
        end
    end
    
    get '/stream/?' do
      load_session
      @memberships = Membership.all
      @articles = Article.published.by_date_published.paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 25, :conditions => { :account_id => @memberships.collect{ |x| x.account_id } } )
      erb :stream
    end
    
    get '/stream/by_account' do
      load_session
      @accounts = Account.all
      erb :stream_by_account
    end
        
    get '/stream/articles/:id' do
      load_session
      @article = Article.find(params[:id])
      @checkout = @article.pickup
      erb :article
    end
    
    post '/stream/articles/:id/checkout' do
      load_session
      @article = Article.find(params[:id])
      @checkout = Checkout.new
      @checkout.original_article = @article
            
      Checkout.transaction do
        @checkout.duplicate_article = @article.photocopy(@account)        
        @checkout.user = @current_user
        @checkout.save!
      end
      
      redirect "/stream/articles/#{@article.id}"
    end  
    
    get '/team' do
      load_session
      @users = @account.has_staff
      erb :team
    end
    
  end
end