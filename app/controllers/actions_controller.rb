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
    function = params[:name] || "save"
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
  
  def publish(klass, id, options = {} )
    raise ArgumentError unless klass=="articles"
    record = @account.send(klass).find(id)
    unless record.status=="Published"
      flash[:notice] = "Articles published" if record.update_attributes({:status => "Published", :published_at => Time.now })
    end
  end
  
end
