class ListsController < ApplicationController
  
  permit 'manager of account or admin', :except => :index
  
  layout 'hotink'
  
  def index
    page = params[:page] || 1
    per_page = params[:per_page] || 10
    
    @lists = @account.lists.paginate(:page => page, :per_page => per_page, :order => "updated_at desc")
  end
  
  def new
    @list = @account.lists.build
    
    page = params[:page] || 1
    per_page = params[:per_page] || 8
    @articles = @account.articles.published_or_scheduled.paginate(:all, :page => page, :per_page => per_page, :order => 'published_at desc')
  end
  
  def edit
    @list = @account.lists.find(params[:id])
    page = params[:page] || 1
    per_page = params[:per_page] || 8
    
    if params[:q]
      @articles = @account.articles.published_or_scheduled.search(params[:q], :page => page, :per_page => per_page, :order => "published_at desc", :include => [:authors, :mediafiles, :section])
    else
      @articles = @account.articles.published_or_scheduled.paginate(:all, :page => page, :per_page => per_page, :order => 'published_at desc')
    end
  end
  
  def create
    @list = @account.lists.create(:name => params[:list][:name]) # Needs to be created so that list items can be added
    
    if @list.new_record?
      page = params[:page] || 1
      per_page = params[:per_page] || 8
      @articles = @account.articles.published_or_scheduled.paginate(:all, :page => page, :per_page => per_page, :order => 'published_at desc')
      render :new
    else
      @list.update_attributes(params[:list])
      redirect_to lists_url
    end
  end
  
  def update
    @list = @account.lists.find(params[:id])
    
    @list.documents.clear unless params[:list][:document_ids]
    if @list.update_attributes(params[:list])
      redirect_to lists_url
    else
      page = params[:page] || 1
      per_page = params[:per_page] || 8
      @articles = @account.articles.published_or_scheduled.paginate(:all, :page => page, :per_page => per_page, :order => 'published_at desc')
      render :edit
    end
  end
  
  def destroy
    @list = @account.lists.find(params[:id])
    @list.destroy
    redirect_to lists_url
  end
end
