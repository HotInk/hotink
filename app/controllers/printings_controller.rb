class PrintingsController < ApplicationController
  
  before_filter :find_article, :only => [ :create, :destroy ]

  # GET /printings.xml
  def index
    @printings = Printing.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @printings }
    end
  end

  # GET /printings/1
  # GET /printings/1.xml
  def show
    @printing = Printing.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @printing }
    end
  end

  # GET /printings/new
  # GET /printings/new.xml
  def new
    @printing = Printing.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @printing }
    end
  end

  # GET /printings/1/edit
  def edit
    @printing = Printing.find(params[:id])
  end

  # POST /printings
  # POST /printings.xml
  def create
    @printing = @account.printings.build(params[:printing])
    @printing.document = @article

    respond_to do |format|
      if @printing.save
        flash[:notice] = 'Printing recorded'
        format.html { redirect_to( edit_account_article_url(@account, @article) ) }
        format.js 
        format.xml  { render :xml => @printing, :status => :created, :location => @printing }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @printing.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /printings/1
  # PUT /printings/1.xml
  def update
    @printing = Printing.find(params[:id])

    respond_to do |format|
      if @printing.update_attributes(params[:printing])
        flash[:notice] = 'Printing was successfully updated.'
        format.html { redirect_to(@printing) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @printing.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /printings/1
  # DELETE /printings/1.xml
  def destroy
    @printing = @article.printings.find(params[:id])
    @printing.destroy

    respond_to do |format|
      format.html { redirect_to( edit_account_article_url(@account, @article) ) }
      format.js
      format.xml  { head :ok }
    end
  end
end
