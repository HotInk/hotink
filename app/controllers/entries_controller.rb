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
  
  private
  
  def find_blog
    if params[:blog_id]
      @blog = @account.blogs.find(params[:blog_id])
    end
  end
end
