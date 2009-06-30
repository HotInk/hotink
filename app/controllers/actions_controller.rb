# An Action is a group update of a number of Hot Ink records with one API call.
# An action takes at least 4 parameters:
#   1. The action id (a string passed via url)
#   2. Action parameters (a hash with a params key equal to the action id)
#   3. Content types (an array of class name strings)
#   4. Content ids arrays (one array for each content type, with the params key "{content_type}_ids")
class ActionsController < ApplicationController
  
  
  def new
    @action = Action.new
    @action.name = params[:name]
    @action.content_types = params[:content_types]
    @records = Hash.new
    params[:content_types].each do |content_type|
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
      format.html { redirect_to account_articles_url(@account) }
    end
      
  end
  
  
  private
  
  def publish( klass, id, options = {} )
    raise ArgumentError unless klass=="articles"
    record = @account.send(klass).find(id)
    
    unless record.status=="Published"
      flash[:notice] = "Articles published" if record.update_attributes({:status => "Published", :published_at => Time.now })
    end
    
  end
  
  def schedule( klass, id, options = {} )
    raise ArgumentError unless klass=="articles"
    record = @account.send(klass).find(id)
    unless record.status=="Published"
        flash[:notice] = "Articles scheduled" if record.update_attributes({:status => "Published", :published_at => Time.local(options[:year].to_i, options[:month].to_i, options[:day].to_i, options[:hour].to_i, options[:minute].to_i) })
    end
  end
  
  def delete( klass, id, options = {} )
    record = @account.send(klass).find(id)
    begin
      record.destroy
      flash[:notice] = "Trashed"
    rescue
    end
  end
  
  def unpublish( klass, id, options = {} )
    raise ArgumentError unless klass=="articles"
    record = @account.send(klass).find(id)
    if record.status=="Published"
      flash[:notice] = "Articles unpublished" if record.update_attributes({:status => nil, :published_at => nil })
    end
  end
  
  def add_tag( klass, id, options = {} )
    raise ArgumentError unless klass=="articles"||klass=="mediafiles"
    record = @account.send(klass).find(id)
    if record.tag_list
      record.tag_list = record.tag_list.to_s + ", #{options[:new_tag_list]}"
    else
      record.tag_list = options[:new_tag_list]
    end
    record.save
    flash[:notice] = "Articles tagged"
  end
  
  def set_primary_section( klass, id, options = {} )
    raise ArgumentError unless klass=="articles"
    record = @account.send(klass).find(id)
    record.section_id = options[:section_id]
    record.save
  end
  
end
