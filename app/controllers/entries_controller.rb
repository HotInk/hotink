class EntriesController < ApplicationController
  before_filter :find_blog
  
  layout 'hotink'
  
  def new
    @entry = @account.entries.build 
    
    # Check to see if the last entry created for this blog exists and is blank.
    # If so, redate it and serve it up instead of a new entry, to prevent
    # the data from becoming cluttered with abandoned entries.
    #
    # If the last entry was legit, save the fresh entry so it can have relationships 
   if last_blog_entry = @blog.entries.find(:last)
     if last_blog_entry.created_at == last_blog_entry.updated_at
        @entry = last_blog_entry
         @entry.date = Time.now #Give it the current time, without saving.
     else
        @entry.save
        @blog.entries << @entry
     end
   else
      @entry.save
      @blog.entries << @entry
   end
       
      respond_to do |format|
        if @entry.save 
          flash[:notice] = "New blog entry"
          format.html { redirect_to edit_account_blog_entry_url(@account, @blog, @entry) }
          format.xml  { render :xml => @entry }
        else
          flash[:notice] = "Error saving entry"
          format.html { redirect_to account_blog_url(@account, @blog) }
        end
      end
  end
  
  def edit
    @entry = @blog.entries.find(params[:id])
  end
  
  def update
    @entry = @blog.entries.find(params[:id])
  
    respond_to do |format|
      if @entry.update_attributes(params[:entry])
        flash[:notice] = "Entry saved"
        @entry = @blog.entries.find(params[:id])
        format.js
        format.html { redirect_to(edit_account_blog_entry_path(@account, @blog, @entry)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @entry.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  
  private
  
  def find_blog
    if params[:blog_id]
      @blog = @account.blogs.find(params[:blog_id])
    else
      @blog = false
    end
  end
end
