class PagesController < ApplicationController
  
  permit 'admin'
  
  layout "hotink"  
  
  def index
    @pages = @account.pages.main_pages
  end
  
  def new
    if params[:parent_id]
      @page = @account.pages.new(:parent => Page.find(params[:parent_id]))
    else
      @page = @account.pages.new
    end
  end
  
  def create
    @page = @account.pages.create(params[:page])
    if @page.new_record?
      render :new
    else
      redirect_to pages_url
    end
  end
  
  def edit
    @page = @account.pages.find(params[:id])
  end
  
  def update
     @page = @account.pages.find(params[:id])
     if @page.update_attributes(params[:page])
       redirect_to pages_url
     else
       render :edit
     end
   end

   def destroy
     @page = @account.pages.find(params[:id])
     @page.destroy
     redirect_to pages_url
   end
  
end
