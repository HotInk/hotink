class CategoriesController < ApplicationController

  # POST /categories
  def create
    @category = @account.categories.build(params[:category])
    if @category.save
      flash[:categories_notice] =  "\"#{@category.name}\" created"        
    else
      flash[:categories_notice] =  "Sorry, can't create that category"        
    end
    respond_to do |format|
      format.js
    end
  end

  # PUT /categories/1
  def update
    @category = @account.categories.find(params[:id])
    respond_to do |format|
      if @category.update_attributes(params[:category])
        flash[:notice] = 'Category updated'
        format.js
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
  def destroy
    @category = @account.categories.find(params[:id])
    @category.destroy
    flash[:categories_notice] = "\"#{@category.name}\" deleted"

    respond_to do |format|
      format.js
    end
  end
end
