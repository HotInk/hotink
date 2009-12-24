# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)
require 'sinatra/base'

class HotinkApi < Sinatra::Base
  
  def load_account
    @account = Account.find(params[:account_id])
  end
  
  get "/accounts/:account_id/articles.xml" do
    load_account
    page = params[:page] || 1
    per_page = params[:per_page] || 20
    
    if params[:ids]
      @articles = @account.articles.published.all(:conditions => { :id => params[:ids] })
    elsif params[:section_id]
      @articles = @account.articles.by_published_at(:desc).paginate(:page => page, :per_page => per_page, :conditions => { :section_id => params[:section_id] }) 
    elsif params[:tagged_with]
      @articles = @account.articles.published.by_published_at(:desc).tagged_with(params[:tagged_with], :on => :tags).paginate( :page=> page, :per_page => per_page )
    elsif params[:search]
      @articles = @account.articles.published.search( params[:search], :page => page, :per_page => per_page)
    else
      @articles = @account.articles.published.by_date_published(:desc).paginate(:page => page, :per_page => per_page)
    end
    
    content_type "text/xml"
    @articles.to_xml    
  end
  
  get "/accounts/:account_id/articles/:id.xml" do
    load_account    
    @article = @account.articles.find(params[:id])

    content_type "text/xml"
    @article.to_xml
  end
  
end
