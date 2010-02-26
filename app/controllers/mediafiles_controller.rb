class MediafilesController < ApplicationController
  layout 'hotink'
  
  before_filter :find_article, :find_entry, :find_document
  
  # GET /mediafiles
  def index
    
    if params[:search].blank?
      @mediafiles = @account.mediafiles.paginate( :page=>(params[:page] || 1), :per_page => (params[:per_page] || 20 ), :order => "date DESC", :include => [:authors])
    else
      @search_query = params[:search]
      @mediafiles = @account.mediafiles.search(@search_query, :page=>(params[:page] || 1), :per_page => (params[:per_page] || 20 ), :order => :date, :sort_mode => :desc, :include => [:authors])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end

  # GET /mediafiles/1
  def show
    @mediafile = @account.mediafiles.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /mediafiles/new
  def new
    @mediafile = @account.mediafiles.build

    respond_to do |format|
      format.html # new.html.erb
      if @document
        format.js
      end
    end
  end

  # GET /mediafiles/1/edit
  def edit
    @mediafile = @account.mediafiles.find(params[:id])
     respond_to do |format|
       format.html # new.html.erb
       format.js
     end
  end

  # POST /mediafiles
  def create
    
    # Catch various content types and build the appropriate media type
        
    case params[:mediafile][:file].content_type
    # Images
    when %r"jpe?g", %r"tiff?", %r"png", %r"gif", %r"bmp"    then @mediafile = @account.images.build
    # mp3s/Audiofiles
    when  %r"audio\/mpeg", %r"audio\/mpg"                   then @mediafile = @account.audiofiles.build
    # Catch-all for generic file attachments
    else @mediafile = @account.mediafiles.build
    end
    @mediafile.attributes = params[:mediafile]
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
     else
        format.html { head :bad_request }
        format.js { head :bad_request }
      end
    end
  end

  # PUT /mediafiles/1
  def update
    @mediafile = @account.mediafiles.find(params[:id])
   	 
    respond_to do |format|
      if @mediafile.update_attributes(params[:mediafile]) 
        flash[:notice] = 'Media updated'      
        format.js
        format.html { redirect_to(account_mediafiles_path(@account))}
      else
        flash[:notice] = 'Error! Media NOT updated'      
        format.html { render :action => "edit" }
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
    end
  end
end
