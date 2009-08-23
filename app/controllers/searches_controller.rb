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
    
    if params[:q]
      @results = ThinkingSphinx.search params[:q], :conditions => conditions, :with => withs
    else
      @results = ThinkingSphinx.search :conditions => conditions, :with => withs
    end
    
    respond_to do |format|
      format.xml { render :xml => @results }
    end
  end
  
end
