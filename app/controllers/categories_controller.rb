class CategoriesController < ApplicationController
  # GET /categories
  # GET /categories.xml
  def index
    @categories = @account.categories.find(:all)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => [@account, @categories] }
    end
  end

  # GET /categories/1
  # GET /categories/1.xml
  def show
    @category = @account.categories.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => [@account, @category] }
    end
  end

  # GET /categories/new
  # GET /categories/new.xml
  def new
    @category = Category.new

    # If the new category is requested from an existing article page then we have to retain that article for 
    # reloading that article's sortings list to include the new category.
    @article = find_article if params[:article_id]

    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.xml  { render :xml => [@account, @category] }
    end
  end

  # GET /categories/1/edit
  def edit
    @category = @account.categories.find(params[:id])
  end

  # POST /categories
  # POST /categories.xml
  def create
    @category = Category.new(params[:category])
    @category.account = @account
    
    # This serves to retreive any article attached to this new category so we can access that article's apge
    @article = find_article if params[:article_id]

    respond_to do |format|
      if @category.save
        flash[:notice] = 'Category was successfully created.'
        format.js { redirect_to(account_article_sortings_url(@account, @article, :format=>:js)) if @article}
        format.html { redirect_to(account_categories_url(@account)) }
        format.xml  { render :xml => [@account, @category], :status => :created, :location =>[@account, @category] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /categories/1
  # PUT /categories/1.xml
  def update
    @category = @account.categories.find(params[:id])
    @category.account = @account

    respond_to do |format|
      if @category.update_attributes(params[:category])
        flash[:notice] = 'Category was successfully updated.'
        format.html { redirect_to([@account, @category]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.xml
  def destroy
    @category = @account.categories.find(params[:id])
    @category.destroy

    respond_to do |format|
      format.html { redirect_to(account_categories_url(@account)) }
      format.xml  { head :ok }
    end
  end
end
