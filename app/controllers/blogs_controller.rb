class BlogsController < ApplicationController
  
  layout 'hotink'
  
  def index
    @blogs = @account.blogs
    
    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
    
  end
  
  def new
    @blog = @account.blogs.build
    
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @blog }
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
        format.xml  { render :xml => @blog, :status => :created, :location => @blog }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @blog.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def show
    @blog = @account.blogs.find(params[:id])
    @entries = @blog.entries.paginate( :page => params[:page], :per_page => params[:per_page])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @blog }
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
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @blog.errors, :status => :unprocessable_entity }
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
