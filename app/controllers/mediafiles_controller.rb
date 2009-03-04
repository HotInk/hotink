class MediafilesController < ApplicationController
  # GET /mediafiles
  # GET /mediafiles.xml
  def index
    if @article = find_article
      @mediafiles = @article.mediafiles.find(:all, :include => [ :waxings ], :conditions => ['waxings.article_id = ?', @article.id])
    else
      @mediafiles = @account.mediafiles
    end

    respond_to do |format|
      if @article = find_article
        format.js
      end
      format.html # index.html.erb
      format.xml  { render :xml => @mediafiles }
    end
  end

  # GET /mediafiles/1
  # GET /mediafiles/1.xml
  def show
    @mediafile = Mediafile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mediafile }
    end
  end

  # GET /mediafiles/new
  # GET /mediafiles/new.xml
  def new
    @mediafile = @account.mediafiles.build

    respond_to do |format|
      format.html # new.html.erb
      if @article = find_article
        format.js
      end
      format.xml  { render :xml => @mediafile }
    end
  end

  # GET /mediafiles/1/edit
  def edit
    @mediafile = @account.mediafiles.find(params[:id])
     respond_to do |format|
        if @article = find_article
          format.js
        end
        format.html # new.html.erb
     end
  end

  # POST /mediafiles
  # POST /mediafiles.xml
  def create
    @mediafile = @account.mediafiles.build(params[:mediafile])

    respond_to do |format|
      if @mediafile.save
        #Special behaviour to mimic ajax file-upload
        if @article = find_article
          @waxing = @account.waxings.create(:article_id => @article.id, :mediafile_id=> @mediafile.id);
          responds_to_parent do
          			render :update do |page|
          				page << "reload_media();"
          			end
          end
          return
        end
        flash[:notice] = 'Mediafile was successfully created.'
        format.html { redirect_to(@mediafile) }
        format.xml  { render :xml => @mediafile, :status => :created, :location => @mediafile }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mediafile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mediafiles/1
  # PUT /mediafiles/1.xml
  def update
    @mediafile = @account.mediafiles.find(params[:id])

    respond_to do |format|
      if @mediafile.update_attributes(params[:mediafile])
        #Special behaviour to mimic ajax file-upload
        if @article = find_article
          responds_to_parent do
          			render :update do |page|
          				page << "reload_media();"
          			end
          end
          return
        end
        flash[:notice] = 'Mediafile was successfully updated.'
        format.html { redirect_to(@mediafile) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mediafile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mediafiles/1
  # DELETE /mediafiles/1.xml
  def destroy
    @mediafile = Mediafile.find(params[:id])
    @mediafile.destroy

    respond_to do |format|
      format.html { redirect_to(mediafiles_url) }
      format.xml  { head :ok }
    end
  end
end
