class DesignsController < ApplicationController
  
  permit "admin"
  
  layout 'hotink'
  
  # GET /designs
  def index
    @designs = @account.designs.all
    respond_to do |format|
      format.html
    end
  end

  # GET /current_design
  def current_design
    @design = @account.current_design 
    render :show
  end

  # GET /designs/1
  def show
    @design = @account.designs.find(params[:id])
    respond_to do |format|
      format.html
    end  
  end
  
  # GET /designs/new
  def new
    @design = @account.designs.build
    respond_to do |format|
      format.html
    end  
  end
  
  # GET /designs/1/edit
  def edit
    @design = @account.designs.find(params[:id])
    respond_to do |format|
      format.html
    end  
  end
  
  # POST /designs
  def create
    @design = @account.designs.build(params[:design])
    if @design.save
      flash[:notice] = 'Design was successfully created.'
      redirect_to(@design)
    else
      render :action => "new"
    end
  end
  
  # PUT /designs/1
  def update
    @design = @account.designs.find(params[:id])
    if @design.update_attributes(params[:design])
      redirect_to(@design)
    else
      render :action => "edit"
    end
  end

  # DELETE /designs/1
  def destroy
    @design = @account.designs.find(params[:id])
    @design.destroy
    redirect_to(designs_url(@account))
  end

end
