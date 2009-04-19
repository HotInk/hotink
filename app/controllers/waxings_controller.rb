class WaxingsController < ApplicationController
  before_filter :find_article, :find_mediafile
  layout 'hotink'
  
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
    @mediafiles = @account.mediafiles.search(@search_query, :page=>(params[:page] || 1), :per_page => (params[:per_page] || 10 ), :order => :date, :sort_mode => :desc, :include => [:authors])
    @waxing.article.mediafiles.each { |m| @mediafiles.delete(m) }
    
    respond_to do |format|
      format.html # new.html.erb
      format.js
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
  # This is a split behaviour method, handling create-one and create-many based
  # on which parameters it receives. 
  def create
    if params[:waxing]
      @waxing = @account.waxings.build(params[:waxing])
      respond_to do |format|
        if @waxing.save
          flash[:notice] = 'Media attached'
          format.html { redirect_to(@waxing) }
          format.xml  { render :xml => @waxing, :status => :created, :location => @waxing }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @waxing.errors, :status => :unprocessable_entity }
        end
      end
    elsif params[:mediafile_ids]
      params[:mediafile_ids].each { |k, v| @account.waxings.create(:article_id => @article.id, :mediafile_id => k)  }
      
      respond_to do |format|
        flash[:notice] = "Media attached"
        format.html { redirect_to(edit_account_article_url(@account, @article)) }
        format.js { head :ok }
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
