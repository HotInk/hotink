# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  helper_method :current_user_session, :current_user
  
  before_filter :find_account
  before_filter :login_or_oauth_required


  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '2b2fa863c84a38ce85b2ad73c4daac41'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password, :password_confirmation
  
  protected
  
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)&&@current_user # Only returns a user if it's defined and not nil
    @current_user = current_user_session && current_user_session.user
  end
  
  private
  
  # These 'find_*' methods load models passed in through url parameters.
  
  def find_account
    if @account
      @account
    elsif params[:account_id]
      @account = Account.find(params[:account_id])
      Time.zone = @account.time_zone
      @account
    else
      @account = false
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
  
  def find_entry
    if params[:blog_id] && params[:entry_id]
      @blog = @account.blogs.find(params[:blog_id])
      @entry = @blog.entries.find(params[:entry_id])
    else
      @blog = false
      @entry = false
    end
  end
  
  
  def login_required
    unless current_user
      store_location
      
      respond_to do |format|
        format.xml  { head :unauthorized  }
        format.html do
          flash[:notice] = "You must be logged in to access this page"
          redirect_to new_user_session_url
        end
      end
      
      return false
    end
  end

  def login_forbidden
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to account_url
      return false
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
    false
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
  
end
