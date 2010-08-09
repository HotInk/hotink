class EntriesController < ApplicationController
  include DocumentsHelper
  
  before_filter :find_blog
  
  layout 'hotink'
  
  def new
    @entry = @blog.entries.create(:account => @account) 
    @entry.owner = current_user
    
    respond_to do |format|
      format.html { redirect_to edit_blog_entry_url(@blog, @entry) }
    end
  end
  
  def edit
    @entry = @blog.entries.find(params[:id])
    permit @entry.is_editable_by
  end
  
  def edit_multiple
    @update_action_name = params[:update_action_name]
    @entries = @account.entries.find(params[:entry_ids])
    respond_to do |format|
       format.html
     end
  end
  
  def show
    @entry = @blog.entries.find(params[:id])
  end
  
  def update
    @entry = @blog.entries.find(params[:id])
    
    publish_time = params[:entry].delete(:schedule)
    
    permit @entry.is_editable_by do
      # Only touch published status if status is passed
      if params[:entry][:status]=="Published"
        if permit?(@entry.is_publishable_by)
          @entry.publish extract_time(publish_time)
        end
      elsif params[:entry][:status]==""
        @entry.unpublish
      end
  
      respond_to do |format|
        if @entry.update_attributes(params[:entry])
          flash[:notice] = "Entry saved"
          format.html { redirect_to(edit_blog_entry_path(@blog, @entry)) }
          format.js
        else
          format.html { render :action => "edit", :status => :bad_request }
        end
      end
      
    end
  end
  
  def update_multiple
    @entries = @account.entries.find(params[:entry_ids])
    @update_action_name = params[:update_action_name]
    @entries.each do |entry|
      action_class = (@update_action_name + "_action").classify.constantize
      action = action_class.new(entry, params[:options])
      action.execute
    end
    
    if @update_action_name=="delete"
      flash[:notice] = "Entries deleted."
    else
      flash[:notice] = "Entries updated."
    end    
    redirect_to blog_url(@entries.first.blog)
  end
  
  def destroy
    @entry = @blog.entries.find(params[:id])
    permit @entry.is_editable_by do
      @entry.destroy
    
      flash[:notice] = "Entry trashed"
      respond_to do |format|
        format.html { redirect_to(blog_url(@blog)) }
        format.js
      end
    end
  end
  
  def comments
    @entry = @blog.entries.find(params[:entry_id])
    @comments = @entry.comments.find(:all, :order => "created_at DESC")
    
    render :action => :comments, :layout => false
  end
  
  def lock_comments
    @entry = @blog.entries.find(params[:id])
    @entry.lock_comments
  end
  
  def disable_comments
    @entry = @blog.entries.find(params[:id])
    @entry.disable_comments
  end
  
  def enable_comments
    @entry = @blog.entries.find(params[:id])
    @entry.enable_comments
  end
  
  private
  
  def find_blog
    if params[:blog_id]
      @blog = @account.blogs.find(params[:blog_id])
    end
  end
end
