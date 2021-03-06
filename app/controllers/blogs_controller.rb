class BlogsController < ApplicationController
  
  layout 'hotink'
  
  permit "manager of account or admin", :only => [:new, :create]
  
  before_filter :load_blog_from_id, :only => [:manage_contributors, :add_contributor, :remove_contributor, :promote_contributor, :demote_contributor]
  permit "manager of account or admin or editor of blog", :only => [:manage_contributors, :add_contributor, :remove_contributor, :promote_contributor, :demote_contributor]
  
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
        format.html { redirect_to(@blog) }
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
      @entries = @blog.entries.published_or_scheduled.search( @search_query, :page => page, :per_page => per_page, :order => "published_at desc", :include => [:authors, :mediafiles], :with => { :account_id => @account.id })
    else
      @entries = @blog.entries.paginate(:page => page, :per_page => per_page, :order => 'status, published_at desc, updated_at desc')
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
        format.html { redirect_to(@blog) }
      else
        format.html { render :action => "edit", :status => :bad_request }
      end
    end
  end
  
  def manage_contributors
    respond_to do |format|
      format.html 
    end
  end

  def add_contributor
    @user = User.find(params[:user])
    
    @blog.add_contributor @user
    
    respond_to do |format|
      format.html { redirect_to(manage_contributors_blog_url(@blog)) }
    end
  end
  
  def remove_contributor
    @user = User.find(params[:user])
    
    @blog.remove_contributor @user
    
    respond_to do |format|
      format.html { redirect_to(manage_contributors_blog_url(@blog)) }
    end
  end
  
  def promote_contributor
    @user = User.find(params[:user])
    
    @blog.make_editor(@user)
    
    respond_to do |format|
      format.html { redirect_to(manage_contributors_blog_url(@blog)) }
    end
  end
  
  def demote_contributor
    @user = User.find(params[:user])
    
    @blog.demote_editor(@user)
    
    respond_to do |format|
      format.html { redirect_to(manage_contributors_blog_url(@blog)) }
    end
  end
  
  private
  
  def load_blog_from_id
    @blog = @account.blogs.find(params[:id])
  end
end
