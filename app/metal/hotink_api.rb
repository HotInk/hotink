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
      @articles = @account.articles.published.by_published_at(:desc).paginate(:page => page, :per_page => per_page, :conditions => { :section_id => params[:section_id] }) 
    elsif params[:tagged_with]
      @articles = @account.articles.published.by_published_at(:desc).tagged_with(params[:tagged_with], :on => :tags).paginate( :page=> page, :per_page => per_page )
    elsif params[:search]
      articles = @account.articles.published.search( params[:search], :page => page)
      @articles = WillPaginate::Collection.create(articles.current_page, articles.per_page, articles.total_entries) do |pager|
       pager.replace(articles.to_a)
      end
    else
      @articles = @account.articles.published.by_date_published.paginate(:page => page, :per_page => per_page)
    end
    
    content_type "text/xml"
    @articles.to_xml    
  end
  
  get "/accounts/:account_id/articles/:id.xml" do
    load_account    
    begin
      @article = @account.articles.published.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      halt 404, "Record not found or unavailable."
    end

    content_type "text/xml"
    @article.to_xml
  end
  
  get "/accounts/:account_id/issues.xml" do
    load_account
    page = params[:page] || 1
    per_page = params[:per_page] || 15
    
    @issues = @account.issues.processed.paginate(:page => page, :per_page => per_page, :order => "date DESC")
    
    content_type "text/xml"
    @issues.to_xml
  end
  
  get "/accounts/:account_id/issues/:id.xml" do
    load_account    
    begin
      @issue = @account.issues.processed.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      halt 404, "Record not found or unavailable."
    end
    content_type "text/xml"
    @issue.to_xml
  end
  
  get "/accounts/:account_id/issues/:id/articles.xml" do
    load_account    

    begin
      @issue = @account.issues.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      halt 404, "Record not found or unavailable."
    end
    
    if params[:section_id]
      begin
        @section = @account.categories.find(params[:section_id]) if params[:section_id]
      rescue
        @articles = []
      else
        @articles = @issue.articles.published.in_section(@section).by_date_published.all
      end
    else
      @articles = @issue.articles.published.by_date_published.all
    end
    
    content_type "text/xml"
    @articles.to_xml
  end
  
  get "/accounts/:account_id/sections.xml" do
    load_account
    
    @sections = @account.categories.active.sections.all
    
    content_type "text/xml"
    @sections.to_xml
  end

  get "/accounts/:account_id/sections/:id.xml" do
    load_account    
    begin
      @section = @account.categories.active.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      @section = @account.categories.active.find_by_name(params[:id])
      halt 404, "Record not found or unavailable." unless @section
    end
    content_type "text/xml"
    @section.to_xml
  end

  get "/accounts/:account_id/blogs.xml" do
    load_account
    
    @blogs = @account.blogs
    
    content_type "text/xml"
    @blogs.to_xml
  end

  get "/accounts/:account_id/blogs/:id.xml" do
    load_account
    begin
      @blog = @account.blogs.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      halt 404, "Record not found or unavailable."
    end
    content_type "text/xml"
    @blog.to_xml
  end

  get "/accounts/:account_id/entries.xml" do
    load_account
    page = params[:page] || 1
    per_page = params[:per_page] || 20
    
    content_type "text/xml"
    if params[:blog_id]
      @blog = @account.blogs.find(params[:blog_id])
      @blog.entries.published.by_date_published.paginate(:page => page, :per_page => per_page, :order => "published_at DESC").to_xml
    else
      @account.entries.published.by_date_published.paginate(:page => page, :per_page => per_page, :order => "published_at DESC").to_xml
    end
  end
  
  get "/accounts/:account_id/entries/:id.xml" do
    load_account    
    begin
      @entry = @account.entries.published.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      halt 404, "Record not found or unavailable."
    end

    content_type "text/xml"
    @entry.to_xml
  end
  
  get "/accounts/:account_id/query.xml" do
    load_account
    
    @results = []
    num_records = params[:count] || 5

    case params[:group_by]
    when "section"
      for section in @account.main_categories
         @results += @account.articles.find(:all, :conditions => { :section_id => section.id, :status => 'published' }, :limit => num_records, :order => "published_at DESC" )
      end  
    when "blog"
      for blog in @account.blogs
         @results += blog.entries.find(:all, :conditions => { :status => 'published' }, :limit => num_records, :order => "published_at DESC" )
      end
    end

    content_type "text/xml"
    @results.to_xml
  end

end
