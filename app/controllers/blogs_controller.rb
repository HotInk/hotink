class BlogsController < ApplicationController
  
  layout 'hotink'
  
  def index
    @active_blogs = @account.blogs.active
    @inactive_blogs = @account.blogs.inactive    
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def new
    @blog = @account.blogs.build
    
    respond_to do |format|
      format.html 
    end
  end
  
  def create
    @blog = @account.blogs.build(params[:blog])

    respond_to do |format|
      if @blog.save
        @blog.accepts_role "contributor", current_user
        @blog.accepts_role "editor", current_user
        
        flash[:notice] = 'New blog created'
        format.html { redirect_to([@account, @blog]) }
      else
        format.html { render :action => "new", :status => :bad_request }
      end
    end
  end
  
  def show
    page = params[:page] || 1
    per_page = params[:per_page] || 20
    
    @blog = @account.blogs.find(params[:id])
    
    if params[:search]
      @search_query = params[:search]
      @entries = @blog.entries.search( @search_query, :page => page, :per_page => per_page, :include => [:authors, :mediafiles], :with => { :account_id => @account.id })
    else
      @entries = @blog.entries.published.paginate( :page => page, :per_page => per_page)
      if page.to_i == 1
        @drafts = @blog.entries.drafts.all(:include => [:authors, :mediafiles])
        @scheduled = @blog.entries.scheduled.by_published_at(:desc).all(:include => [:authors, :mediafiles])
      end
    end
    
    respond_to do |format|
      format.html # show.html.erb
    end
  end
  
  def edit
    @blog = @account.blogs.find(params[:id])
  end
  
  def update
    @blog = @account.blogs.find(params[:id])

    respond_to do |format|
      if @blog.update_attributes(params[:blog])
        flash[:notice] = 'Blog details updated'
        format.html { redirect_to([@account, @blog]) }
      else
        format.html { render :action => "edit", :status => :bad_request }
      end
    end
  end
  
  def add_user
    @blog = @account.blogs.find(params[:id])
    @user = User.find(params[:user])
    
    # Only account staff can contribute to a blog
    if @user.has_role?("staff", @account)
      @user.has_role( "contributor", @blog)
    end
    
    respond_to do |format|
      format.js
    end
  end
  
  def remove_user
    @blog = @account.blogs.find(params[:id])
    @user = User.find(params[:user])
    
    if @user.has_role?( "contributor", @blog)
      @user.has_no_role("contributor", @blog)
      @user.has_no_role("editor", @blog)      
    end
    
    respond_to do |format|
      format.js
    end
  end
  
  def promote_user
    @blog = @account.blogs.find(params[:id])
    @user = User.find(params[:user])
    
    # Only staff can post to or edit a blog
    if @user.has_role?( "staff", @account)
      @user.has_role("contributor", @blog)
      @user.has_role("editor", @blog)      
    end
    
    respond_to do |format|
      format.js
    end
  end
  
end
