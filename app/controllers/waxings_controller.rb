class WaxingsController < ApplicationController
  before_filter :find_article, :find_mediafile
  
  # GET /waxings
  # GET /waxings.xml
  def index
    @waxings = Waxing.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @waxings }
    end
  end

  # GET /waxings/1
  # GET /waxings/1.xml
  def show
    @waxing = Waxing.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @waxing }
    end
  end

  # GET /waxings/new
  # GET /waxings/new.xml
  def new
    @waxing = @account.waxings.build
    @waxing.article = @article
    @mediafiles = @account.mediafiles.search(@search_query, :page=>(params[:page] || 1), :per_page => (params[:per_page] || 20 ), :order => :date, :sort_mode => :desc, :include => [:authors])
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @waxing }
    end
  end

  # GET /waxings/1/edit
  def edit
    @waxing = @account.waxings.find(params[:id])
    respond_to do |format|
      if @article = find_article
        format.js
      end
      format.html
    end
  end

  # POST /waxings
  # POST /waxings.xml
  def create
    @waxing = Waxing.new(params[:waxing])

    respond_to do |format|
      if @waxing.save
        flash[:notice] = 'Waxing was successfully created.'
        format.html { redirect_to(@waxing) }
        format.xml  { render :xml => @waxing, :status => :created, :location => @waxing }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @waxing.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /waxings/1
  # PUT /waxings/1.xml
  def update
    @waxing = Waxing.find(params[:id])

    respond_to do |format|
      if @waxing.update_attributes(params[:waxing])
        if @article = find_article
          format.js
        end
        format.html { redirect_to(@waxing) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @waxing.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /waxings/1
  # DELETE /waxings/1.xml
  def destroy
    @waxing = @account.waxings.find(params[:id])
    @waxing.destroy

    respond_to do |format|
      if @article == @waxing.article
        format.js { head :ok }
      end
      format.html { redirect_to(waxings_url) }
      format.xml  { head :ok }
    end
  end
end
