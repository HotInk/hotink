class SectionsController < ApplicationController
  # GET /sections
  # GET /sections.xml
  def index
    @sections = @account.sections.find(:all)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sections }
    end
  end

  # GET /sections/1
  # GET /sections/1.xml
  def show
    
    begin
      @section = @account.sections.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      @section = @account.sections.find_by_name(params[:id]) 
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @section }
    end
  end

  # GET /sections/new
  # GET /sections/new.xml
  def new
    @section = Section.new

    # If the new section is requested from an existing article page then we have to retain that article for 
    # reloading that article's sortings list to include the new section.
    @article = find_article if params[:article_id]

    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.xml  { render :xml => @section }
    end
  end

  # GET /sections/1/edit
  def edit
    @section = @account.sections.find(params[:id])
  end

  # POST /sections
  # POST /sections.xml
  def create
    @section = Section.new(params[:section])
    @section.account = @account
    
    # This serves to retreive any article attached to this new section so we can access that article's apge
    @article = find_article if params[:article_id]

    respond_to do |format|
      if @section.save
        flash[:notice] = 'Section was successfully created.'
        format.js { redirect_to(account_article_sortings_url(@account, @article, :format=>:js)) if @article}
        format.html { redirect_to(account_sections_url(@account)) }
        format.xml  { render :xml => [@account, @section], :status => :created, :location =>[@account, @section] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @section.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sections/1
  # PUT /sections/1.xml
  def update
    @section = @account.sections.find(params[:id])
    @section.account = @account

    respond_to do |format|
      if @section.update_attributes(params[:section])
        flash[:notice] = 'Section updated'
        format.js
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @section.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sections/1
  # DELETE /sections/1.xml
  def destroy
    @section = @account.sections.find(params[:id])
    @section.destroy

    respond_to do |format|
      format.html { redirect_to(account_sections_url(@account)) }
      format.xml  { head :ok }
    end
  end
end
