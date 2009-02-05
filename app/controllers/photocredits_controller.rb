class PhotocreditsController < ApplicationController
  # GET /photocredits
  # GET /photocredits.xml
  def index
    @photocredits = Photocredit.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @photocredits }
    end
  end

  # GET /photocredits/1
  # GET /photocredits/1.xml
  def show
    @photocredit = Photocredit.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @photocredit }
    end
  end

  # GET /photocredits/new
  # GET /photocredits/new.xml
  def new
    @photocredit = Photocredit.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @photocredit }
    end
  end

  # GET /photocredits/1/edit
  def edit
    @photocredit = Photocredit.find(params[:id])
  end

  # POST /photocredits
  # POST /photocredits.xml
  def create
    @photocredit = Photocredit.new(params[:photocredit])

    respond_to do |format|
      if @photocredit.save
        flash[:notice] = 'Photocredit was successfully created.'
        format.html { redirect_to(@photocredit) }
        format.xml  { render :xml => @photocredit, :status => :created, :location => @photocredit }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @photocredit.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /photocredits/1
  # PUT /photocredits/1.xml
  def update
    @photocredit = Photocredit.find(params[:id])

    respond_to do |format|
      if @photocredit.update_attributes(params[:photocredit])
        flash[:notice] = 'Photocredit was successfully updated.'
        format.html { redirect_to(@photocredit) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @photocredit.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /photocredits/1
  # DELETE /photocredits/1.xml
  def destroy
    @photocredit = Photocredit.find(params[:id])
    @photocredit.destroy

    respond_to do |format|
      format.html { redirect_to(photocredits_url) }
      format.xml  { head :ok }
    end
  end
end
