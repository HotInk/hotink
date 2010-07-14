class AuthorsController < ApplicationController

  # GET /authors.json
  def index    
    if params[:q]
      @authors = @account.authors.search_for(params[:q], :on => [:name])
    else 
      @authors = @account.authors.find(:all)
    end
    
    respond_to do |format|
      format.json { render :json => @authors.collect{ |a| { "id" => a.id, "name" => a.name } }.to_json }
    end
  end

end