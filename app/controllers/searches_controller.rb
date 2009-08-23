class SearchesController < ApplicationController

  def show
    withs = {}
    conditions = {}
    
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
      @results = search_class.search params[:q], :conditions => conditions, :with => withs
    else
      @results = search_class.search :conditions => conditions, :with => withs
    end
    
    respond_to do |format|
      format.xml { render :xml => @results }
    end
  end
  
end
