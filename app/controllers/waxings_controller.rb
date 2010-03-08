class WaxingsController < ApplicationController
  before_filter :find_article, :find_mediafile, :find_entry, :find_document
  layout 'hotink'
  
  helper_method :plural_class_name

  # GET /waxings/new
  def new
    document = @document || @article || @entry
    
    @waxing = document.waxings.build
    
    @mediafiles = @account.mediafiles.paginate(:page=>(params[:page] || 1), :per_page => (params[:per_page] || 10 ), :order => 'date DESC', :include => [:authors])
    @waxing.document.mediafiles.each { |m| @mediafiles.delete(m) } # Scrub out already attached files

    respond_to do |format|
      format.html # new.html.erb
      format.js
    end
  end

  # GET /waxings/1/edit
  def edit
    @waxing = Waxing.find(params[:id], :include => :document, :conditions => { :documents => { :account_id => @account.id }})
    respond_to do |format|
      format.js
    end
  end

  # POST /waxings
  def create
    # Set behaviour based on document type
    if @document.is_a? Article
      redirect_path = edit_account_article_url(@account, @document)
    elsif @document.is_a? Entry
      redirect_path = edit_account_blog_entry_url(@account, @document.blogs.first, @document)
    end
    params[:mediafile_ids].each { |k, v| @document.waxings.create(:mediafile_id => k)  }
    respond_to do |format|
      flash[:notice] = "Media attached"
      format.html { redirect_to(redirect_path) }
      format.js
    end
  end

  # PUT /waxings/1
  def update
    @waxing = Waxing.find(params[:id])

    respond_to do |format|
      if @waxing.update_attributes(params[:waxing])
        format.js
      end
    end
  end

  # DELETE /waxings/1
  def destroy
    @waxing = Waxing.find(params[:id], :include => :document, :conditions => { :documents => { :account_id => @account.id }})
    
    respond_to do |format|
      if @waxing.destroy
        flash[:notice] = "Media detached"
        format.js
      end
    end
  end
end
