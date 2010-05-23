# An Action is a group update of a number of Hot Ink records with HTTP request.
# An action takes at least 4 parameters:
#   1. The action id (a string passed via url)
#   2. Action parameters (a hash with a params key equal to the action id)
#   3. Content types (an array of class name strings)
#   4. Content ids arrays (one array for each content type, with the params key "{content_type}_ids")
class ActionsController < ApplicationController
  
  def new
    @action = Action.new(:name => params[:name], :content_types => params[:content_types])
    @records = Hash.new
    @action.content_types.each do |content_type|
      @records[content_type] = content_type.camelize.constantize.find(params[(content_type+"_ids").to_sym])
    end
    respond_to do |format|
      format.js
    end
  end
  
  
  def create    
    function = params[:name]
    function_options = params[function] || {}   

    params[:content_types].each do |content_type|
      klass = content_type.tableize          
      params[content_type.downcase+"_ids"].each do |id|
            send(function, klass, id, function_options)
      end      
    end
    
    respond_to do |format|
      format.html do
        if params[:content_types].first=="mediafile"
          redirect_to account_mediafiles_url(@account)        
        elsif params[:content_types].first=="entry"
          blog = @account.blogs.find(params[:blog_id])
          redirect_to account_blog_url(@account, blog)        
        else
          redirect_to account_articles_url(@account)
        end
      end
    end
  end
  
  
  private
  
  def delete( klass, id, options = {} )
    record = @account.send(klass).find(id)
    record.destroy
    flash[:notice] = "Trashed"
  end
  
  def publish( klass, id, options = {} )
    record = @account.send(klass).find(id)
    raise ArgumentError unless record&&record.kind_of?(Document)
    
    unless record.published?
      flash[:notice] = "Successfully published" if record.publish!
    end
    
  end
  
  def schedule( klass, id, options = {} )
    record = @account.send(klass).find(id)
    raise ArgumentError unless record&&record.kind_of?(Document)
    if record.published?
      flash[:notice] = "Sorry, you can only schedule drafts, not published documents" 
    else
      flash[:notice] = "Successfully scheduled" if record.schedule!(Time.local(options[:year].to_i, options[:month].to_i, options[:day].to_i, options[:hour].to_i, options[:minute].to_i))
    end
  end
  
  def unpublish( klass, id, options = {} )
    record = @account.send(klass).find(id)
    raise ArgumentError unless record&&record.kind_of?(Document)
    if record.published?
      flash[:notice] = "Articles unpublished" if record.unpublish!
    end
  end
  
  def add_tag( klass, id, options = {} )
    raise ArgumentError unless klass=="articles"||klass=="mediafiles"||klass=="entries"
    record = @account.send(klass).find(id)
    record.tag(options[:new_tag_list])
    record.save!
    flash[:notice] = "Successfully tagged"
  end
  
  def add_issue( klass, id, options = {} )
    record = @account.send(klass).find(id)
    raise ArgumentError unless record&&record.kind_of?(Article)
    record.issues << Issue.find(options[:issue])
    record.save
    flash[:notice] = "Articles attached to issue"
  end  
  
  def set_primary_section( klass, id, options = {} )
    record = @account.send(klass).find(id)
    raise ArgumentError unless record&&record.kind_of?(Article)
    record.section_id = options[:section_id]
    record.save
  end
  
end
