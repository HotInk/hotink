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
    begin
      @category = @account.categories.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      @category = @account.categories.find_by_name(params[:id]) 
    end
    
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
    if params['print_section']
      @category = @account.sections.build(params[:category])
    else
      @category = @account.categories.build(params[:category])
    end
    
    # This serves to retreive any article attached to this new category so we can access that article's apge
    @article = find_article if params[:article_id]

    respond_to do |format|
      if @category.save!
        flash[:categories_notice] =  "\"#{@category.name}\" created"        
        format.js
        format.html { redirect_to(account_categories_url(@account)) }
        format.xml  { render :xml => [@account, @category], :status => :created, :location =>[@account, @category] }
      else
        flash[:categories_notice] =  "Sorry, can't create that category"        
        format.js
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
        flash[:notice] = 'Category updated'
        format.js
        format.html { redirect_to([@account, @category]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end


  def deactivate  
    @category = @account.categories.find(params[:id])
    @category.update_attribute(:active, false)
  
    respond_to do |format|
      format.js
    end
  end

  def reactivate  
    @category = Category.find(params[:id], :conditions => { :account_id => @account.id })
    @category.update_attribute(:active, true)
  
    respond_to do |format|
      format.js
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.xml
  def destroy
    @category = @account.categories.find(params[:id])
    @category.destroy

    respond_to do |format|
      flash[:categories_notice] = "\"#{@category.name}\" deleted"
      format.html { redirect_to(account_categories_url(@account)) }
      format.js
      format.xml  { head :ok }
    end
  end
end
