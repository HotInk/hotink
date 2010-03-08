class EntriesController < ApplicationController
  before_filter :find_blog
  
  layout 'hotink'
  
  def new
    @entry = @blog.entries.create(:account => @account) 
       
    respond_to do |format|
      format.html { redirect_to edit_account_blog_entry_url(@account, @blog, @entry) }
    end
  end
  
  def edit
    @entry = @blog.entries.find(params[:id])
  end
  
  def update
    @entry = @blog.entries.find(params[:id])
      
    # Only touch published status if status is passed
    if params[:entry][:status]=="Published"
      
      if permit?("(manager of account) or (editor of blog) or (contributor to blog) or admin")
        # Should we schedule publishing on a custom date or immediately?
        # Rely on a "schedule" parameter to determine which.
        if params[:entry][:schedule] 
          schedule = params[:entry].delete(:schedule)
          @entry.schedule(Time.local(schedule[:year].to_i, schedule[:month].to_i, schedule[:day].to_i, schedule[:hour].to_i, schedule[:minute].to_i))
        else
          @entry.publish
        end
      end

    elsif params[:entry][:status]==""
      params[:entry][:status]=nil #To make sure an entry is unpublished properly
    end
  
    respond_to do |format|
      if @entry.update_attributes(params[:entry])
        flash[:notice] = "Entry saved"
        format.html { redirect_to(edit_account_blog_entry_path(@account, @blog, @entry)) }
        format.js
      else
        format.html { render :action => "edit", :status => :bad_request }
      end
    end
  end
  
  # DELETE /articles/1
  def destroy
    @entry = @blog.entries.find(params[:id])
    @entry.destroy
    
    flash[:notice] = "Entry trashed"
    respond_to do |format|
      format.html { redirect_to(account_blog_url(@account, @blog)) }
      format.js
    end
  end
  
  private
  
  def find_blog
    if params[:blog_id]
      @blog = @account.blogs.find(params[:blog_id])
    end
  end
end
