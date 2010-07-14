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
    if request.xhr?
      render :template => 'mediafiles/new.html.erb', :layout => false
    else
      render :action => :new
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
    if params[:mediafile][:file].respond_to?(:content_type)    
      # Catch various content types and build the appropriate media type
      case params[:mediafile][:file].content_type
      # Images
      when %r"jpe?g", %r"tiff?", %r"png", %r"gif", %r"bmp"    then @mediafile = @account.images.create(params[:mediafile].merge(:settings => @account.settings["image"]))
      # mp3s/Audiofiles
      when  %r"audio\/mpeg", %r"audio\/mpg"                   then @mediafile = @account.audiofiles.create(params[:mediafile])
      # Catch-all for generic file attachments
      else @mediafile = @account.mediafiles.create(params[:mediafile])
      end    

      respond_to do |format|
        flash[:notice] = 'Media added'
            #Special behaviour to mimic ajax file-upload on article & entry form, if it's an iframe
            if params[:iframe_post] && @document
              @article = @document
              @waxing = @account.waxings.create(:document_id => @document.id, :mediafile_id=> @mediafile.id);
              responds_to_parent do
          			render :update do |page|
          				page << "$.fancybox.close();$('#article_mediafiles').html('#{ escape_javascript(render(:partial => 'articles/article_mediafile', :collection => @document.mediafiles)) }')"
          			end
              end
              return
            end
        format.html { redirect_to(edit_account_mediafile_path(@account, @mediafile)) }
      end  
     else
       render :text => "Mediafile NOT uploaded", :status => :bad_request
    end
  rescue NoMethodError # Raised in the case that there's no file supplied (on line 54 `params[:mediafile]` will be nil, hence `params[:mediafile][:file]` raises error)
   if @document
      responds_to_parent do
  			render :update do |page|
  				page << "$.fancybox.close();$('#article_mediafiles').html('#{ escape_javascript(render(:partial => 'articles/article_mediafile', :collection => @document.mediafiles)) }')"
  			end
      end
    else
      flash[:notice] = "No mediafile uploaded"
      redirect_to new_account_mediafile_url(@account)
    end
  end

  # PUT /mediafiles/1
  def update
    @mediafile = @account.mediafiles.find(params[:id])
   	
    respond_to do |format|
      if @mediafile.update_attributes(params[@mediafile.class.name.downcase.to_sym]) 
        flash[:notice] = 'Media updated'      
        format.html { redirect_to(account_mediafiles_path(@account))}
        format.js
      else
        flash[:notice] = 'Error! Media NOT updated'      
        format.html { render :action => "edit", :status => :bad_request }
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
