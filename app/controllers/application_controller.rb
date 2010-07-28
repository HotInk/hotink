# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  helper_method :current_user, :login_url, :logout_url
  
  before_filter :find_account
  before_filter :login_required


  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  #protect_from_forgery # :secret => '2b2fa863c84a38ce85b2ad73c4daac41'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password, :password_confirmation
  
  protected
  
  def current_user
    session[:checkpoint_user_id].nil? ? nil : User.find(session[:checkpoint_user_id])
  end
  
  def current_lead_articles
    if @account.lead_article_ids.blank?
      []
    else
      @account.lead_article_ids.collect{ |id| @account.articles.find_by_id(id) }
    end
  end
  
  # This method determines whether an OAuth request is kosher. 
  # A request is alright if:
  #   - There's no attached account
  #   - The user is staff on this account
  # If neither is true, then the request will fail.
  def authorized?
    return true unless @account
    return true if @account && @account.accepts_role?("staff", current_user)
    return true if current_user.has_role? "admin"
    false
  end
  
  def login_url
    '/sso/login'
  end
  
  def logout_url
    '/sso/logout'
  end
  
  
  private
  
  # These 'find_*' methods load models passed in through url parameters.
  
  def find_account
    if @account
      @account
    else
      @account = Account.find_by_name(current_subdomain)
    end
  end
  
  def find_article
    if params[:article_id]
      @article = @account.articles.find(params[:article_id])
    else
      @article = false
    end
  end
  
  def find_mediafile
    if params[:mediafile_id]
      @mediafile = @account.mediafiles.find(params[:mediafile_id])
    else
      @mediafile = false
    end
  end
  
  def find_document
    if params[:document_id]
      @document = @account.documents.find(params[:document_id])
    else
      @document = nil
    end
  end
  
  def find_entry
    if params[:blog_id] && params[:entry_id]
      @blog = @account.blogs.find(params[:blog_id])
      @entry = @blog.entries.find(params[:entry_id])
    else
      @blog = false
      @entry = false
    end
  end
  
  # Determines which design to render, either the current design or one passed in as <tt>params[:design_id]</tt> 
  def design_to_render
    if params[:design_id]&&current_user&&(current_user.has_role("manager", @account)||current_user.has_role("admin"))
      @account.designs.find(params[:design_id])
    else
      @account.current_design
    end
  end
  
  def login_required
    unless current_user && authorized?
      store_location
      
      respond_to do |format|
        format.xml  { head :unauthorized  }
        format.html do
          redirect_to login_url
        end
      end
      
      return false
    end
    logger.info "Current user: #{current_user.email} at #{request.remote_ip}"
  end
  
  def store_location
    session[:return_to] = request.request_uri
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  
  def clear_flash
    flash[:notice] = ""
  end
  
  def load_user_using_perishable_token  
    # Make user activation url valid for 1 full week.
    @user = User.find_using_perishable_token(params[:id], 1.week)  
    unless @user  
      flash[:notice] = "We're sorry, but we could not locate your account. " +  
      "If you are having issues try copying and pasting the URL " +  
      "from your email into your browser or restarting the " +  
      "process."  
      redirect_to root_url  
    end
  end
  
end
