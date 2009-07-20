class MediafilesController < ApplicationController
  layout 'hotink'
  
  before_filter :find_article, :find_entry, :find_document
  
  # GET /mediafiles
  # GET /mediafiles.xml
  def index

    if params[:search].blank?
      @mediafiles = @account.mediafiles.paginate( :page=>(params[:page] || 1), :per_page => (params[:per_page] || 20 ), :order => "date DESC", :include => [:authors])
    else
      @search_query = params[:search]
      @mediafiles = @account.mediafiles.search(@search_query, :page=>(params[:page] || 1), :per_page => (params[:per_page] || 20 ), :order => :date, :sort_mode => :desc, :include => [:authors])
    end

    respond_to do |format|
      format.js
      format.html # index.html.erb
      format.xml  { render :xml => @mediafiles.to_xml(:root => "mediafiles") }
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
      if @document
        format.js
      end
      format.xml  { render :xml => @mediafile }
    end
  end

  # GET /mediafiles/1/edit
  def edit
    @mediafile = @account.mediafiles.find(params[:id])
     respond_to do |format|
        format.js
        format.html # new.html.erb
     end
  end

  # POST /mediafiles
  # POST /mediafiles.xml
  def create
    
    # Catch various content types and build the appropriate media type
    case params[:mediafile][:file].content_type
    # Images
    when %r"jpe?g", %r"tiff?", %r"png", %r"gif", %r"bmp"    then @mediafile = @account.images.build(params[:mediafile].merge(:settings => @account.settings["image"]))
    # mp3s/Audiofiles
    when  %r"audio\/mpeg"                                   then @mediafile = @account.audiofiles.build(params[:mediafile])
    # Catch-all for generic file attachments
    else @mediafile = @account.mediafiles.build(params[:mediafile])
    end
    @mediafile.date = Time.now
    

    respond_to do |format|
      if @mediafile.save!
        flash[:notice] = 'Media added'
            #Special behaviour to mimic ajax file-upload on article & entry form, if it's an iframe
            if params[:iframe_post] && @document
              @waxing = @account.waxings.create(:document_id => @document.id, :mediafile_id=> @mediafile.id);
              responds_to_parent do
              			render :update do |page|
              			  page << 'trigger_flash(\'<p style="color:green;">Media added</p>\');'
              				page.replace_html 'mediafiles_list', :partial => 'waxings/waxing', :collection => @document.waxings
              			end
              end
              return
            end
        format.html { redirect_to(edit_account_mediafile_path(@account, @mediafile)) }
        format.js { redirect_to(account_mediafiles_path(@account)) }
        format.xml  { render :xml => @mediafile, :status => :created, :location => @mediafile }
     else
        format.html { head :bad_request }
        format.js { head :bad_request }
        format.xml  { render :xml => @mediafile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mediafiles/1
  # PUT /mediafiles/1.xml
  def update
    @mediafile = @account.mediafiles.find(params[:id])
   	 
    respond_to do |format|
      if @mediafile.update_attributes(params[:mediafile].merge(:settings => @account.settings["image"])) # Pass image-size settings
        flash[:notice] = 'Media updated'      
        format.js
        format.html { redirect_to(account_mediafiles_path(@account))}
        format.xml  { head :ok }
      else
        flash[:notice] = 'Error! Media NOT updated'      
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mediafile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mediafiles/1
  # DELETE /mediafiles/1.xml
  def destroy
    @mediafile = @account.mediafiles.find(params[:id])
    @mediafile.destroy

    respond_to do |format|
      flash[:notice] = 'Media trashed'
      format.html { redirect_to(account_mediafiles_path(@account)) }
      format.js   { head :ok }
      format.xml  { head :ok }
    end
  end
end
