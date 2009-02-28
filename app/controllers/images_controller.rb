class ImagesController < ApplicationController
  layout 'articles'
  
  # GET /images
  # GET /images.xml
  def index
    @images = @account.images.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @images }
    end
  end

  # GET /images/1
  # GET /images/1.xml
  def show
    @image = @account.images.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @image }
    end
  end

  # GET /images/new
  # GET /images/new.xml
  def new
    @image = @account.images.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @image }
    end
  end

  # GET /images/1/edit
  def edit
    @image = @account.images.find(params[:id])
  end

  # POST /images
  # POST /images.xml
  def create
    # Create new image and set account explicitly to ensure account.settings is
    # available to Paperclip
    @image = Image.new
    @image.account = @account
    @image.attributes = params[:image]

    respond_to do |format|
      if @image.save
        flash[:notice] = 'Image was successfully created.'
        format.html { redirect_to([@account, @image]) }
        format.xml  { render :xml => @image, :status => :created, :location => @image }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @image.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /images/1
  # PUT /images/1.xml
  def update
    @image = @account.images.find(params[:id])

    respond_to do |format|
      if @image.update_attributes(params[:image])
        flash[:notice] = 'Image was successfully updated.'
        format.html { redirect_to([@account, @image]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @image.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1
  # DELETE /images/1.xml
  def destroy
    @image = @account.images.find(params[:id])
    @image.destroy

    respond_to do |format|
      format.html { redirect_to(account_images_url(@account)) }
      format.xml  { head :ok }
    end
  end
end
