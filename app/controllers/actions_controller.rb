# An Action is a group update of a number of Hot Ink records with one API call.
# An action takes at least 4 parameters:
#   1. The action id (a string passed via url)
#   2. Action parameters (a hash with a params key equal to the action id)
#   3. Content types (an array of class name strings)
#   4. Content ids arrays (one array for each content type, with the params key "{content_type}_ids")
class ActionsController < ApplicationController
  
  
  
  def create    
    function = params[:id] || "publish"
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
    flash[:notice] = "Articles published" if record.update_attributes({:status => "Published", :published_at => Time.now })
  end
  
end
