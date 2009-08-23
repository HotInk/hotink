class SearchesController < ApplicationController

  def show
    withs = { :status => 'published' }
    conditions = {}
    
    # Build "with" filters
    if params[:account_id]
      withs.merge!( :account_id => Account.find(params[:account_id]).id )
    end
    
    @results = ThinkingSphinx.search params[:q], :conditions => conditions, :with => withs
    
    respond_to do |format|
      format.xml { render :xml => @results }
    end
  end
  
end
