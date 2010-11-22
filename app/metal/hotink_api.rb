# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)
require 'sinatra/base'
require "addressable/uri"

class HotinkApi < Sinatra::Base  
  helpers do
    def subdomain
      uri = Addressable::URI.parse("http://#{request.env["HTTP_HOST"]}")
      domains = uri.host.split(".")
      domains.first
    end
    
    def respond_with(results, format, callback=nil)
      case format
      when "xml"  
        content_type "text/xml"
        results.to_xml
      when "json"
        content_type "application/json"
        if callback
          "#{callback}(#{results.to_json})"
        else
          results.to_json
        end
      else
        halt 404, "Not available in the format requested."
      end
    end
  end
  
  def load_account(name)
    @account = Account.find_by_name(name)
  end
 
  get "/search.:format" do
    load_account(subdomain)
    
    if params[:q]
      @hits = @account.articles.published.search(params[:q], :order => "published_at desc")
    else
      @hits = []
    end
    
    case params[:format]
    when "xml"
      content_type "text/xml"
      if @hits.empty?
        Builder::XmlMarkup.new.search_results
      else
        Builder::XmlMarkup.new.search_results do |xml|
          @hits.each { |result| xml << result.to_xml }
        end
      end
    when "json"
      content_type "application/json"
      results_hash = @hits.collect { |c| c.to_hash }
      if callback = params[:callback]
        "#{callback}(#{Yajl::Encoder.encode(results_hash)})"
      else
        Yajl::Encoder.encode(results_hash)
      end
    else
      halt 404, "Not available in the format requested."
    end
  end
 
  get "/articles.:format" do
    load_account(subdomain)
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
    
    respond_with @articles, params[:format], params[:callback]
  end

  get "/articles/:id.:format" do
    load_account(subdomain)
    begin
      @article = @account.articles.published.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      halt 404, "Article not found or unavailable."
    end

    respond_with @article, params[:format], params[:callback]
  end

  get "/issues.:format" do
    load_account(subdomain)
    page = params[:page] || 1
    per_page = params[:per_page] || 15
  
    @issues = @account.issues.processed.paginate(:page => page, :per_page => per_page, :order => "date DESC")
  
    respond_with @issues, params[:format], params[:callback]
  end

  get "/issues/:id.:format" do
    load_account(subdomain)
    begin
      @issue = @account.issues.processed.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      halt 404, "Record not found or unavailable."
    end
    respond_with @issue, params[:format], params[:callback]
  end

  get "/issues/:id/articles.:format" do
    load_account(subdomain)

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
  
    respond_with @articles, params[:format], params[:callback]
  end

  get "/categories.:format" do
    load_account(subdomain)
  
    @categories = @account.categories.active.sections.all

    case params[:format]
    when "xml"
      content_type "text/xml"
      if @categories.empty?
        Builder::XmlMarkup.new.categories
      else
        @categories.to_xml
      end
    when "json"
      content_type "application/json"
      categories_hash = @categories.collect { |c| c.to_hash }
      if callback = params[:callback]
        "#{callback}(#{Yajl::Encoder.encode(categories_hash)})"
      else
        Yajl::Encoder.encode(categories_hash)
      end
    else
      halt 404, "Not available in the format requested."
    end
  end

  get "/categories/:id.:format" do
    load_account(subdomain)
    begin
      @section = @account.categories.active.find_by_name(params[:id])
      @section ||= @account.categories.active.find_by_slug(params[:id])
      @section ||= @account.categories.active.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      halt 404, "Record not found or unavailable."
    end
    
    respond_with @section, params[:format], params[:callback]
  end

  get "/categories/:id/articles.:format" do
    load_account(subdomain)
    begin
      @section = @account.categories.active.sections.find_by_name(params[:id])
      @section ||= @account.categories.active.sections.find_by_slug(params[:id])
      @section ||= @account.categories.active.sections.find(params[:id])
      @section ||= @account.categories.active.find_by_name(params[:id])
      @section ||= @account.categories.active.find_by_slug(params[:id])
      @section ||= @account.categories.active.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      halt 404, "Record not found or unavailable."
    end
    respond_with  @section.articles.published.by_date_published.paginate(:page => 1, :per_page => 20),
                  params[:format], params[:callback]
  end

  get "/blogs.:format" do
    load_account(subdomain)
  
    @blogs = @account.blogs.active
  
    respond_with @blogs, params[:format], params[:callback]
  end

  get "/blogs/:id.:format" do
    load_account(subdomain)
    begin
      @blog = @account.blogs.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      halt 404, "Record not found or unavailable."
    end
    respond_with @blog, params[:format], params[:callback]
  end

  get "/entries.:format" do
    load_account(subdomain)
    page = params[:page] || 1
    per_page = params[:per_page] || 20
  
    if params[:blog_id]
      @blog = @account.blogs.find(params[:blog_id])
      results = @blog.entries.published.by_date_published.paginate(:page => page, :per_page => per_page, :order => "published_at DESC")
      respond_with results, params[:format], params[:callback]
    else
      results = @account.entries.published.by_date_published.paginate(:page => page, :per_page => per_page, :order => "published_at DESC")
      respond_with results, params[:format], params[:callback]
    end
  end

  get "/entries/:id.:format" do
    load_account(subdomain)
    begin
      @entry = @account.entries.published.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      halt 404, "Record not found or unavailable."
    end

    respond_with @entry, params[:format], params[:callback]
  end

  get "/query.:format" do
    load_account(subdomain)
  
    @results = []
    num_records = params[:count] || 5

    case params[:group_by]
    when "section"
      for section in @account.main_categories
         @results += @account.articles.published.find(:all, :conditions => { :section_id => section.id, :status => 'published' }, :limit => num_records, :order => "published_at DESC" )
      end  
    when "blog"
      for blog in @account.blogs
         @results += blog.entries.published.find(:all, :conditions => { :status => 'published' }, :limit => num_records, :order => "published_at DESC" )
      end
    end

    respond_with @results, params[:format], params[:callback]
  end
  
  get "/lead_articles.:format" do
    load_account(subdomain)
    
    @lead_articles = @account.lead_article_ids.nil? ? [] : @account.lead_article_ids.collect{ |id| @account.articles.find_by_id(id) }.compact
    
    case params[:format]
    when "xml"
      content_type "text/xml"
      if @lead_articles.empty?
        Builder::XmlMarkup.new.articles
      else
        @lead_articles.to_xml
      end
    when "json"
      content_type "application/json"
      if callback = params[:callback]
        "#{callback}(#{Yajl::Encoder.encode(@lead_articles)})"
      else
        Yajl::Encoder.encode(@lead_articles)
      end
    else
      halt 404, "Not available in the format requested."
    end
  end
  
  get "/:list_slug.:format" do
    load_account(subdomain)
    
    @list = @account.lists.find_by_slug(params[:list_slug])
    halt 404, "No resource found" unless @list
    
    respond_with @list, params[:format], params[:callback]
  end
end
