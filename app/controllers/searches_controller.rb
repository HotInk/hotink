class SearchesController < ApplicationController

  def show
    withs = {}
    conditions = {}
    
    @current_page = params[:page].blank? ? 1 : params[:page].to_i
    @per_page = params[:per_page].blank? ? 20 : params[:per_page].to_i
    
    # Build "with" filters from params
    if params[:account_id]
      withs.merge!( :account_id => Account.find(params[:account_id]).id )
    end
    
    # Build conditional searchs from params
    if params[:title]
      conditions.merge!( :title => params[:title] )
    end
    if params[:subtitle]
      conditions.merge!( :subtitle => params[:subtitle] )
    end
    if params[:bodytext]
      conditions.merge!( :bodytext => params[:bodytext] )
    end
    if params[:description]
      conditions.merge!( :description => params[:description] )
    end
    
    # Select which class to use as our search base
    case params[:only]
    when nil
      search_class = ThinkingSphinx
    when "articles", "article", "Articles", "Article"
      search_class = Article
    end
    
    if params[:q]
      @results = search_class.search params[:q], :page => @current_page, :per_page => @per_page, :conditions => conditions, :with => withs
    else
      @results = search_class.search :page => @current_page, :per_page => @per_page, :conditions => conditions, :with => withs
    end

    @paginated_results = WillPaginate::Collection.create(@results.current_page, @results.per_page, @results.total_entries) do |pager|
      pager.replace(@results)
    end 
    
    respond_to do |format|
      format.xml { render :xml => @paginated_results.to_xml }
    end
  end
  
end
