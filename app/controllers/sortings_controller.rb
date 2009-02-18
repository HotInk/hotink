class SortingsController < ApplicationController
  before_filter :find_article
  
  layout 'articles'
  # GET /sortings
  # GET /sortings.xml
  def index
    @sortings = @article.sortings.find(:all)
    @article.categories << @article.section unless @article.categories.member?(@article.section)
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.xml  { render :xml => @sortings }
    end
  end

  # GET /sortings/1
  # GET /sortings/1.xml
  def show
    @sorting = @article.sortings.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @sorting }
    end
  end

  # GET /sortings/new
  # GET /sortings/new.xml
  def new
    @sorting = Sorting.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sorting }
    end
  end

  # GET /sortings/1/edit
  def edit
    @sorting = @article.sortings.find(params[:id])
  end

  # POST /sortings
  # POST /sortings.xml
  def create
    @sorting = Sorting.new(params[:sorting])
    @sorting.article = @article
    @sorting.account = @account

    respond_to do |format|
      if @sorting.save
        flash[:notice] = 'Sorting was successfully created.'
        format.html { redirect_to([@account, @article, @sorting]) }
        format.xml  { render :xml => @sorting, :status => :created, :location => [@account, @article, @sorting] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sorting.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sortings/1
  # PUT /sortings/1.xml
  def update
    @sorting = @article.sortings.find(params[:id])
    @sorting.account = @account

    respond_to do |format|
      if @sorting.update_attributes(params[:sorting])
        flash[:notice] = 'Sorting was successfully updated.'
        format.html { redirect_to([@account, @article, @sorting]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sorting.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sortings/1
  # DELETE /sortings/1.xml
  def destroy
    @sorting = @article.sortings.find(params[:id])
    @sorting.destroy

    respond_to do |format|
      format.html { redirect_to(account_article_sortings_url(@account, @article)) }
      format.xml  { head :ok }
    end
  end
  
end
