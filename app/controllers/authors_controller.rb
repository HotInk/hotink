class AuthorsController < ApplicationController
  # GET /authors
  # GET /authors.xml
  def index
    if @article = find_article
      @authors = @article.authors
    else 
      @authors = @account.authors.find(:all)
    end
    
    respond_to do |format|
      format.json { render :json => @authors }
    end
  end

  # POST /authors
  # POST /authors.xml
  def create
    @author = @account.authors.find_or_initialize_by_name(params[:author])
        
    respond_to do |format|
      if @author.save
        format.json { render :json => @author, :status => :created }
      end
    end
  end

end
